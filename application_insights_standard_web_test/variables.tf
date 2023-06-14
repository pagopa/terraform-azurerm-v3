locals {
  alert_name                = var.alert_name != null ? lower(replace("${var.alert_name}", "/\\W/", "-")) : lower(replace("${var.https_endpoint}", "/\\W/", "-"))
  alert_name_sha256_limited = substr(sha256(var.alert_name), 0, 5)
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

