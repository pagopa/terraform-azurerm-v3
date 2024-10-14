
resource "azurerm_container_app_job" "container_app_job" {
  container_app_environment_id = data.azurerm_container_app_environment.container_app_environment.id
  name                         = "${local.project}-${var.job.name}-ca-job"
  location                     = data.azurerm_container_app_environment.container_app_environment.location
  resource_group_name          = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  replica_timeout_in_seconds = var.replica_timeout_in_seconds
  replica_retry_limit        = var.replica_retry_limit

  event_trigger_config {
    parallelism              = var.parallelism
    replica_completion_count = var.replica_completion_count
    scale {
      max_executions              = var.job.scale_max_executions
      min_executions              = var.job.scale_min_executions
      polling_interval_in_seconds = var.polling_interval_in_seconds
      rules {
        custom_rule_type = local.rule.type
        metadata         = local.rule.metadata
        name             = local.rule.name
        authentication {
          secret_name       = local.rule.auth.0.secretRef
          trigger_parameter = local.rule.auth.0.triggerParameter
        }
      }
    }
  }

  secret {
    # no versioning
    key_vault_secret_id = data.azurerm_key_vault_secret.github_pat.id

    identity = "System"
    name     = "personal-access-token"
  }

  template {
    container {
      cpu    = local.container.resources.cpu
      image  = local.container.image
      memory = local.container.resources.memory
      name   = local.container.name

      dynamic "env" {
        for_each = local.container.env
        content {
          name  = env.value["name"]
          value = env.value["value"]
        }
      }
    }
  }

  # Prevent false plan changes on secret part
  lifecycle {
    ignore_changes = [secret]
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "keyvault_containerapp" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_container_app_job.container_app_job.identity[0].tenant_id
  object_id    = azurerm_container_app_job.container_app_job.identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
}
