resource "azurerm_resource_group" "resourcegroups" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_log_analytics_workspace" "rg-loganalytics-001" {
  name                = var.LogAnalytics.Name
  location            = azurerm_resource_group.resourcegroups.location
  resource_group_name = azurerm_resource_group.resourcegroups.name
  sku                 = var.LogAnalytics.SKU
  retention_in_days   = var.LogAnalytics.LogRentensionInDays  
}