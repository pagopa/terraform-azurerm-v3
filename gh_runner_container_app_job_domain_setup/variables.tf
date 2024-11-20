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
    repo_owner                   = optional(string, "pagopa")
    runner_scope                 = optional(string, "repo")
    target_workflow_queue_length = optional(string, "1")
    github_runner                = optional(string, "https://api.github.com")
  })

  description = "Scaling rules metadata."
  default = {
    repo_owner                   = "pagopa"
    runner_scope                 = "repo"
    target_workflow_queue_length = "1"
    github_runner                = "https://api.github.com"
  }
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

variable "key_vault" {
  type = object({
    name        = string # Name of the KeyVault which stores PAT as secret
    rg          = string # Resource group of the KeyVault which stores PAT as secret
    secret_name = string # Data of the KeyVault which stores PAT as secret
  })
}


variable "runner_labels" {
  type        = list(string)
  description = "Labels that allow a GH action to call a specific runner"
  default     = []
}


variable "gh_repositories" {
  type = list(object({
    name       = string
    short_name = string
  }))
  description = "(Required) List of gh repository names and short names on which the managed identity will have permission. Max 20 repos. All repos must belong to the same organization, check `job_meta` variable"
  validation {
    condition     = length(var.gh_repositories) <= 20
    error_message = "Cannot configure more than 20 gh_repositories federations. Split the list and duplicate this module call to solve the issue. Use the variable "
  }

  validation {
    condition     = length(var.gh_repositories) > 0
    error_message = "You need to configure at leas one repository"
  }

  validation {
    condition = alltrue([
      for r in var.gh_repositories : (length(r.short_name) <= 15)
    ])
    error_message = "gh_repository short name must be less than 15 characters"
  }
}

variable "gh_identity_suffix" {
  type        = string
  description = "(Optional) Suffix used in the gh identity name. Necessary to distinguish the identities when more than 20 repos are used"
  default     = "01"
}

variable "kubernetes_deploy" {
  type = object({
    enabled      = optional(bool, false)
    namespaces    = optional(list(string), [])
    cluster_name = optional(string, "")
    rg           = optional(string, "")
  })

  description = "(Optional) Enables and specifies the kubernetes deply permissions"

  default = {
    enabled      = false
    namespaces    = []
    cluster_name = ""
    rg           = ""
  }

  validation {
    condition     = var.kubernetes_deploy.enabled ? length(var.kubernetes_deploy.namespaces) > 0 : true
    error_message = "Kubernetes namespaces not defined"
  }
  validation {
    condition     = var.kubernetes_deploy.enabled ? length(var.kubernetes_deploy.cluster_name) > 0 : true
    error_message = "Kubernetes cluster name not defined"
  }
  validation {
    condition     = var.kubernetes_deploy.enabled ? length(var.kubernetes_deploy.rg) > 0 : true
    error_message = "Kubernetes cluster rg name not defined"
  }
}


variable "function_deploy" {
  type = object({
    enabled = optional(bool, false)
  })
  description = "(Optional) Enables and specifies the function app deploy permissions"
  default = {
    enabled = false
  }
}

variable "custom_rg_permissions" {
  type = list(object({
    rg_name     = string       #name of the resource group on which the permissions are given
    permissions = list(string) # list of permission assigned on with rg_name scope
  }))
  description = "(Optional) List of resource group permission assigned to the job identity"
  default     = []

 validation {
    condition = alltrue([
      for p in var.custom_rg_permissions : (length(p.rg_name) > 0)
    ])
    error_message = "rg_name cannot be empty"
  }

  validation {
    condition = alltrue([
      for p in var.custom_rg_permissions : (length(p.permissions) > 0)
    ])
    error_message = "permissions cannot be empty"
  }

}


variable "domain_name" {
  type        = string
  description = "(Required) Domain name for the configured repositories"
}
