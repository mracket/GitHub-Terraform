resource "azurerm_resource_group" "resourcegroups" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_key_vault" "keyvault" {
  name                            = "kv-vpn-001"
  location                        = azurerm_resource_group.resourcegroups.location
  resource_group_name             = azurerm_resource_group.resourcegroups.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get","Get", "List"
    ]

    secret_permissions = [
      "Get","Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore","Set"
    ]

    storage_permissions = [
      "Get","Get", "List"
    ]
  }
}