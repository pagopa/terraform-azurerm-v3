variable "project" {
  type = string
  validation {
    condition = (
      length(var.project) <= 10
    )
    error_message = "Max length is 1o chars."
  }
}

variable "env" {
  type        = string
  description = "Environment"
}


variable "github" {
  type = object({
    org        = string
    repository = string
  })
  description = "GitHub Organization and repository name"
  default = {
    org        = "pagopa"
    repository = "io-sign"
  }
}

variable "environment_cd_roles" {
  type = object({
    subscription    = list(string)
    resource_groups = map(list(string))
  })
  description = "GitHub Continous Delivery roles"
}

variable "github_repository_environment_cd" {
  type = object({
    protected_branches     = bool
    custom_branch_policies = bool
    reviewers_teams        = list(string)
  })
  description = "GitHub Continous Integration roles"
}
