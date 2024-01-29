resource "azurerm_container_app_environment" "container_app_environment" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_workspace_id

  infrastructure_subnet_id       = var.subnet_id == null ? null : var.subnet_id
  zone_redundancy_enabled        = var.subnet_id == null ? null : var.zone_redundant
  internal_load_balancer_enabled = var.subnet_id == null ? null : var.internal_load_balancer

  tags = var.tags
}
