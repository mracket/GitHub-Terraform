variable "Location" {
    type                        = string
    default                     = "WestEurope"  
}

variable "ResourceGroup" {
    type                        = string
    default                     = "rg-loganalytics-001"   
}

variable "LogAnalytics" {
    type                        = any
    default                     = {
        "Name"                  = "log-sharedservices-001"
        "SKU"                   = "PerGB2018"
        "LogRentensionInDays"   = 30
    }   
}


