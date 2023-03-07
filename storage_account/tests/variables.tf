variable "subscription_id" {
  description = "Test subscription. Default to DevOpsLab"
  type    = string
  default = "ac17914c-79bf-48fa-831e-1359ef74c1d5"
}

variable "prefix" {
  description = "Resorce prefix"
  type    = string
  default = "test"
}

variable "location" {
  description = "Resorce location"
  type    = string
  default = "westeurope"
}

variable "tags" {
  type        = map(string)
  description = "Azurerm test tags"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
  }
}
