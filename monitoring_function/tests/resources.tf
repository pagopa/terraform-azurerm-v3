resource "azurerm_resource_group" "rg_runner" {
  name     = local.rg_name
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = local.law_name
  location            = azurerm_resource_group.rg_runner.location
  resource_group_name = azurerm_resource_group.rg_runner.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

#tfsec:ignore:azure-keyvault-specify-network-acl
#tfsec:ignore:azure-keyvault-no-purge
resource "azurerm_key_vault" "key_vault" {
  resource_group_name           = azurerm_resource_group.rg_runner.name
  name                          = local.key_vault_name
  sku_name                      = "standard"
  location                      = azurerm_resource_group.rg_runner.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  soft_delete_retention_days    = 7

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.rg_runner.name
  name                = local.vnet_name
  location            = azurerm_resource_group.rg_runner.location
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg_runner.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/23"]
}

resource "azurerm_container_app_environment" "container_app_environment" {
  name                           = local.environment_name
  resource_group_name            = azurerm_resource_group.rg_runner.name
  location                       = azurerm_resource_group.rg_runner.location
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law.id
  infrastructure_subnet_id       = azurerm_subnet.subnet.id
  zone_redundancy_enabled        = false
  internal_load_balancer_enabled = true

  tags = var.tags
}

# module to use
module "monitoring_function" {

  source = "../"

  location            = var.location
  prefix              = "${local.product}-${var.location_short}"
  resource_group_name = azurerm_resource_group.synthetic_rg.name
  legacy              = var.legacy

  application_insight_name              = azurerm_application_insights.application_insights.name
  application_insight_rg_name           = azurerm_application_insights.application_insights.resource_group_name
  application_insights_action_group_ids = []

  docker_settings = {
    image_tag = "v1.7.0@sha256:08b88e12aa79b423a96a96274786b4d1ad5a2a4cf6c72fcd1a52b570ba034b18"
  }

  job_settings = {
    cron_scheduling              = "*/5 * * * *"
    container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
    http_client_timeout          = 30000
  }

  storage_account_settings = {
    private_endpoint_enabled  = var.use_private_endpoint
    replication_type          = var.storage_account_replication_type
    table_private_dns_zone_id = null
  }

  private_endpoint_subnet_id = var.use_private_endpoint ? azurerm_subnet.subnet.id : null

  tags = var.tags

  self_alert_configuration = {
    enabled = var.self_alert_enabled
  }
  monitoring_configuration_encoded = templatefile("${path.module}/monitoring_configuration.json.tpl", {
    env_name                   = var.env,
    env_short                  = var.env_short,
    api_dot_env_name           = var.env == "prod" ? "api" : "api.${var.env}"
    internal_api_domain_prefix = "weu${var.env}"
    internal_api_domain_suffix = var.env == "prod" ? "internal.platform.pagopa.it" : "internal.${var.env}.platform.pagopa.it"
  })

  alert_set_auto_mitigate = var.alert_set_auto_mitigate
}
