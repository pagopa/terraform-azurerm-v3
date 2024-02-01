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

variable "cert_street_address" {
  type    = list(string)
  default = []
}

variable "cert_country" {
  type    = string
  default = ""
}

variable "cert_locality" {
  type    = string
  default = ""
}

variable "cert_organization" {
  type    = string
  default = ""
}

variable "cert_organizational_unit" {
  type    = string
  default = ""
}

variable "cert_postal_code" {
  type    = string
  default = ""
}

variable "cert_province" {
  type    = string
  default = ""
}

variable "cert_serial_number" {
  type    = string
  default = ""
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

# List of key usages allowed for the issued certificate: https://datatracker.ietf.org/doc/html/rfc5280
variable "cert_allowed_uses" {
  type = list(string)
  default = [
    // "crl_signing",
    // "data_encipherment",
    "digital_signature",
    // "key_agreement",
    // "cert_signing",
    // "key_encipherment"
  ]
}

 