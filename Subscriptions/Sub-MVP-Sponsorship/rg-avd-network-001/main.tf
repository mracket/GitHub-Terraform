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
  service_endpoints    = [ "Microsoft.Storage" ]
  depends_on = [
    azurerm_virtual_network.vnet
  ] 
}

resource "azurerm_network_security_group" "networksecuritygroups" {
  for_each = var.Subnets
  name                = "nsg-${each.value["name"]}"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name  
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.Subnets
  subnet_id                 = azurerm_subnet.subnets[each.value["name"]].id
  network_security_group_id = azurerm_network_security_group.networksecuritygroups[each.value["name"]].id 
  depends_on = [
    azurerm_subnet.subnets
  ]
}
resource "azurerm_route_table" "routes" {
  name                          = "rt-${azurerm_virtual_network.vnet.name}"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  disable_bgp_route_propagation = true

  route {
    name           = "udr-azure-kms"
    address_prefix = "23.102.135.246/32"
    next_hop_type  = "Internet"
  }
  route {
    name                    = "udr-internet"
    address_prefix          = "0.0.0.0/0"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = "172.16.0.68"
  }
  route {
    name                    = "udr-vpn-001"
    address_prefix          = "192.168.1.0/24"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = "172.16.0.68"
  }
  route {
    name                    = "udr-vpn-002"
    address_prefix          = "192.168.10.0/24"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = "172.16.0.68"
  }
}
resource "azurerm_subnet_route_table_association" "routetableassociation" {
  for_each = var.Subnets
  subnet_id      = azurerm_subnet.subnets[each.value["name"]].id
  route_table_id = azurerm_route_table.routes.id
  depends_on = [
    azurerm_subnet.subnets
  ]
}