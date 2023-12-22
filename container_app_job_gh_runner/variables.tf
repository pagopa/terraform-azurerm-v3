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

variable "network" {
  type = object({
    vnet_resource_group_name = string
    vnet_name                = string
    subnet_name              = optional(string, "")
    subnet_cidr_block        = string
  })

  description = "Existing VNet information and subnet CIDR block to use (must be /23). Optionally specify the subnet name"
}

variable "environment" {
  type = object({
    law_name                = string
    law_resource_group_name = string
  })

  description = "Container App Environment configuration (Log Analytics Workspace)"
}

variable "app" {
  type = object({
    repo_owner = optional(string, "pagopa")
    repos      = set(string)
    image      = optional(string, "ghcr.io/pagopa/github-self-hosted-runner-azure:beta-dockerfile-v2@sha256:c7ebe4453578c9df426b793366b8498c030ec0f47f753ea2c685a3c0ec0bb646")
  })

  validation {
    condition = (
      var.app.repos != null && length(var.app.repos) >= 1
    )
    error_message = "List of repos must supplied"
  }

  description = "Container App job configuration"
}

variable "vm_size" {
  type = object({
    cpu    = number
    memory = string
  })

  default = {
    cpu    = 1.0
    memory = "2Gi"
  }

  description = "Job VM size"
}

variable "key_vault" {
  type = object({
    resource_group_name = string
    name                = string
    secret_name         = string
  })

  description = "Data of the KeyVault which stores PAT as secret"
}
