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
resource "azurerm_public_ip" "public-ip-AzureFirewall" {
  name                = "pip-${var.AzureFirewallName}"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "AzureFirewall" {
  name                = var.AzureFirewallName
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnets["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.public-ip-AzureFirewall.id
  }
}