terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name     = "rg-terraform-state-001"
    storage_account_name    = "cloudninjatfstate"
    container_name          = "tfstate"
    key                     = "GitHub-Terraform-rg-avd-network-001"
  }
}
provider "azurerm" {
  features {}
}