resource "azurerm_resource_group" "resourcegroup" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_storage_account" "FSLogixStorageAccount" {
  name                      = var.FSLogixStorageAccount
  location                  = azurerm_resource_group.resourcegroup.location
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  account_kind              = "FileStorage"  
}

data "azurerm_virtual_network" "SharedServicesvNet" {
  name                = "vnet-sharedservices-001"
  resource_group_name = "rg-sharedservices-network-001"
}

data "azurerm_subnet" "SharedServicesSubnets" {
  name                  = "snet-sharedservices-adds-001"
  virtual_network_name  = data.azurerm_virtual_network.SharedServicesvNet.name
  resource_group_name   = data.azurerm_virtual_network.SharedServicesvNet.resource_group_name  
}

data "azurerm_virtual_network" "AVDvNet" {
  name                = "vnet-avd-001"
  resource_group_name = "rg-avd-network-001"
}

data "azurerm_subnet" "AVDSubnets" {
  name                  = "snet-avd-hostpool-001"
  virtual_network_name  = data.azurerm_virtual_network.AVDvNet.name
  resource_group_name   = data.azurerm_virtual_network.AVDvNet.resource_group_name  
}

data "azurerm_key_vault" "kv-cloudninja-vpn-002" {
  name                = "kv-cloudninja-vpn-002"
  resource_group_name = "rg-keyvault-001"
}

data "azurerm_key_vault_secret" "PublicIP" {
  name         = "PublicIP"
  key_vault_id = data.azurerm_key_vault.kv-cloudninja-vpn-002.id
}

resource "azurerm_storage_account_network_rules" "NetworkRules" {
  storage_account_id = azurerm_storage_account.FSLogixStorageAccount.id

  default_action             = "Deny"
  virtual_network_subnet_ids = [data.azurerm_subnet.SharedServicesSubnets.id,data.azurerm_subnet.AVDSubnets.id]
  bypass                     = ["AzureServices"]
  ip_rules                   = [ data.azurerm_key_vault_secret.PublicIP.value ]
}

resource "azurerm_storage_share" "AVDProfileShare" {
  name                 = "avdprofiles"
  storage_account_name = azurerm_storage_account.FSLogixStorageAccount.name
  quota                = 100  

}

data "azuread_client_config" "AzureAD" {}

data "azuread_group" "AVDGroup" {
  display_name     = "ACC_AVD_Users"  
}

resource "azurerm_role_assignment" "RBACStorageAccount" {
  scope                = azurerm_storage_account.FSLogixStorageAccount.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = data.azuread_group.AVDGroup.object_id
}

