resource "azurerm_resource_group" "resourcegroup" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.vNetName
  address_space       = var.vnet.address_space
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  
}

resource "azurerm_subnet" "subnets" {
  for_each = var.Subnets
  name                 = each.value["name"]
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value["prefix"]
  
  depends_on = [
    azurerm_virtual_network.vnet
  ] 
}