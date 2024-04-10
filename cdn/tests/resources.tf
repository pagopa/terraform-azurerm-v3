locals {
  dns_zone_name = "${var.prefix}.pagopa.it"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "${local.project}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = "30"
  daily_quota_gb      = -1

  tags = var.tags
}

resource "azurerm_key_vault" "this" {
  name                = local.project
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  tags = var.tags
}

module "cdn" {
  source = "../../cdn"

  location                     = var.location
  dns_zone_name                = local.dns_zone_name
  dns_zone_resource_group_name = azurerm_resource_group.rg.name
  error_404_document           = "error_404.html"
  hostname                     = "test"
  index_document               = "index.html"
  keyvault_resource_group_name = azurerm_resource_group.rg.name
  keyvault_subscription_id     = data.azurerm_client_config.current.subscription_id
  keyvault_vault_name          = azurerm_key_vault.this.name
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.log_analytics_workspace.id
  name                         = "${var.prefix}${random_id.unique.hex}"
  prefix                       = var.prefix
  resource_group_name          = azurerm_resource_group.rg.name
  tags                         = var.tags
}

module "cdn_different_location" {
  source = "../../cdn"

  location                     = var.location
  cdn_location                 = var.location_cdn
  dns_zone_name                = local.dns_zone_name
  dns_zone_resource_group_name = azurerm_resource_group.rg.name
  error_404_document           = "error_404.html"
  hostname                     = "test"
  index_document               = "index.html"
  keyvault_resource_group_name = azurerm_resource_group.rg.name
  keyvault_subscription_id     = data.azurerm_client_config.current.subscription_id
  keyvault_vault_name          = azurerm_key_vault.this.name
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.log_analytics_workspace.id
  name                         = "${var.prefix}${random_id.unique.hex}"
  prefix                       = var.prefix
  resource_group_name          = azurerm_resource_group.rg.name
  tags                         = var.tags
}





