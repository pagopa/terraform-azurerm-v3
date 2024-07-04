variable "es_host" {
  description = "Elastic Host"
  type = "string"
}

variable "namespace" {
  description = "Namespace for ECK Operator"
  type        = string
  default     = "elastic-system"
}

variable "dedicated_log_instance_name" {
  type = list(string)
}

variable "eck_version" {
  type        = string
  description = "ECK (Elastic Cloud on Kubernetes) version, see: https://www.elastic.co/guide/en/cloud-on-k8s/index.html for futher versions"
  validation {
    condition     = contains(["2.12", "2.9", "2.6"], var.eck_version)
    error_message = "The ECK version supported is only 2.9 or 2.6"
  }
}
