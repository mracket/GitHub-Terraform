data "azurerm_virtual_network" "RemotevNet" {
  name                      = var.RemotevNet.name
  resource_group_name       = var.RemotevNet.resourcegroup
  provider                  = azurerm.management
}

data "azurerm_virtual_network" "ADDS-RemotevNet" {
  name                      = var.ADDS-RemotevNet.name
  resource_group_name       = var.ADDS-RemotevNet.resourcegroup  
  provider                  = azurerm.management
}

data "azurerm_virtual_network" "Citrix-RemotevNet" {
  name                      = var.Citrix-RemotevNet.name
  resource_group_name       = var.Citrix-RemotevNet.resourcegroup  
  provider                  = azurerm.management
}

resource "azurerm_virtual_network_peering" "AVD-To-Connectivity" {
  name                      = "Connectivity-To-AVD"
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.RemotevNet.id
  allow_gateway_transit     = true  
}

resource "azurerm_virtual_network_peering" "ADDS-To-Connectivity" {
  name                      = "Connectivity-To-ADDS"
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.ADDS-RemotevNet.id
  allow_gateway_transit     = true  
}

resource "azurerm_virtual_network_peering" "Citrix-To-Connectivity" {
  name                      = "Connectivity-To-Citrix"
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.Citrix-RemotevNet.id
  allow_gateway_transit     = true  
}