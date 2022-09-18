terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.7.0"
    }
  }
  backend "azurerm" {
    resource_group_name     = "rg-terraform-state-001"
    storage_account_name    = "cloudninjatfstate"
    container_name          = "tfstate"
    key                     = "GitHub-Terraform-rg-connectivity-001"
    use_oidc                = true
    subscription_id         = "dad8b126-305d-4950-bdcf-fc18f996dd94"
  }
}
provider "azurerm" {
  alias           = "connectivity"
  use_oidc        = true
  features {}
}
provider "azurerm" {
  alias           = "management"  
  subscription_id = "dad8b126-305d-4950-bdcf-fc18f996dd94"
  use_oidc        = true
  features {}
}

provider "azurerm" {

  features {}
}