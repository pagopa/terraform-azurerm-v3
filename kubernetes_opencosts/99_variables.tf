variable "project" {
  type    = string
  default = "cstar"
  validation {
    condition = (
      length(var.project) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}

variable "env" {
  type = string
  validation {
    condition = (
      length(var.env) <= 3
    )
    error_message = "Max length is 3 chars."
  }
}

# AKS Variables
###################

variable "aks_name" {
  type        = string
  description = "(Required) Name of AKS cluster in Azure"
}

variable "aks_rg_name" {
  type        = string
  description = "(Required) Name of AKS cluster resource group in Azure"
}

variable "kubernetes_namespace" {
  type    = string
  default = "monitoring"
}

# Prometheus variables
########################
variable "prometheus_chart_version" {
  type        = string
  default     = "1.42.3"
  description = "(Optional) The prometheus chart version to use."
}

variable "prometheus_namespace" {
  type        = string
  description = "(Required) The prometheus namespace."
}

variable "prometheus_service_name" {
  type        = string
  description = "(Required) The prometheus service name."
}

variable "prometheus_service_port" {
  type        = string
  description = "(Required) The prometheus service port."
}
