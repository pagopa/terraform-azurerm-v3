locals {
  name                = "${var.prefix}-${var.env_short}"
  resource_group_name = "${local.name}-github-runner-rg"

  rules = [for container in var.app.containers :
    {
      name = "github-runner-${var.env_short}-${container.repo}"
      type = "github-runner"
      metadata = {
        owner                     = var.app.repo_owner
        runnerScope               = "repo"
        repos                     = "${container.repo}"
        targetWorkflowQueueLength = "1"
        labels                    = "github-runner-${var.env_short}-${container.repo}"
      }
      auth = [
        {
          secretRef        = "personal-access-token"
          triggerParameter = "personalAccessToken"
        }
      ]
    }
  ]

  containers = [for container in var.app.containers :
    {
      env = [
        {
          name      = "GITHUB_PAT"
          secretRef = "personal-access-token"
        },
        {
          name  = "REPO_URL"
          value = "https://github.com/${var.app.repo_owner}/${container.repo}"
        },
        {
          name  = "REGISTRATION_TOKEN_API_URL"
          value = "https://api.github.com/repos/${var.app.repo_owner}/${container.repo}/actions/runners/registration-token"
        }
      ]
      image = var.app.image
      name  = "github-runner-${var.env_short}-${container.repo}"
      resources = {
        cpu    = container.cpu
        memory = container.memory
      }
    }
  ]
}
