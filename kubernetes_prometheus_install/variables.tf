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
}
