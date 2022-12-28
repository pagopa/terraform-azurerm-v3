variable "jwt_name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

# cert info
variable "cert_common_name" {
  type = string
}

variable "cert_password" {
  type = string
}

variable "cert_validity_hours" {
  type    = number
  default = 8640
}

variable "early_renewal_hours" {
  type    = number
  default = 720
}
