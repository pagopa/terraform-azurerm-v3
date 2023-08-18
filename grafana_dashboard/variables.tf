variable "grafana_url" {
  type = string
}

variable "grafana_api_key" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type = string
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}