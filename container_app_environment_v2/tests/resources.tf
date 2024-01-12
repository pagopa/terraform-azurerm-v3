resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${random_id.unique.hex}"
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Free"
  retention_in_days   = 30
}

module "container_app_environment" {
  source = "../" # change me with module URI

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  name                       = "${var.prefix}-cae"
  internal_load_balancer     = false
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  tags = var.tags
}
