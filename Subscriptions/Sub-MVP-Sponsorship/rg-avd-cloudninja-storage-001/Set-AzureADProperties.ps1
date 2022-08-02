param (
  $tenantId,
  $subscriptionId,
  $resourceGroupName,
  $storageAccountName
)

$AdModule = Get-Module ActiveDirectory;
 if ($null -eq $AdModule) {
    Write-Error "Please install and/or import the ActiveDirectory PowerShell module." -ErrorAction Stop;
}
$domainInformation = Get-ADDomain
$domainGuid = $domainInformation.ObjectGUID.ToString()
$domainName = $domainInformation.DnsRoot
$domainSid = $domainInformation.DomainSID.Value
$forestName = $domainInformation.Forest
$netBiosDomainName = $domainInformation.DnsRoot
$azureStorageSid = $domainSid + "-123454321";

Write-Verbose "Setting AD properties on $storageAccountName in $resourceGroupName : `
        EnableActiveDirectoryDomainServicesForFile=$true, ActiveDirectoryDomainName=$domainName, `
        ActiveDirectoryNetBiosDomainName=$netBiosDomainName, ActiveDirectoryForestName=$($domainInformation.Forest) `
        ActiveDirectoryDomainGuid=$domainGuid, ActiveDirectoryDomainSid=$domainSid, `
        ActiveDirectoryAzureStorageSid=$azureStorageSid"

$Uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Storage/storageAccounts/{2}?api-version=2021-04-01' -f $subscriptionId, $resourceGroupName, $storageAccountName);

$json=
    @{
        properties=
            @{azureFilesIdentityBasedAuthentication=
                @{directoryServiceOptions="AADKERB";
                    activeDirectoryProperties=@{domainName="$($domainName)";
                                                netBiosDomainName="$($netBiosDomainName)";
                                                forestName="$($forestName)";
                                                domainGuid="$($domainGuid)";
                                                domainSid="$($domainSid)";
                                                azureStorageSid="$($azureStorageSid)"}
                }
            }
    };  

$json = $json | ConvertTo-Json -Depth 99

$token = $(Get-AzAccessToken).Token
$headers = @{ Authorization="Bearer $token" }

try {
    Invoke-RestMethod -Uri $Uri -ContentType 'application/json' -Method PATCH -Headers $Headers -Body $json
} catch {
    Write-Host $_.Exception.ToString()
    Write-Host "Error setting Storage Account AD properties.  StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "Error setting Storage Account AD properties.  StatusDescription:" $_.Exception.Response.StatusDescription
    Write-Error -Message "Caught exception setting Storage Account AD properties: $_" -ErrorAction Stop
}