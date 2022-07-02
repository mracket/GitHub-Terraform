data "azurerm_key_vault" "kv-cloudninja-vpn-001" {
  name                = "kv-cloudninja-vpn-001"
  resource_group_name = "rg-keyvault-001"
}

data "azurerm_key_vault_secret" "VPNSharedSecret" {
  name         = "VPNSharedSecret"
  key_vault_id = data.azurerm_key_vault.kv-cloudninja-vpn-001.id
}

data "azurerm_key_vault_secret" "PublicIP" {
  name         = "PublicIP"
  key_vault_id = data.azurerm_key_vault.kv-cloudninja-vpn-001.id
}

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

resource "azurerm_public_ip" "VPN-PublicIP" {
  name                = "pip-vgw-connectivity-001"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  allocation_method = "Dynamic"
  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_virtual_network_gateway" "VPN-Gateway" {
  name                = "vgw-connectivity-001"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vgw-config"
    public_ip_address_id          = azurerm_public_ip.VPN-PublicIP.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["GatewaySubnet"].id
  }
  timeouts {
    create = "120m"
  }
}

resource "azurerm_local_network_gateway" "LocalGateway" {
  name                = "lgw-onpremises-001"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  gateway_address     = data.azurerm_key_vault_secret.PublicIP.value
  address_space       = [var.LocalGateway.subnet2,var.LocalGateway.subnet1]
}

resource "azurerm_virtual_network_gateway_connection" "VPN-Connection" {
  name                = "vcn-onpremises-001"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VPN-Gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.LocalGateway.id

  shared_key = data.azurerm_key_vault_secret.VPNSharedSecret.value
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.Subnets
  subnet_id                 = azurerm_subnet.subnets[each.value["name"]].id
  network_security_group_id = azurerm_network_security_group.networksecuritygroups[each.value["name"]].id 
}
resource "azurerm_route_table" "routes" {
  name                          = "rt-${azurerm_virtual_network.vnet.name}"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  disable_bgp_route_propagation = true

  
  route {
    name                    = "udr-onprem-to-avd"
    address_prefix          = "172.17.0.0/16"
    next_hop_type           = "VirtualAppliance"
    next_hop_in_ip_address  = "172.16.0.68"
  }
}

data "azurerm_subnet" "subnets" {
  name = "GatewaySubnet"
  resource_group_name = azurerm_resource_group.resourcegroup.name
}
resource "azurerm_subnet_route_table_association" "routetableassociation" {
  subnet_id      = data.azurerm_subnet.subnets.id
  route_table_id = azurerm_route_table.routes.id
}