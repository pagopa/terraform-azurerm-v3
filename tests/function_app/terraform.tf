#
# APP CONFIGURATION
#

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

  count = var.function_python_diego_enabled ? 1 : 0

  resource_group_name = azurerm_resource_group.funcs_diego_rg.name
  name                = "${local.project}-fn-py"
  location            = var.location
  health_check_path   = "/api/v1/info"

  os_type          = "linux"
  linux_fx_version = "python|3.9"
  runtime_version  = "~4"

  always_on                                = true
  application_insights_instrumentation_key = data.azurerm_application_insights.application_insights.instrumentation_key

  app_service_plan_id = azurerm_app_service_plan.funcs_diego[0].id

  app_settings = merge(
    local.func_python.app_settings_common, {}
  )

  subnet_id = module.funcs_diego_snet.id

  allowed_subnets = [
    module.funcs_diego_snet.id,
  ]

  tags = var.tags
}

module "func_python_staging_slot" {
  source = "../../function_app"

  count = var.function_python_diego_enabled ? 1 : 0

  name                = "staging"
  location            = var.location
  resource_group_name = azurerm_resource_group.funcs_diego_rg.name
  function_app_name   = module.func_python[0].name
  function_app_id     = module.func_python[0].id
  app_service_plan_id = module.func_python[0].app_service_plan_id
  health_check_path   = "/api/v1/info"

  storage_account_name       = module.func_python[0].storage_account.name
  storage_account_access_key = module.func_python[0].storage_account.primary_access_key

  os_type                                  = "linux"
  linux_fx_version                         = "python|3.9"
  always_on                                = "true"
  runtime_version                          = "~4"
  application_insights_instrumentation_key = data.azurerm_application_insights.application_insights.instrumentation_key

  app_settings = merge(
    local.func_python.app_settings_common, {}
  )

  subnet_id = module.funcs_diego_snet.id

  allowed_subnets = [
    module.funcs_diego_snet.id,
  ]

  tags = var.tags
}
