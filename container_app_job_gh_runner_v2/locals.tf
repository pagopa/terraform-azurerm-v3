locals {
  project = "${var.prefix}-${var.env_short}"

  rule = {
    name = "${local.project}-${var.job.name}-github-runner-rule"
    type = "github-runner"
    metadata = {
      owner                     = var.job.repo_owner
      runnerScope               = var.job.runner_scope
      repos                     = "${var.job.repo}"
      targetWorkflowQueueLength = var.job.target_workflow_queue_length
      github-runner             = var.job.github_runner
    }
    auth = [
      {
        secretRef        = "personal-access-token"
        triggerParameter = "personalAccessToken"
      }
    ]
  }

  container = {
    env = [
      {
        name  = "GITHUB_PAT"
        value = "personal-access-token"
      },
      {
        name  = "REPO_URL"
        value = "https://github.com/${var.job.repo_owner}/${var.job.repo}"
      },
      {
        name  = "REGISTRATION_TOKEN_API_URL"
        value = "https://api.github.com/repos/${var.job.repo_owner}/${var.job.repo}/actions/runners/registration-token"
      }
    ]
    image = var.container.image
    name  = "${local.project}-${var.job.name}-runner"
    resources = {
      cpu    = var.container.cpu
      memory = var.container.memory
    }
  }
}
