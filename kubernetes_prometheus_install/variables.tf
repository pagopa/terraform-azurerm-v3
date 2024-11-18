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
    server = object({
      image_name = optional(string, "quay.io/prometheus/prometheus"),
      image_tag  = optional(string, "v2.53.1"),
    }),
    alertmanager = object({
      image_name = optional(string, "quay.io/prometheus/alertmanager"),
      image_tag  = optional(string, "v0.27.0"),
    }),
    node_exporter = object({
      image_name = optional(string, "quay.io/prometheus/node-exporter"),
      image_tag  = optional(string, "v1.8.2"),
    }),
    configmap_reload_prometheus = object({
      image_name = optional(string, "jimmidyson/configmap-reload"),
      image_tag  = optional(string, "v0.13.1"),
    }),
    configmap_reload_alertmanager = object({
      image_name = optional(string, "jimmidyson/configmap-reload"),
      image_tag  = optional(string, "v0.13.1"),
    }),
    pushgateway = object({
      image_name = optional(string, "prom/pushgateway"),
      image_tag  = optional(string, "v1.9.0"),
    }),
  })

  description = "Prometheus helm chart configuration"


  default = {
    chart_version = "25.24.1"
    server = {
      image_name = "quay.io/prometheus/prometheus"
      image_tag  = "v2.53.1",
    }
    alertmanager = {
      image_name = "quay.io/prometheus/alertmanager"
      image_tag  = "v0.27.0",
    }
    node_exporter = {
      image_name = "quay.io/prometheus/node-exporter"
      image_tag  = "v1.8.2"
    }
    configmap_reload_prometheus = {
      image_name = "jimmidyson/configmap-reload"
      image_tag  = "v0.13.1"
    }
    configmap_reload_alertmanager = {
      image_name = "jimmidyson/configmap-reload"
      image_tag  = "v0.13.1"
    }
    pushgateway = {
      image_name = "prom/pushgateway"
      image_tag  = "v1.9.0"
    }
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
