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
  })

  description = "Prometheus helm chart configuration"


  default = {
    chart_version = "25.24.1"
  }
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
