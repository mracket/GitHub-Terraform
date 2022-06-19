resource "azurerm_resource_group" "resourcegroup" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.vNetName
  address_space       = var.vnet.address_space
  location            = var.Location
  resource_group_name = var.ResourceGroup

  depends_on = [
    azurerm_resource_group.resourcegroup
  ]
}

resource "azurerm_subnet" "subnets" {
  for_each = var.Subnets
  name                 = each.value["name"]
  resource_group_name  = var.ResourceGroup
  virtual_network_name = var.vnet.vNetName
  address_prefixes     = each.value["prefix"]
  
  depends_on = [
    azurerm_virtual_network.vnet
  ] 
}

resource "azurerm_public_ip" "VPN-PublicIP" {
  name                = "pip-vgw-connectivity-001"
  location            = var.Location
  resource_group_name = var.ResourceGroup

  allocation_method = "Dynamic"
  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_virtual_network_gateway" "VPN-Gateway" {
  name                = "vgw-connectivity-001"
  location            = var.Location
  resource_group_name = var.ResourceGroup

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
  depends_on = [azurerm_public_ip.VPN-PublicIP]
}

resource "azurerm_local_network_gateway" "LocalGateway" {
  name                = "lgw-onpremises-001"
  location            = var.Location
  resource_group_name = var.ResourceGroup
  gateway_address     = var.LocalGateway.gateway_address
  address_space       = [var.LocalGateway.subnet2,var.LocalGateway.subnet1]

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_virtual_network_gateway_connection" "VPN-Connection" {
  name                = "vcn-onpremises-001"
  location            = var.Location
  resource_group_name = var.ResourceGroup

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VPN-Gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.LocalGateway.id

  shared_key = var.pre-shared-key

  depends_on = [azurerm_virtual_network_gateway.VPN-Gateway, azurerm_local_network_gateway.LocalGateway]
}