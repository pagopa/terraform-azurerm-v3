resource "azurerm_container_app_job" "job" {
  name                         = "${var.job_name_prefix}-${var.job.name}-ca-job"
  location                     = data.azurerm_container_app_environment.container_app_environment.location
  resource_group_name          = data.azurerm_resource_group.rg_runner.name
  container_app_environment_id = data.azurerm_container_app_environment.container_app_environment.id

  replica_timeout_in_seconds = 1800
  replica_retry_limit        = 1

  event_trigger_config {
    parallelism            = 1
    replica_completion_count  = 1
    scale {
      max_executions    = var.job.scale_max_executions
      min_executions    = 1
      polling_interval_in_seconds = var.job.polling_interval
      rules           {
        name = "${local.project}-${var.job.name}-github-runner-rule"
        custom_rule_type  = "github-runner"
        metadata = {
          owner                     = var.job.repo_owner
          runnerScope               = "repo"
          repos                     = var.job.repo
          targetWorkflowQueueLength = "1"
          github-runner             = "https://api.github.com"
        }
#         authentication  = [
#           {
#             secret_name         = "personal-access-token"
#             trigger_parameter = "personalAccessToken"
#           }
#         ]
      }
    }
  }

  template {
    container {
      image = var.container.image
      name  = "${local.project}-${var.job.name}-runner"

      cpu    = var.container.cpu
      memory = var.container.memory
      dynamic "env" {
        for_each = local.container.env
        content {
          name = env.value.name
          value = env.value.value
        }
      }

    }
  }

  identity {
    type = "SystemAssigned"
  }
}
