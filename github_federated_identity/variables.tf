variable "tags" {
  type        = map(any)
  description = "Identity tags"
}

variable "prefix" {
  type        = string
  description = "Project prefix"

  validation {
    condition = (
      length(var.prefix) <= 12
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
  description = "Application name"

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

variable "github_federations" {
  type = list(object({
    org               = optional(string, "pagopa")
    repository        = string
    audience          = optional(set(string), ["api://AzureADTokenExchange"])
    issuer            = optional(string, "https://token.actions.githubusercontent.com")
    credentials_scope = optional(string, "environment")
    subject           = string
  }))
  description = "GitHub Organization, repository name and scope permissions"

  validation {
    condition = alltrue([
      for g in var.github_federations : contains(["environment", "ref", "pull_request"], g.credentials_scope)
    ])
    error_message = "The credentials_scope value must be either 'environment', 'ref' or 'pull_request'"
  }
}

#
# ci_rbac_roles = {
#   subscription = ["role1", "role2"]
#   resource_groups = {
#     "rg1" = [
#       "role1",
#       "role2"
#     ],
#     "rg2" = [
#       "role3"
#     ]
#   }
# }
#
variable "ci_rbac_roles" {
  type = object({
    subscription    = set(string)
    resource_groups = map(list(string))
  })

  default = {
    subscription    = ["Reader"]
    resource_groups = {}
  }

  description = "Set of CI identity roles for the current subscription and the specified resource groups"
}

#
# cd_rbac_roles = {
#   subscription = ["role1", "role2"]
#   resource_groups = {
#     "rg1" = [
#       "role1",
#       "role2"
#     ],
#     "rg2" = [
#       "role3"
#     ]
#   }
# }
#
variable "cd_rbac_roles" {
  type = object({
    subscription    = set(string)
    resource_groups = map(list(string))
  })

  default = {
    subscription    = ["Contributor"]
    resource_groups = {}
  }

  description = "Set of CD identity roles for the current subscription and the specified resource groups"
}
