# Azure function app

Module that allows the creation of an Azure function app.

## Architecture

![architecture](./docs/module-arch.drawio.png)

## How to use it
The following Terraform template `terraform-azurerm-v3/tree/azurerm_linux_function_app_migration/tests/function_app` has been created to test this module and reported below.
```ts
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
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "example-virtual-network"
  address_space       = var.address_space
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.address_prefixes

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
      # FUNCTIONS_WORKER_RUNTIME       = "python"
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

  resource_group_name = azurerm_resource_group.example.name
  name                = "${var.project}-fn-py"
  location            = var.location
  health_check_path   = "/api/v1/info"

  runtime_version  = "~4"

  always_on                                = true
  application_insights_instrumentation_key = azurerm_application_insights.example.instrumentation_key

  # app_service_plan_id = true

  app_settings = merge(
    local.func_python.app_settings_common, {}
  )

  subnet_id = azurerm_subnet.example.id

  allowed_subnets = [
    azurerm_subnet.example.id,
  ]

  tags = var.tags
}
```
## Migration from azurerm_function_app to azurerm_linux_function_app

Since the resource `azurerm_function_app` has been deprecated in version 3.0 of the AzureRM provider, the newer `azurerm_linux_function_app` resource is used in this module, thus the following variables have been removed since they are not used anymore:
- os_type
- app_service_plan_info/sku_tier
- linux_fx_version

## Migration from v2

Output for resource `azurerm_function_app_host_keys` changed

See [Generic resource migration](../.docs/MIGRATION_GUIDE_GENERIC_RESOURCES.md)

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
