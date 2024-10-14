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

  tags = var.tags
}

module "function_app_slot" {
  source = "../../function_app_slot"

  name                       = "slot"
  function_app_id            = module.function_app.id
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  health_check_path          = "/api/v1/info"
  runtime_version            = "~4"
  storage_account_name       = module.function_app.storage_account.name
  storage_account_access_key = module.function_app.storage_account.primary_access_key

  ### OLD version variables
  # linux_fx_version           = "Python"
  # function_app_name          = module.function_app.name
  # app_service_plan_id        = module.function_app.app_service_plan_id

  ### NEW version variables
  python_version = "3.9"

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

  tags = var.tags
}
