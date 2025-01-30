locals {
  default_affinity = {
    nodeAffinity = {
      requiredDuringSchedulingIgnoredDuringExecution = {
        nodeSelectorTerms = [{
          matchExpressions = [{
            key = "kubernetes.azure.com/mode"
            operator = "NotIn"
            values = ["system"]
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
    chart_version = optional(string, "25.24.1")
    server_storage_size = optional(string, "128Gi")
    alertmanager_storage_size = optional(string, "32Gi")
    replicas = optional(number, 1)
  })

  description = "Prometheus helm chart configuration"


  default = {
    chart_version = "25.24.1"
  }
}

variable "prometheus_node_selector" {
  description = "Node selector for Prometheus components"
  type = map(string)
  default = {}
}

variable "prometheus_tolerations" {
  description = "Tolerations for Prometheus components"
  type = list(object({
    key = string
    operator = string
    value = string
    effect = string
  }))
  default = []
}

variable "prometheus_affinity" {
  description = "Custom affinity rules for each component"
  type = map(object({
    nodeAffinity = object({
      requiredDuringSchedulingIgnoredDuringExecution = object({
        nodeSelectorTerms = list(object({
          matchExpressions = list(object({
            key = string
            operator = string
            values = list(string)
          }))
        }))
      })
    })
  }))
  default = {}
}

#
# CRDS
#
variable "prometheus_crds_enabled" {
  type        = bool
  description = "Setup CRDS for prometheus"
  default     = false
}

variable "prometheus_crds_release_version" {
  type        = string
  description = "Prometheus CRDS helm release version. https://github.com/prometheus-community/helm-charts/pkgs/container/charts%2Fprometheus-operator-crds "
  default     = "16.0.0"
}
