variable "tags" {
  type        = map(any)
  description = "Identity tags"
  default = {
    CreatedBy = "Terraform"
  }
}

variable "location" {
  type        = string
  description = "Resource group and identity location"
}

variable "prefix" {
  type        = string
  description = "Project prefix"

  validation {
    condition = (
      length(var.prefix) < 8
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

variable "network" {
  type = object({
    rg_vnet      = string
    vnet         = string
    cidr_subnets = list(string)
  })
}

variable "environment" {
  type = object({
    workspace_id = string
    customerId   = string
    sharedKey    = string
  })
}

variable "app" {
  type = object({
    repo_owner = optional(string, "pagopa")
    repos      = set(string)
    image      = optional(string, "ghcr.io/pagopa/github-self-hosted-runner-azure:beta-dockerfile-v2@sha256:ed51ac419d78b6410be96ecaa8aa8dbe645aa0309374132886412178e2739a47")
  })
}

variable "key_vault" {
  type = object({
    resource_group_name = string
    name                = string
    secret_name         = string
  })
}
