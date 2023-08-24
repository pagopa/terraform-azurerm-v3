variable "grafana_url" {
  type = string
  description = "Grafana Managed url"
}

variable "grafana_api_key" {
  type = string
  description = "Grafana Managed Service Account key"
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

variable "monitor_workspace_id" {
  type = string
  description = "Azure Log Analytics workspace id"
}

variable "dashboard_directory_path" {
  type    = string
  default = "dashboard"
  description = "path for dashboard template"
}