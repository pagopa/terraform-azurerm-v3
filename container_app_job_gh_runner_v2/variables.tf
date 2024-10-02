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

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
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

variable "environment_name" {
  type        = string
  description = "(Required) Container App Environment configuration (Log Analytics Workspace)"
}

variable "environment_rg" {
  type        = string
  description = "(Required) Container App Environment configuration (Log Analytics Workspace)"
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

variable "job" {
  type = object({
    name                 = string
    scale_max_executions = optional(number, 5)
    scale_min_executions = optional(number, 0)
  })

  description = "Container App job configuration"
}

variable "job_meta" {
  type = object({
    repo                         = string
    repo_owner                   = optional(string, "pagopa")
    runner_scope                 = optional(string, "repo")
    target_workflow_queue_length = optional(string, "1")
    github_runner                = optional(string, "https://api.github.com") #
  })

  description = "Scaling rules metadata."
}

variable "parallelism" {
  type        = number
  default     = 1
  description = "(Optional) Number of parallel replicas of a job that can run at a given time."
}

variable "replica_completion_count" {
  type        = number
  default     = 1
  description = "(Optional) Minimum number of successful replica completions before overall job completion."
}

variable "polling_interval_in_seconds" {
  type        = number
  default     = 30
  description = "(Optional) Interval to check each event source in seconds."
}

variable "replica_timeout_in_seconds" {
  type        = number
  default     = 1800
  description = "(Required) The maximum number of seconds a replica is allowed to run."
}

variable "replica_retry_limit" {
  type        = number
  default     = 1
  description = "(Optional) The maximum number of times a replica is allowed to retry."
}

variable "key_vault_name" {
  type        = string
  description = "Name of the KeyVault which stores PAT as secret"
}

variable "key_vault_rg" {
  type        = string
  description = "Resource group of the KeyVault which stores PAT as secret"
}

variable "key_vault_secret_name" {
  type        = string
  description = "Data of the KeyVault which stores PAT as secret"
}
