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
    secret_name         = "gh_pat"
  }
}

variable "network" {
  type = object({
    rg_vnet      = string
    vnet         = string
    cidr_subnets = list(string)
  })

  default = {
    rg_vnet      = "azrmtest-vnet-rg"
    vnet         = "azrmtest-vnet"
    cidr_subnets = ["10.0.2.0/23"]
  }
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
    repos      = optional(set(string))
    repo_owner = string
  })

  default = {
    repo_owner = "pagopa"
  }
}
