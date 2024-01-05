variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmtest"
}

variable "tags" {
  type        = map(string)
  description = "List of tags"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
  }
}

variable "key_vault" {
  type = object({
    resource_group_name = string
    name                = string
    secret_name         = string
  })

  default = {
    resource_group_name = "azrmtest-keyvault-rg"
    name                = "azrmtest-keyvault"
    secret_name         = "gh-pat"
  }
}

variable "network" {
  type = object({
    vnet_resource_group_name = string
    vnet_name                = string
    subnet_cidr_block        = string
  })

  default = {
    vnet_resource_group_name = "azrmtest-vnet-rg"
    vnet_name                = "azrmtest-vnet"
    subnet_cidr_block        = "10.0.2.0/23"
  }
}

variable "environment" {
  type = object({
    law_name                = string
    law_resource_group_name = string
  })
}

variable "app" {
  type = object({
    containers = optional(set(object({
      repo   = string
      cpu    = number
      memory = string
    })))
    repo_owner = string
  })

  default = {
    repo_owner = "pagopa"
    containers = [
      {
        repo   = "terraform-azurerm-v3"
        cpu    = 0.25
        memory = "0.5Gi"
      }
    ]
  }
}
