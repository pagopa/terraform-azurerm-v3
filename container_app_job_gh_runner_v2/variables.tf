locals {
  project = "${var.prefix}-${var.env_short}"

  container = {
    env = [
#       {
#         name      = "GITHUB_PAT"
#         secretRef = "personal-access-token"
#       },
      {
        name  = "REPO_URL"
        value = "https://github.com/${var.job.repo_owner}/${var.job.repo}"
      },
      {
        name  = "REGISTRATION_TOKEN_API_URL"
        value = "https://api.github.com/repos/${var.job.repo_owner}/${var.job.repo}/actions/runners/registration-token"
      }
    ]
  }
}

#
# Variables
#
variable "tags" {
  type        = map(any)
  description = "Tags for new resources"
  default = {
    CreatedBy = "Terraform"
  }
}

variable "location" {
  type        = string
  description = "Resource group and resources location"
}

variable "prefix" {
  type        = string
  description = "Project prefix"

  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars"
  }
}

variable "env_short" {
  type        = string
  description = "Short environment prefix"

  validation {
    condition = (
      length(var.env_short) == 1
    )
    error_message = "Length is 1 chars."
  }
}

variable "container_app_environment_name" {
  type = string
  description = "Container App Environment name"
}

variable "container_app_environment_rg_name" {
  type = string
  description = "Container App Environment rg name"
}

variable "container" {
  type = object({
    cpu    = number
    memory = string
    image  = string
  })

  default = {
    cpu    = 0.5
    memory = "1Gi"
    image  = "ghcr.io/pagopa/github-self-hosted-runner-azure:latest"
  }

  description = "Job Container configuration"
}

variable "job_name_prefix" {
  type = string
  description = "Job name prefix"
}

variable "job" {
  type = object({
    name                 = string
    repo_owner           = optional(string, "pagopa")
    repo                 = string
    polling_interval     = optional(number, 30)
    scale_max_executions = optional(number, 5)
  })

  description = "Container App job configuration"
}

# variable "key_vault" {
#   type = object({
#     resource_group_name = string
#     name                = string
#     secret_name         = string
#   })
#
#   description = "Data of the KeyVault which stores PAT as secret"
# }
