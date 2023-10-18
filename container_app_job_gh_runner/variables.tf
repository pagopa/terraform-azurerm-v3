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
    error_message = "Max length is 6 chars."
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

variable "network" {
  type = object({
    vnet_resource_group_name = string
    vnet_name                = string
    subnet_cidr_block        = string
  })

  description = "Existing VNet information and subnet CIDR block to use (must be /23)"
}

variable "environment" {
  type = object({
    customerId = string
    sharedKey  = string
  })

  description = "Container App Environment logging configuration (Log Analytics Workspace)"
}

variable "app" {
  type = object({
    repo_owner = optional(string, "pagopa")
    repos      = set(string)
    image      = optional(string, "ghcr.io/pagopa/github-self-hosted-runner-azure:beta-dockerfile-v2@sha256:ed51ac419d78b6410be96ecaa8aa8dbe645aa0309374132886412178e2739a47")
  })

  validation {
    condition = (
      var.app.repos != null && length(var.app.repos) >= 1
    )
    error_message = "List of repos must supplied"
  }

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
