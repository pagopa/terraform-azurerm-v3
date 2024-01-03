locals {
  name                = "${var.prefix}-${var.env_short}"
  resource_group_name = "${local.name}-github-runner-rg"

  rules = [for repo in var.app.repos :
    {
      name = "github-runner-${var.env_short}-${repo}"
      type = "github-runner"
      metadata = {
        owner                     = var.app.repo_owner
        runnerScope               = "repo"
        repos                     = "${repo}"
        targetWorkflowQueueLength = "1"
        labels                    = "github-runner-${var.env_short}-${repo}"
      }
      auth = [
        {
          secretRef        = "personal-access-token"
          triggerParameter = "personalAccessToken"
        }
      ]
    }
  ]

  containers = [for repo in var.app.repos :
    {
      env = [
        {
          name      = "GITHUB_PAT"
          secretRef = "personal-access-token"
        },
        {
          name  = "REPO_URL"
          value = "https://github.com/${var.app.repo_owner}/${repo}"
        },
        {
          name  = "REGISTRATION_TOKEN_API_URL"
          value = "https://api.github.com/repos/${var.app.repo_owner}/${repo}/actions/runners/registration-token"
        }
      ]
      image = var.app.image
      name  = "github-runner-${var.env_short}-${repo}"
      resources = {
        cpu    = var.vm_size.cpu
        memory = var.vm_size.memory
      }
    }
  ]
}
