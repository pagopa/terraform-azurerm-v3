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

variable "environment" {
  type = object({
    name                = string
    resource_group_name = string
  })

  description = "Container App Environment configuration (Log Analytics Workspace)"
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
    image  = "ghcr.io/pagopa/github-self-hosted-runner-azure:beta-dockerfile-v2@sha256:a4ddc89b5a65c367442b024c4ac0edbfdcb363a731727b88853b3df0dcd2a711"
  }

  description = "Job Container configuration"
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

variable "key_vault" {
  type = object({
    resource_group_name = string
    name                = string
    secret_name         = string
  })

  description = "Data of the KeyVault which stores PAT as secret"
}
