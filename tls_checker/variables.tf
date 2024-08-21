locals {
  alert_name                = var.alert_name != null ? lower(replace(var.alert_name, "/\\W/", "-")) : lower(replace(var.https_endpoint, "/\\W/", "-"))
  alert_name_sha256_limited = substr(sha256(var.alert_name), 0, 5)
  # all this work is mandatory to avoid helm name limit of 53 chars
  helm_chart_name = "${lower(substr(replace("chckr-${var.alert_name}", "/\\W/", "-"), 0, 47))}${local.alert_name_sha256_limited}"
  chart_version = var.workload_identity_enabled ? "7.1.0" : "5.9.1"
}

variable "https_endpoint" {
  type        = string
  description = "Https endpoint to check"
}

variable "location_string" {
  type        = string
  description = "(Required) Location string"
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

#
# 🔒 KV
#
variable "keyvault_name" {
  type        = string
  description = "(Required) Keyvault name"
}

variable "keyvault_tenant_id" {
  type        = string
  description = "(Required) Keyvault tenant id"
}

variable "kv_secret_name_for_application_insights_connection_string" {
  type        = string
  description = "(Required) The name of the secret inside the kv that contains the application insights connection string"
}

#
# 🪖 HELM & Kubernetes
#
variable "namespace" {
  type        = string
  description = "(Required) Namespace where the helm chart will be installed"
}

variable "helm_chart_present" {
  type        = bool
  description = "Is this helm chart present?"
  default     = true
}

variable "helm_chart_version" {
  type        = string
  description = "Helm chart version for the tls checker application"
  default     = "5.9.1"
}

variable "helm_chart_image_name" {
  type        = string
  description = "Docker image name"
  default     = "ghcr.io/pagopa/infra-ssl-check"
}

variable "helm_chart_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "v1.3.4@sha256:c3d45736706c981493b6216451fc65e99a69d5d64409ccb1c4ca93fef57c921d"
}

#
# App Insigths and alert
#
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

#
# Workload Identity
#

variable "workload_identity_enabled" {
  type        = bool
  description = "Enable workload identity chart"
  default     = false
}

variable "workload_identity_service_account_name" {
  type        = string
  description = "Service account name linked to workload identity"
  default     = null
}

variable "workload_identity_client_id" {
  type        = string
  description = "ClientID in form of 'qwerty123-a1aa-1234-xyza-qwerty123' linked to workload identity"
  default     = null
}
