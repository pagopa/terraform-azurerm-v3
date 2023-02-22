variable "address_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/26"]
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "project" {
  type    = string
  default = "fnapp"
}

variable "tags" {
  type        = map(string)
  description = "Function-app example"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
  }
}

