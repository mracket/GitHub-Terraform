resource "azurerm_resource_group" "resourcegroup" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  name                     = "vdpool-cloudninja-001"
  friendly_name            = "Cloudninja host pool"
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "targetisaadjoined:i:1;audiocapturemode:i:1;audiomode:i:0"
  description              = "Shared desktop for office use"
  type                     = "Pooled"
  maximum_sessions_allowed = 10
  load_balancer_type       = "DepthFirst"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationkey" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = timeadd(timestamp(), "180m")
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "vdws-cloudninja-001"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  friendly_name = "Workspace for Cloudninja.nu"
  description   = "Workspace for Cloudninja.nu"
  depends_on = [azurerm_virtual_desktop_host_pool.hostpool]
}

resource "azurerm_virtual_desktop_application_group" "remoteapp" {
  name                = "vdag-cloudninja-remoteapp-001"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  type          = "RemoteApp"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hostpool.id
  friendly_name = "Remote App group for Cloudninja"
  description   = "Remote App group for Cloudninja"
}

resource "azurerm_virtual_desktop_application_group" "desktopapp" {
  name                = "vdag-cloudninja-desktop-001"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  default_desktop_display_name = "Desktop"

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hostpool.id
  friendly_name = "Desktop App group for Cloudninja"
  description   = "Desktop App group for Cloudninja"

}

resource "azurerm_virtual_desktop_workspace_application_group_association" "desktopapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktopapp.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "remoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.remoteapp.id
}

data "azuread_client_config" "AzureAD" {}

resource "azuread_group" "AVDGroup" {
  display_name     = "ACC-AVD-Users"
  owners           = [data.azuread_client_config.AzureAD.object_id]
  security_enabled = true
}
resource "azurerm_role_assignment" "AVDGroupDesktopAssignment" {
  scope                = azurerm_virtual_desktop_application_group.desktopapp.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.AVDGroup.object_id
}
resource "azurerm_role_assignment" "AVDGroupRemoteAppAssignment" {
  scope                = azurerm_virtual_desktop_application_group.remoteapp.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.AVDGroup.object_id
}
resource "azurerm_role_assignment" "RBACAssignment" {
  scope                = azurerm_resource_group.resourcegroup.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = azuread_group.AVDGroup.object_id
}