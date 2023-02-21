variable "address_prefixes" {
  type    = list(any)
  default = ["10.0.1.0/26"]
}

variable "address_space" {
  type    = list(any)
  default = ["10.0.0.0/16"]
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "project" {
  type    = string
  default = "example"
}

variable "tags" {
  type = map
  description = "Tags for infrastructure resources."
  default = {
    CreatedBy   = "Terraform"
    Source      = "https://github.com/pagopa/terraform-azurerm-v3"
  }
}

