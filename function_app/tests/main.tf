#
# APP CONFIGURATION
#

resource "random_id" "function_id" {
  byte_length = 4
}

resource "azurerm_application_insights" "example" {
  name                = "${var.project}-${random_id.function_id.hex}-appinsights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.project}-${random_id.function_id.hex}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.project}-${random_id.function_id.hex}-vn"
  address_space       = var.address_space
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "${var.project}-${random_id.function_id.hex}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.address_prefixes

  delegation {
    name = "${var.project}-${random_id.function_id.hex}-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

locals {
  function_app = {
    app_settings_common = {
      WEBSITE_RUN_FROM_PACKAGE       = "1"
      WEBSITE_DNS_SERVER             = "168.63.129.16"
      FUNCTIONS_WORKER_PROCESS_COUNT = 4
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

  resource_group_name = azurerm_resource_group.example.name
  name                = "${var.project}-${random_id.function_id.hex}-fn-py"
  location            = var.location
  health_check_path   = "/api/v1/info"
  python_version      = "3.9"
  runtime_version     = "~4"

  always_on                                = true
  application_insights_instrumentation_key = azurerm_application_insights.example.instrumentation_key

  app_settings = merge(
    local.func_python.app_settings_common, {}
  )

  subnet_id = azurerm_subnet.example.id

  allowed_subnets = [
    azurerm_subnet.example.id,
  ]

  tags = merge(var.tags, 
              {Name = "${var.project}-${random_id.function_id.hex}_function_app"})
}