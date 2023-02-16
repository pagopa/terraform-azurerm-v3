variable "address_prefixes" {
  type    = list(any)
  default = ["10.0.1.0/24"]
}

variable "address_space" {
  type    = list(any)
  default = ["10.0.0.0/16"]
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "project" {
  type    = string
  default = "test"
}

variable "resource_group_name" {
  type    = string
  default = "test_rg"
}

variable "tags" {
  type = object({
    Name = string
  })

  default = {
    Name = "test_function_app"
  }
}

