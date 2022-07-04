variable "Location" {
    type                = string
    default             = "WestEurope"  
}

variable "ResourceGroup" {
    type                = string
    default             = "rg-avd-network-001"   
}

variable "vnet" {
  type = any
  default = {
    "vNetName"          = "vnet-avd-001"
    "address_space"     = ["172.17.0.0/16"]
  }  
}
variable "Subnets" {
    type = any
    default = {
        "snet-avd-services-001" = {
            "name"      = "snet-avd-services-001"
            "prefix"    = ["172.17.0.0/26"]
        }
        "snet-avd-hostpool-001" = {
            "name"      = "snet-avd-hostpool-001"
            "prefix"    = ["172.17.0.64/26"]
        }
    }
}

variable "RemotevNet" {
  default = {
    "connectionname"    = "AVD-To-Connectivity"
    "name"              = "vnet-connectivity-001"
    "resourcegroup"     = "rg-connectivity-network-001"    
  }  
}
