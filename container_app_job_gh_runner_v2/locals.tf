locals {
  project = "${var.prefix}-${var.env_short}"

  rule = {
    name = "${local.project}-${var.job.name}-github-runner-rule"
    type = "github-runner"
    metadata = {
      owner                     = var.job_meta.repo_owner
      runnerScope               = var.job_meta.runner_scope
      repos                     = "${var.job_meta.repo}"
      targetWorkflowQueueLength = var.job_meta.target_workflow_queue_length
      github-runner             = var.job_meta.github_runner
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
        value = "https://github.com/${var.job_meta.repo_owner}/${var.job_meta.repo}"
      },
      {
        name  = "REGISTRATION_TOKEN_API_URL"
        value = "https://api.github.com/repos/${var.job_meta.repo_owner}/${var.job_meta.repo}/actions/runners/registration-token"
      },
      {
        name = "LABELS"
        value = join(",", var.runner_labels)
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
