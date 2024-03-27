variable "kibana_external_domain" {
  description = "Kibana external domain"
  type        = string
}

variable "secret_name" {
  description = "Secret certificate name"
  type        = string
}

variable "keyvault_name" {
  description = "Keyvault name"
  type        = string
}

variable "kibana_internal_hostname" {
  description = "Kibana internal hostname"
  type        = string
}

variable "namespace" {
  description = "Namespace for ECK Operator"
  type        = string
  default     = "elastic-system"
}

variable "nodeset_config" {
  type = map(object({
    count            = string
    roles            = list(string)
    storage          = string
    storageClassName = string
    requestMemory    = string
    requestCPU       = string
    limitsMemory     = string
    limitsCPU        = string
  }))
  default = {
    default = {
      count            = 1
      roles            = ["master", "data", "data_content", "data_hot", "data_warm", "data_cold", "data_frozen", "ingest", "ml", "remote_cluster_client", "transform"]
      storage          = "5Gi"
      storageClassName = "standard"
      requestMemory    = "2Gi"
      requestCPU       = "1"
      limitsMemory     = "2Gi"
      limitsCPU        = "1"
    }
  }
}

variable "dedicated_log_instance_name" {
  type = list(string)
}

variable "env_short" {
  type = string
}
variable "env" {
  type = string
}

variable "eck_license" {
  type = string
}

variable "snapshot_secret_name" {
  type = string
}

variable "eck_version" {
  type        = string
  description = "ECK (Elastic Cloud on Kubernetes) version, see: https://www.elastic.co/guide/en/cloud-on-k8s/index.html for futher versions"
  validation {
    condition     = contains(["2.9", "2.6"], var.eck_version)
    error_message = "The ECK version supported is only 2.9 or 2.6"
  }
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID for azure"
  default     = "7788edaf-0346-4068-9d79-c868aed15b3d"
}
