data "azurerm_virtual_network" "RemotevNet" {
  name                = var.RemotevNet.name
  resource_group_name = var.RemotevNet.resourcegroup
}

resource "azurerm_virtual_network_peering" "AVD-To-Connectivity" {
  name                      = var.RemotevNet.connectionname
  resource_group_name       = azurerm_resource_group.resourcegroup.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.RemotevNet.id
}
