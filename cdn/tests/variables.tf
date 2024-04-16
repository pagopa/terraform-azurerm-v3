variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmtest"
}

variable "location" {
  description = "Resorce location"
  type        = string
  default     = "italynorth"
}

variable "location_cdn" {
  description = "Resorce location CDN"
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

### Custom variables

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet1_cidr" {
  type    = list(string)
  default = ["10.0.1.0/26"]
}

variable "subnet2_cidr" {
  type    = list(string)
  default = ["10.0.2.0/26"]
}
