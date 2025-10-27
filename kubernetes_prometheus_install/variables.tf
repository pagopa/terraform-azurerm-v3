locals {
  default_affinity = {
    nodeAffinity = {
      requiredDuringSchedulingIgnoredDuringExecution = {
        nodeSelectorTerms = [{
          matchExpressions = [{
            key      = "kubernetes.azure.com/mode"
            operator = "NotIn"
            values   = ["system"]
          }]
        }]
      }
    }
  }
}

variable "prometheus_namespace" {
  type        = string
  description = "(Required) Name of the monitoring namespace, used to install prometheus resources"
}

variable "storage_class_name" {
  type        = string
  default     = "default"
  description = "(Optional) Storage class name used for prometheus server and alertmanager"
}

variable "prometheus_helm" {
  type = object({
    chart_version             = optional(string, "27.1.0")
    server_storage_size       = optional(string, "128Gi")
    alertmanager_storage_size = optional(string, "32Gi")
    replicas                  = optional(number, 1)
  })

  description = "Prometheus helm chart configuration"


  default = {
    chart_version             = "27.1.0"
    server_storage_size       = "128Gi"
    alertmanager_storage_size = "32Gi"
    replicas                  = 1
  }
}

# Semplifichiamo le variabili
variable "prometheus_affinity" {
  description = "Global affinity rules for all Prometheus components"
  type = object({
    nodeAffinity = object({
      requiredDuringSchedulingIgnoredDuringExecution = object({
        nodeSelectorTerms = list(object({
          matchExpressions = list(object({
            key      = string
            operator = string
            values   = list(string)
          }))
        }))
      })
    })
  })
  default = null # Usiamo null per permettere l'uso del default locale
}

variable "prometheus_node_selector" {
  description = "Global node selector for all Prometheus components"
  type        = map(string)
  default     = {}
}

variable "prometheus_tolerations" {
  description = "Global tolerations for all Prometheus components"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

#
# CRDS
#
variable "prometheus_crds_enabled" {
  type        = bool
  description = "Setup CRDS for prometheus"
  default     = true
}

variable "prometheus_crds_release_version" {
  type        = string
  description = "Prometheus CRDS helm release version. https://github.com/prometheus-community/helm-charts/pkgs/container/charts%2Fprometheus-operator-crds "
  default     = "17.0.2"
}
