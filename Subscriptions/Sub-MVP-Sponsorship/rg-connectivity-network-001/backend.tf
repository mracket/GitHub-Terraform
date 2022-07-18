terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name     = "rg-terraform-state-001"
    storage_account_name    = "cloudninjaterraformstate"
    container_name          = "tfstate"
    key                     = "GitHub-Terraform-rg-connectivity-001"
  }
}
provider "azurerm" {
  alias = "Sub-MVP-Sponsorship"
  subscription_id = "1d647cfc-6103-4dde-af5e-4a103660defe"
  features {}
}
provider "azurerm" {
  alias = "Sub-MVP-Sponsorship-Credits"
  subscription_id = "dad8b126-305d-4950-bdcf-fc18f996dd94"
  features {}
}