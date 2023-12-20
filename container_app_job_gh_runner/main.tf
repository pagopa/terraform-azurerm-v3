data "azurerm_resource_group" "runner_rg" {
  name = local.resource_group_name
}

data "azurerm_key_vault" "key_vault" {
  resource_group_name = var.key_vault.resource_group_name
  name                = var.key_vault.name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = var.environment.law_name
  resource_group_name = var.environment.law_resource_group_name
}

resource "azurerm_subnet" "runner_subnet" {
  name                 = var.network.subnet_name == "" ? "${local.name}-github-runner-snet" : var.network.subnet_name
  resource_group_name  = var.network.vnet_resource_group_name
  virtual_network_name = var.network.vnet_name
  address_prefixes     = ["${var.network.subnet_cidr_block}"]
  service_endpoints    = []
}

# resource "azapi_resource" "runner_environment" {
#   type      = "Microsoft.App/managedEnvironments@2023-05-01"
#   name      = "${local.name}-github-runner-cae"
#   location  = data.azurerm_resource_group.runner_rg.location
#   parent_id = data.azurerm_resource_group.runner_rg.id

#   tags = var.tags

#   body = jsonencode({
#     properties = {
#       appLogsConfiguration = {
#         destination = "log-analytics"
#         logAnalyticsConfiguration = {
#           customerId = var.environment.customerId
#           sharedKey  = var.environment.sharedKey
#         }
#       }
#       zoneRedundant = true
#       vnetConfiguration = {
#         infrastructureSubnetId = azurerm_subnet.runner_subnet.id
#         internal               = true
#       }
#     }
#   })
# }

resource "azurerm_container_app_environment" "container_app_environment" {
  name                = "${local.name}-github-runner-cae"
  location            = data.azurerm_resource_group.runner_rg.location
  resource_group_name = data.azurerm_resource_group.runner_rg.name

  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id

  infrastructure_subnet_id       = azurerm_subnet.runner_subnet.id
  internal_load_balancer_enabled = true

  tags = var.tags
}

resource "azapi_resource" "runner_job" {
  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "${local.name}-github-runner-job"
  location  = data.azurerm_resource_group.runner_rg.location
  parent_id = data.azurerm_resource_group.runner_rg.id

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      environmentId = azurerm_container_app_environment.container_app_environment.id
      configuration = {
        replicaRetryLimit = 1
        replicaTimeout    = 1800
        eventTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
          scale = {
            maxExecutions   = 10
            minExecutions   = 0
            pollingInterval = 20
            rules           = local.rules
          }
        }
        secrets = [{
          keyVaultUrl = "${data.azurerm_key_vault.key_vault.vault_uri}secrets/${var.key_vault.secret_name}" # no versioning
          identity    = "system"
          name        = "personal-access-token"
        }]
        triggerType = "Event"
      }
      template = {
        containers = local.containers
      }
    }
  })
}

resource "azurerm_key_vault_access_policy" "keyvault_containerapp" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = azapi_resource.runner_job.identity[0].tenant_id
  object_id    = azapi_resource.runner_job.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}
