resource "azapi_resource" "container_app_job" {
  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "${local.project}-${var.job.name}-ca-job"
  location  = data.azurerm_container_app_environment.container_app_environment.location
  parent_id = data.azurerm_resource_group.rg_runner.id

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      environmentId = data.azurerm_container_app_environment.container_app_environment.id
      configuration = {
        replicaRetryLimit = 1
        replicaTimeout    = 1800
        eventTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
          scale = {
            maxExecutions   = var.job.scale_max_executions
            minExecutions   = 0
            pollingInterval = var.job.polling_interval
            rules           = [local.rule]
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
        containers = [local.container]
      }
    }
  })
}

resource "azurerm_key_vault_access_policy" "keyvault_containerapp" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = azapi_resource.container_app_job.identity[0].tenant_id
  object_id    = azapi_resource.container_app_job.identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
}
