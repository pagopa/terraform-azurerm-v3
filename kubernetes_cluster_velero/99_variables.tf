variable "tags" {
  type = map(any)
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group in which the backup storage account is located"
}

variable "backup_enabled" {
  type        = bool
  description = "(Optional) Enables the scheduled Velero backups of all the namespaces"
  default     = false
}

variable "backup_storage_container_name" {
  type        = string
  description = "(Required) Name of the storage container where Velero keeps the backups"
}


variable "backup_storage_account_name" {
  type        = string
  description = "(Required) Name of the storage account where Velero keeps the backups"
}


variable "subscription_id" {
  type        = string
  description = "(Required) ID of the subscriiption"
}

variable "tenant_id" {
  type        = string
  description = "(Required) ID of the tenant"
}

variable "backup_schedule" {
  type        = string
  description = "(Optional) Cron expression for the scheduled velero backup including all namespaces, in UTC timezone. ref: https://velero.io/docs/v1.9/backup-reference/"
  default     = "0 3 * * *"
}

variable "backup_ttl" {
  type        = string
  description = "(Optional) TTL for velero 'all namespaces' backup, expressed using '<number>h<number>m<number>s' format"
  default     = "360h0m0s"
}

variable "volume_snapshot" {
  type        = bool
  description = "(Optional) Whether or not to execute the persistence volume snapshot. Disabled by default"
  default     = false
}

variable "plugin_version" {
  type        = string
  description = "(Optional) Version for the velero plugin"
  default     = "v1.5.0"
}

variable "application_prefix" {
  type        = string
  description = "(Optional) Prefix used in the AD Application name, if provided"
  default     = null
}
