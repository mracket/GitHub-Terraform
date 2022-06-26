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