locals {
  alert_name                = var.alert_name != null ? lower(replace("${var.alert_name}", "/\\W/", "-")) : lower(replace("${var.https_endpoint}", "/\\W/", "-"))
  alert_name_sha256_limited = substr(sha256(var.alert_name), 0, 5)
}

variable "location" {
  type        = string
  description = "Application insight location."
}

variable "https_endpoint" {
  type        = string
  description = "Https endpoint to check"
}

variable "https_endpoint_path" {
  type        = string
  description = "Https endpoint path to check"
}

variable "https_probe_headers" {
  type        = string
  description = "Https request headers"
  default     = "{}"
}

variable "https_probe_body" {
  type        = string
  description = "Https request body"
  default     = null
}

variable "https_probe_method" {
  type        = string
  description = "Https request method"
}

variable "application_insights_resource_group" {
  type        = string
  description = "(Required) Application Insights resource group"
}

variable "application_insights_id" {
  type        = string
  description = "(Required) Application Insights id"
}

variable "application_insights_action_group_ids" {
  type        = list(string)
  description = "(Required) Application insights action group ids"
}

variable "alert_name" {
  type        = string
  description = "(Optional) Alert name"
  default     = null
}

variable "alert_enabled" {
  type        = bool
  description = "(Optional) Is this alert enabled?"
  default     = true
}

variable "frequency" {
  type        = number
  description = "(Optional) Interval in seconds between test runs for this WebTest. Valid options are 300, 600 and 900. Defaults to 300."
  default     = 300
}

variable "retry_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should the retry on WebTest failure be enabled?"
}

variable "timeout" {
  type        = number
  default     = 30
  description = "(Optional) Seconds until this WebTest will timeout and fail. Default is 30."
}

variable "metric_frequency" {
  type        = string
  description = "(Optional) The evaluation frequency of this Metric Alert, represented in ISO 8601 duration format. Possible values are PT1M, PT5M, PT15M, PT30M and PT1H. Defaults to PT5M."
  default     = "PT5M"
}

variable "metric_severity" {
  type        = number
  description = "(Optional) The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 0."
  default     = 0
}

variable "metric_window_size" {
  type        = string
  description = "(Optional) The period of time that is used to monitor alert activity, represented in ISO 8601 duration format. This value must be greater than frequency. Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D. Defaults to PT5M."
  default     = "PT5M"
}

variable "https_probe_threshold" {
  type        = number
  description = "threshold for metric alert"
  default     = 90
}
