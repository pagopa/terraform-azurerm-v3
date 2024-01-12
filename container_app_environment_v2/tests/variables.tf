variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "azrmtest"
}

variable "resource_group_name" {
  type    = string
  default = "azrmtest-rg"
}

variable "tags" {
  type        = map(string)
  description = "List of tags"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
  }
}

variable "law_name" {
  type = string

  default = "azrmtest-law"
}
