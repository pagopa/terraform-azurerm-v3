data "azurerm_key_vault" "key_vault" {
  resource_group_name = var.key_vault.resource_group_name
  name                = var.key_vault.name
}

resource "azurerm_resource_group" "runner_rg" {
  name     = local.resource_group_name
  location = var.location

  tags = var.tags
}

resource "azurerm_subnet" "runner_subnet" {
  name                 = "${local.name}-github-runner-snet"
  resource_group_name  = var.network.rg_vnet
  virtual_network_name = var.network.vnet
  address_prefixes     = var.network.cidr_subnets
  service_endpoints    = []
}

resource "azapi_resource" "runner_environment" {
  type      = "Microsoft.App/managedEnvironments@2023-05-01"
  name      = "${local.name}-github-runner-cae"
  location  = azurerm_resource_group.runner_rg.location
  parent_id = azurerm_resource_group.runner_rg.id

  tags = var.tags

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.environment.customerId
          sharedKey  = var.environment.sharedKey
        }
      }
      zoneRedundant = true
      vnetConfiguration = {
        infrastructureSubnetId = azurerm_subnet.runner_subnet.id
        internal               = true
      }
    }
  })
}

resource "azapi_resource" "runner_job" {
  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "${local.name}-github-runner-job"
  location  = azurerm_resource_group.runner_rg.location
  parent_id = azurerm_resource_group.runner_rg.id

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      environmentId = azapi_resource.runner_environment.id
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
    "Get",
  ]
}
