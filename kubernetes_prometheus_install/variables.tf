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
    chart_version = string,
    alertmanager = object({
      image_name = optional(string, "quay.io/prometheus/alertmanager"),
      image_tag  = optional(string, "v0.25.0"),
    }),
    configmap_reload_prometheus = object({
      image_name = optional(string, "jimmidyson/configmap-reload"),
      image_tag  = optional(string, "v0.9.0"),
    }),
    configmap_reload_alertmanager = object({
      image_name = optional(string, "jimmidyson/configmap-reload"),
      image_tag  = optional(string, "v0.9.0"),
    }),
    node_exporter = object({
      image_name = optional(string, "quay.io/prometheus/node-exporter"),
      image_tag  = optional(string, "v1.6.1"),
    }),
    server = object({
      image_name = optional(string, "quay.io/prometheus/prometheus"),
      image_tag  = optional(string, "v2.45.0"),
    }),
    pushgateway = object({
      image_name = optional(string, "prom/pushgateway"),
      image_tag  = optional(string, "v1.6.0"),
    }),
  })
  description = "prometheus helm chart configuration"
  default = {
    chart_version = "15.18.0"
    alertmanager = {
      image_name = "quay.io/prometheus/alertmanager"
      image_tag  = "v0.25.0",
    }
    configmap_reload_prometheus = {
      image_name = "jimmidyson/configmap-reload"
      image_tag  = "v0.9.0"
    }
    configmap_reload_alertmanager = {
      image_name = "jimmidyson/configmap-reload"
      image_tag  = "v0.9.0"
    }
    node_exporter = {
      image_name = "quay.io/prometheus/node-exporter"
      image_tag  = "v1.6.1"
    }
    server = {
      image_name = "quay.io/prometheus/prometheus"
      image_tag  = "v2.45.0",
    }
    pushgateway = {
      image_name = "prom/pushgateway"
      image_tag  = "v1.6.0"
    }
  }
}
