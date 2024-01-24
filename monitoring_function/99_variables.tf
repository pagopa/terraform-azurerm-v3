variable "tags" {
  type = map(any)
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group in which the function and its related components are created"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix used in the Velero dedicated resource names"
}

variable "location" {
  type        = string
  description = "(Required) Resource location"
}


variable "storage_account_tier" {
  type        = string
  description = "(Optional) Tier used for the backup storage account"
  default     = "Standard"
}

variable "storage_account_replication_type" {
  type        = string
  description = "(Optional) Replication type used for the backup storage account"
  default     = "ZRS"
}

variable "storage_account_kind" {
  type        = string
  default     = "StorageV2"
  description = "(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2"
}

variable "sa_backup_retention_days" {
  type        = number
  description = "(Optional) number of days for which the storage account is available for point in time recovery"
  default     = 0
}

variable "enable_sa_backup" {
  type        = bool
  description = "(Optional) enables storage account point in time recovery"
  default     = false
}


variable "execution_timeout_seconds" {
  type        = number
  default     = 300
  description = "(Optional) Job execution timeout, in seconds"
}


variable "use_storage_private_endpoint" {
  type        = bool
  description = "(Optional) Whether to make the storage account private and use a private endpoint to connect"
  default     = true
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "(Optional) Subnet id where to create the private endpoint for backups storage account"
  default     = null
}

variable "storage_account_private_dns_zone_id" {
  type        = string
  description = "(Optional) Storage account private dns zone id, used in the private endpoint creation"
  default     = null
}

variable "registry_url" {
  type        = string
  description = "(Optional) Docker container registry url where to find the monitoring image"
  default     = "ghcr.io"
}

variable "monitoring_image_tag" {
  type        = string
  description = "(Optional) Docker image tag"
  default     = "1.0.0"
}

variable "monitoring_image_name" {
  type        = string
  description = "(Optional) Docker image name"
  default     = "pagopa/azure-synthetic-monitoring"
}


variable "app_insight_connection_string" {
  type        = string
  description = "(Required) App insight connection string where metrics will be published"
}


variable "cron_scheduling" {
  type        = string
  default     = "* * * * *"
  description = "(Optional) Cron expression defining the execution scheduling of the monitoring function"
}

variable "cpu_requirement" {
  type        = number
  default     = 0.25
  description = "(Optional) Decimal; cpu requirement"
}

variable "memory_requirement" {
  type        = string
  description = "(Optional) Memory requirement"
  default     = "0.5Gi"
}


variable "container_app_environment_id" {
  type        = string
  description = "(Optional) If defined, the id of the container app environment tu be used to run the monitoring job. If provided, skips the creation of a dedicated subnet"
  default     = null
}


variable "monitoring_configuration" {
  type = set(object({
    appName = string
    apiName = string
    url = string
    type = string
    checkCertificate = bool
    method = string
    expectedCodes = list(string)
    tags = object({})
    headers = optional(object({}), {})
    body_object = optional(object({}), null)
    body_string = optional(string, null)

  }))
}

