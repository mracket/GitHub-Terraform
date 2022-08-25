variable "Location" {
    type                = string
    default             = "WestEurope"  
}
variable "avd_Location" {
    type                = string
    default             = "NorwayEast"  
}

variable "ResourceGroup" {
    type                = string
    default             = "rg-avd-cloudninja-001"   
}

variable "FSLogixStorageAccount" {
    type                = string
    default             = "cloudninjafsl11072022"   
}

variable "NumberOfSessionHosts" {
    type = number
    default = 2
}

variable "vm_prefix" {
    type = string
    default = "avd-h1"
}

variable "avd_vnet" {
    type = string
    default = "vnet-avd-001"
}
variable "avd_vnet_resource_group" {
    type = string
    default = "rg-avd-network-001"
}
variable "avd_hostpool_subnet" {
    type = string
    default = "snet-avd-hostpool-001"
}
variable "avd_agent_location" {
    type = string 
    default = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_06-15-2022.zip"    
}
