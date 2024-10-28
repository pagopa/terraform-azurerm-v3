locals {
  chart_version = var.workload_identity_enabled ? var.cert_mounter_chart_version : "1.0.4"
}

variable "namespace" {
  type        = string
  description = "(Required) Namespace where the cert secret will be created"
}

variable "certificate_name" {
  type        = string
  description = "(Required) Name of the certificate stored in the keyvault, that will be installed as a secret in aks"
}

variable "kv_name" {
  type        = string
  description = "(Required) Key vault name where to retrieve the certificate"
}

variable "tenant_id" {
  type        = string
  description = "(Required) Tenant identifier"
}

variable "cert_mounter_chart_version" {
  type        = string
  description = "(Optional) Cert mounter chart version"
  default     = "2.0.1"
}

variable "pod_ram" {
  type        = number
  description = "Pod request and limit for RAM memory (in `Mi`)"
  default     = 30
}

variable "pod_cpu" {
  type        = number
  description = "Pod request and limit for CPU (in `m`)"
  default     = 10
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
