param (
    $resourceGroupName,
    $storageAccountName
)

$kerbKey1 = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName -ListKerbKey | Where-Object { $_.KeyName -like "kerb1" }
$aadPasswordBuffer = [System.Linq.Enumerable]::Take([System.Convert]::FromBase64String($kerbKey1.Value), 32);
$password = "kk:" + [System.Convert]::ToBase64String($aadPasswordBuffer);

$azureAdTenantDetail = Get-AzureADTenantDetail;
$azureAdPrimaryDomain = ($azureAdTenantDetail.VerifiedDomains | Where-Object {$_._Default -eq $true}).Name

$servicePrincipalNames = New-Object string[] 3
$servicePrincipalNames[0] = 'HTTP/{0}.file.core.windows.net' -f $storageAccountName
$servicePrincipalNames[1] = 'CIFS/{0}.file.core.windows.net' -f $storageAccountName
$servicePrincipalNames[2] = 'HOST/{0}.file.core.windows.net' -f $storageAccountName

$application = New-AzureADApplication -DisplayName $storageAccountName -IdentifierUris $servicePrincipalNames -GroupMembershipClaims "All";

$servicePrincipal = New-AzureADServicePrincipal -AccountEnabled $true -AppId $application.AppId -ServicePrincipalType "Application";

$Token = ([Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens['AccessToken']).AccessToken
$Uri = ('https://graph.windows.net/{0}/{1}/{2}?api-version=1.6' -f $azureAdPrimaryDomain, 'servicePrincipals', $servicePrincipal.ObjectId)
$json = @'
{
  "passwordCredentials": [
  {
    "customKeyIdentifier": null,
    "endDate": "<STORAGEACCOUNTENDDATE>",
    "value": "<STORAGEACCOUNTPASSWORD>",
    "startDate": "<STORAGEACCOUNTSTARTDATE>"
  }]
}
'@
$now = [DateTime]::UtcNow
$json = $json -replace "<STORAGEACCOUNTSTARTDATE>", $now.AddHours(-12).ToString("s")
  $json = $json -replace "<STORAGEACCOUNTENDDATE>", $now.AddMonths(6).ToString("s")
$json = $json -replace "<STORAGEACCOUNTPASSWORD>", $password
$Headers = @{'authorization' = "Bearer $($Token)"}
try {
  Invoke-RestMethod -Uri $Uri -ContentType 'application/json' -Method Patch -Headers $Headers -Body $json 
  Write-Host "Success: Password is set for $storageAccountName"
} catch {
  Write-Host $_.Exception.ToString()
  Write-Host "StatusCode: " $_.Exception.Response.StatusCode.value
  Write-Host "StatusDescription: " $_.Exception.Response.StatusDescription
}