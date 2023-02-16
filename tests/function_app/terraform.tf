#
# APP CONFIGURATION
#

resource "azurerm_application_insights" "example" {
  name                = "tf-test-appinsights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

locals {
  function_app = {
    app_settings_common = {
      FUNCTIONS_WORKER_RUNTIME       = "python"
      WEBSITE_RUN_FROM_PACKAGE       = "1"
      WEBSITE_VNET_ROUTE_ALL         = "1"
      WEBSITE_DNS_SERVER             = "168.63.129.16"
      FUNCTIONS_WORKER_PROCESS_COUNT = 1
    }
    app_settings_1 = {
    }
    app_settings_2 = {
    }
  }

  func_python = {
    app_settings_common = local.function_app.app_settings_common
    app_settings_1 = {
    }
    app_settings_2 = {
    }
  }
}

# #tfsec:ignore:azure-storage-queue-services-logging-enabled:exp:2022-05-01 # already ignored, maybe a bug in tfsec
module "func_python" {
  source = "../../function_app"

  # count = var.function_python_diego_enabled ? 1 : 0

  resource_group_name = var.resource_group_name
  name                = "${var.project}-fn-py"
  location            = var.location
  health_check_path   = "/api/v1/info"

  os_type          = "linux"
  linux_fx_version = "python|3.9"
  runtime_version  = "~4"

  always_on                                = true
  application_insights_instrumentation_key = azurerm_application_insights.example.instrumentation_key

  app_service_plan_id = true

  app_settings = merge(
    local.func_python.app_settings_common, {}
  )

  subnet_id = azurerm_subnet.example.id

  allowed_subnets = [
    azurerm_subnet.example.id,
  ]

  tags = var.tags
}