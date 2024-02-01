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

variable "storage_account_settings" {
  type = object({
    tier                     = optional(string, "Standard" ) #(Optional) Tier used for the backup storage account
    replication_type         = optional(string, "ZRS" ) #(Optional) Replication type used for the backup storage account
    kind                     = optional(string, "StorageV2" ) #(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2
    backup_retention_days    = optional(number, 0 ) #(Optional) number of days for which the storage account is available for point in time recovery
    backup_enabled           = optional(bool,   false )   # (Optional) enables storage account point in time recovery
    private_endpoint_enabled = optional(bool,   false )   #(Optional) enables the creation and usage of private endpoint
    private_dns_zone_id      = string # (Optional) table storage private dns zone id
  })
  default = {
    tier                     = "Standard"
    replication_type         = "ZRS"
    kind                     = "StorageV2"
    backup_retention_days    = 0
    backup_enabled           = false
    private_endpoint_enabled = false
    private_dns_zone_id      = null
  }
}

variable "job_settings" {
  type = object({
    execution_timeout_seconds    = optional(number, 300) #(Optional) Job execution timeout, in seconds
    cron_scheduling              = optional(string, "* * * * *") #(Optional) Cron expression defining the execution scheduling of the monitoring function
    cpu_requirement              = optional(number, 0.25) #(Optional) Decimal; cpu requirement
    memory_requirement           = optional(string, "0.5Gi") #(Optional) Memory requirement
    http_client_timeout          = optional(number, 0) #(Optional) Default http client timeout, in milliseconds
    default_duration_limit       = optional(number, 10000) #(Optional) Duration limit applied if none is given in the monitoring configuration. in milliseconds
    availability_prefix          = optional(string, "synthetic") #(Optional) Prefix used for prefixing availability test names
    container_app_environment_id = string #(Required) If defined, the id of the container app environment tu be used to run the monitoring job. If provided, skips the creation of a dedicated subnet
  })
  default = {
    execution_timeout_seconds    = 300
    cron_scheduling              = "* * * * *"
    cpu_requirement              = 0.25
    memory_requirement           = "0.5Gi"
    http_client_timeout          = 0
    default_duration_limit       = 10000
    availability_prefix          = "synthetic"
    container_app_environment_id = null
  }
  validation {
    condition     = length(var.job_settings.availability_prefix) > 0
    error_message = "availability_prefix must not be empty"
  }
}

variable "docker_settings" {
  type = object({
    registry_url = optional(string,"ghcr.io")  #(Optional) Docker container registry url where to find the monitoring image
    image_tag    = string #(Optional) Docker image tag
    image_name   = optional(string, "pagopa/azure-synthetic-monitoring") #(Optional) Docker image name
  })
  default = {
    registry_url = "ghcr.io"
    image_tag    = "1.0.0"
    image_name   = "pagopa/azure-synthetic-monitoring"
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "(Optional) Subnet id where to create the private endpoint for backups storage account"
  default     = null
}

variable "application_insight_name" {
  type        = string
  description = "(Required) name of the application insight instance where to publish metrics"
}

variable "application_insight_rg_name" {
  type        = string
  description = "(Required) name of the application insight instance resource group where to publish metrics"
}

variable "application_insights_action_group_ids" {
  type        = list(string)
  description = "(Required) Application insights action group ids"
}

variable "monitoring_configuration_encoded" {
  type        = string
  description = "(Required) monitoring configuration provided in JSON string format (use jsonencode)"
}
