variable "tags" {
  type        = map(any)
  description = "Identity tags"
}

variable "prefix" {
  type        = string
  description = "Project prefix"

  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}

variable "env_short" {
  type        = string
  description = "Short environment prefix"

  validation {
    condition = (
      length(var.env_short) <= 1
    )
    error_message = "Max length is 1 chars."
  }
}

variable "domain" {
  type        = string
  description = "App domain name"

  default = ""
}

variable "app_name" {
  type        = string
  description = "App name"

  default = ""
}

variable "identity_role" {
  type        = string
  description = "Identity role should be either ci or cd"

  validation {
    condition     = contains(["ci", "cd"], var.identity_role)
    error_message = "The identity_role value must be either 'ci' or 'cd'"
  }
}

variable "github" {
  type = object({
    org               = optional(string, "pagopa")
    repository        = string
    audience          = optional(list(string), ["api://AzureADTokenExchange"])
    issuer            = optional(string, "https://token.actions.githubusercontent.com")
    credentials_scope = optional(string, "environment")
    subject           = string
  })
  description = "GitHub Organization, repository name and scope permissions"

  validation {
    condition     = contains(["environment", "ref", "pull_request"], var.github.credentials_scope)
    error_message = "The credentials_scope value must be either 'environment', 'ref' or 'pull_request'"
  }

  validation {
    condition     = var.github.repository != null
    error_message = "The repository value cannot be null"
  }

  validation {
    condition     = var.github.subject != null
    error_message = "The subject value cannot be null"
  }
}

variable "ci_rbac_roles" {
  type = object({
    subscription    = set(string)
    resource_groups = map(list(string))
  })

  default = {
    subscription    = ["Reader"]
    resource_groups = {}
  }
}

variable "cd_rbac_roles" {
  type = object({
    subscription    = set(string)
    resource_groups = map(list(string))
  })

  default = {
    subscription    = ["Contributor"]
    resource_groups = {}
  }
}
