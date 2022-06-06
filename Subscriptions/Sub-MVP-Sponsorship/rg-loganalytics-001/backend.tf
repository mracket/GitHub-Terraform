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
    key                     = "GitHub-Terraform-rg-loganalytics-001"
  }
}
provider "azurerm" {
  features {}
}