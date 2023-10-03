variable "location" {
  type        = string
  description = "Identity region"

  validation {
    condition     = length(var.location) > 3
    error_message = "Location must have at least of 3 chars"
  }
}

variable "tags" {
  type        = map(any)
  description = "Identity tags"
}

variable "project" {
  type    = string
  default = "Project name according to PagoPA conventions"

  validation {
    condition     = length(var.project) > 3
    error_message = "Project name must have at least of 3 chars"
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that must own the identity"
  default     = "identity-rg"

  validation {
    condition     = length(var.resource_group_name) > 3
    error_message = "Resource group name must have at least of 3 chars"
  }
}

variable "identity_role" {
  type        = string
  description = "Identity role should be either ci or cd. Necessary permissions will be given according to the scope of the identity"
  default     = "ci"

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

variable "ci_roles" {
  type        = list(string)
  description = "List of roles assigned to ci identity at subscription level"
  default = [
    "Reader",
    "Reader and Data Access",
    "Storage Blob Data Reader",
    "Storage File Data SMB Share Reader",
    "Storage Queue Data Reader",
    "Storage Table Data Reader",
    "PagoPA Export Deployments Template",
    "Key Vault Secrets User",
    "DocumentDB Account Contributor",
    "API Management Service Contributor"
  ]
}

variable "cd_roles" {
  type        = list(string)
  description = "List of roles assigned to cd identity at subscription level"
  default = [
    "Contributor",
    "Storage Account Contributor",
    "Storage Blob Data Contributor",
    "Storage File Data SMB Share Contributor",
    "Storage Queue Data Contributor",
    "Storage Table Data Contributor",
  ]
}
