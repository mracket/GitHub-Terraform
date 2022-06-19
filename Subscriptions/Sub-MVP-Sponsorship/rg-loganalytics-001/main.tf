resource "azurerm_resource_group" "resourcegroups" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_log_analytics_workspace" "rg-loganalytics-001" {
  name                = var.LogAnalytics.Name
  location            = var.Location
  resource_group_name = var.ResourceGroup
  sku                 = var.LogAnalytics.SKU
  retention_in_days   = var.LogAnalytics.LogRentensionInDays
}