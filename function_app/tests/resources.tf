resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "${local.project}-ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = var.tags
}

resource "azurerm_subnet" "function_app_subnet" {
  name                 = "${local.project}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.function_app_subnet_cidr

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

locals {
  function_app = {
    app_settings_common = {
      FUNCTIONS_WORKER_PROCESS_COUNT = 4
    }
    app_settings_1 = {
    }
    app_settings_2 = {
    }
  }
}

module "function_app" {
  source = "../../function_app"

  name                = "${local.project}-fn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  health_check_path   = "/api/v1/info"
  python_version      = "3.9"
  runtime_version     = "~4"

  always_on                                = true
  application_insights_instrumentation_key = azurerm_application_insights.ai.instrumentation_key

  app_settings = merge(
    local.function_app.app_settings_common, {}
  )

  subnet_id = azurerm_subnet.function_app_subnet.id

  allowed_subnets = [
    azurerm_subnet.function_app_subnet.id,
  ]

  ip_restriction_default_action = "Deny"

  app_service_plan_info = {
    kind     = "Linux"
    sku_size = "P1v3"
    # The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU.
    maximum_elastic_worker_count = 0
    # The number of Workers (instances) to be allocated.
    worker_count = 2
    # Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.
    zone_balancing_enabled = true
  }

  tags = var.tags
}
