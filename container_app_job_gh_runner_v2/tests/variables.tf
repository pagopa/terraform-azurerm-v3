variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmte"
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

  description = "KeyVault properties"
}

variable "job" {
  type = object({
    name                 = optional(string)
    repo_owner           = optional(string)
    repo                 = optional(string)
    polling_interval     = optional(number)
    scale_max_executions = optional(number)
  })

  default = {
    name                 = "azurermv3"
    repo_owner           = "pagopa"
    repo                 = "terraform-azurerm-v3"
    polling_interval     = 30
    scale_max_executions = 5
  }

  description = "Container App job properties"
}
