variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmtest"
}

variable "location" {
  description = "Resorce location"
  type        = string
  default     = "northeurope"
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

variable "subnet_cidr_vmss" {
  type    = list(string)
  default = ["10.0.1.0/26"]
}

variable "source_image_name" {
  type    = string
  default = "ubuntu2204-image-v1"
}
