variable "https_endpoint" {
  type        = string
  description = "Https endpoint to check"
}

variable "namespace" {
  type        = string
  description = "(Required) Namespace where the helm chart will be installed"
}

variable "location_string" {
  type        = string
  description = "(Required) Location string"
}

variable "helm_chart_version" {
  type        = string
  description = "Helm chart version for the tls checker application"
}

variable "helm_chart_image_name" {
  type        = string
  description = "Docker image name"
}

variable "helm_chart_image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "time_trigger" {
  type        = string
  description = "cron trigger pattern"
  default     = "*/1 * * * *"
}

variable "expiration_delta_in_days" {
  type        = string
  default     = "7"
  description = "(Optional)"
}

variable "application_insights_connection_string" {
  type        = string
  description = "(Required) Application Insights connection string"
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

variable "helm_chart_present" {
  type        = bool
  description = "Is this helm chart present?"
  default     = true
}


locals {
  alert_name                = var.alert_name != null ? lower(replace("${var.alert_name}", "/\\W/", "-")) : lower(replace("${var.https_endpoint}", "/\\W/", "-"))
  alert_name_sha256_limited = substr(sha256(var.alert_name), 0, 5)
  # all this work is mandatory to avoid helm name limit of 53 chars
  helm_chart_name = "${lower(substr(replace("chckr-${var.alert_name}", "/\\W/", "-"), 0, 47))}${local.alert_name_sha256_limited}"
}
