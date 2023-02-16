variable "project" {
  type = string
  default = "test"
}

variable "resource_group_name" {
  type = string
  default = "test_rg"
}

variable "location" {
  type = string
  default = "West Europe"
}

variable "tags" {
    type = object({
        Name = string
    })

    default = {
        Name = "test_function_app"
    }
}