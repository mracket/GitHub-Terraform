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
    key                     = "GitHub-Terraform-rg-connectivity-001"
    subscription_id         = "6ef183f0-e0e1-40a7-8bb3-10e7b50b7d3b"
  }
}
provider "azurerm" {
  features {}
}