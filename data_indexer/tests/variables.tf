variable "location" {
  type    = string
  default = "italynorth"
}

variable "prefix" {
  description = "Resorce prefix"
  type        = string
  default     = "azrmtest"
}

variable "tags" {
  type        = map(string)
  description = "Data Indexer example"
  default = {
    CreatedBy = "Terraform"
    Source    = "https://github.com/pagopa/terraform-azurerm-v3"
    Test      = "data-indexer"
  }
}

### Custom variables

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "cidr_subnet_pendpoints" {
  type    = list(string)
  default = ["10.0.250.0/23"]
}