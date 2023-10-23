variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmtest"
}

variable "domain" {
  description = "App domain name"
  type        = string
  default     = ""
}

variable "location" {
  description = "Resorce location"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  type        = map(string)
  description = "Azurerm test tags"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
  }
}

variable "repository" {
  type        = string
  description = "Repository name"
  default     = "terraform-azurerm-v3"
}
