variable "project" {
  type    = string
  default = "pagopa"
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
      length(var.env) <= 4
    )
    error_message = "Max length is 4 chars."
  }
}

variable "enable_opencost" {
  type        = bool
  default     = false
  description = "Enable OpenCosts deployment in the cluster"
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

variable "prometheus_config" {
  type = object({
    service_port  = string
    external_url  = optional(string, "")
    namespace     = string
    service_name  = string
    chart_version = optional(string, "1.42.3")
  })
  description = "Configuration object for Prometheus deployment, including chart version, optional external URL, namespace, service name, service port, and other related settings."
  default = {
    namespace     = "monitoring"
    service_name  = "prometheus-service"
    service_port  = 9090
    chart_version = "1.42.3"
    external_url  = ""
  }
}

# Opencost Variables
#####################

variable "opencost_helm_chart_version" {
  type        = string
  default     = "1.43.0"
  description = "Helm version of Opencost chart"
}
