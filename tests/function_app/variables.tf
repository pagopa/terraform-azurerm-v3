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
  default = "tests654321"
}

variable "tags" {
  type = object({
    Name = string
  })

  default = {
    Name = "test_function_app"
  }
}

