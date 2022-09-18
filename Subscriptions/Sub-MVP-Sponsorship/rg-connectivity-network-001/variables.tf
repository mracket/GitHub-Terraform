variable "Location" {
    type        = string
    default     = "WestEurope"  
}

variable "ResourceGroup" {
    type        = string
    default     = "rg-connectivity-network-001"   
}

variable "vnet" {
  type = any
  default = {
    "vNetName"                      = "vnet-connectivity-001"
    "address_space"                 = ["172.16.0.0/16"]
  }  
}
variable "Subnets" {
    type = any
    default = {
        "GatewaySubnet" = {
            "name"      = "GatewaySubnet"
            "prefix"    = ["172.16.0.0/26"]
        }
        "FirewallSubnet" = {
            "name" = "AzureFirewallSubnet"
            "prefix" = ["172.16.0.64/26"]
        }
         "AzureFirewallManagementSubnet" = {
            "name" = "AzureFirewallManagementSubnet"
            "prefix" = ["172.16.1.128/26"]
        }
        "PrivateDNS" = {
            "name" = "snet-private-dns-resolver-001"
            "prefix" = ["172.16.1.192/29"]
        }
    }
}

variable "LocalGateway" {
  type = map
  default = {
    "subnet1"                         = "192.168.1.0/24"
    "subnet2"                         = "192.168.10.0/24"    
  }  
}

variable "RemotevNet" {
  default = {
    "connectionname"    = "Connectivity-To-AVD"
    "name"              = "vnet-avd-001"
    "resourcegroup"     = "rg-avd-network-001"    
  }  
}
variable "ADDS-RemotevNet" {
  default = {
    "connectionname"    = "Connectivity-To-ADDS"
    "name"              = "vnet-sharedservices-001"
    "resourcegroup"     = "rg-sharedservices-network-001"  
  }  
}

variable "Citrix-RemotevNet" {
  default = {
    "connectionname"    = "Connectivity-To-Citrix"
    "name"              = "vnet-citrix-001"
    "resourcegroup"     = "rg-citrix-network-001"  
  }  
}

variable "AzureFirewallName" {
  type = string
  default = "afw-connectivity-001"
}