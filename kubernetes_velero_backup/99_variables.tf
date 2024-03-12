variable "backup_name" {
  type        = string
  description = "(Required) Name assigned to the backup, used as prefix for the namespace name"
}

variable "volume_snapshot" {
  type        = bool
  default     = false
  description = "(Optional) Whether or not to execute the persistence volume snapshot. Disabled by default"
}

variable "namespaces" {
  type        = list(string)
  description = "(Required) List of namespace names to backup. Use 'ALL' for an all-namespaces backup"
}

variable "schedule" {
  type        = string
  description = "(Optional) Cron expression for the scheduled velero backup, in UTC timezone. ref: https://velero.io/docs/v1.9/backup-reference/"
  default     = "0 3 * * *"
}

variable "ttl" {
  type        = string
  description = "(Optional) TTL for velero backup, expressed using '<number>h<number>m<number>s' format"
  default     = "360h0m0s"
}

variable "aks_cluster_name" {
  type        = string
  description = "(Required) Name of the aks cluster on which Velero will be installed"
}

variable "cluster_id" {
  type        = string
  description = "(Required) cluster id that must be backed up and monitored"
}

variable "action_group_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) list of action group ids to trigger when backup alarm fires"
}

variable "rg_name" {
  type        = string
  description = "(Required) Resource group name where the backup alarm will be created"

}

variable "location" {
  type        = string
  description = "(Required) Location where the backup alarm will be created"
}

variable "tags" {
  type        = map(any)
  description = "(Required) set of tags for the backup alarm"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix assigned to the backup alarm"
}

variable "alert_enabled" {
  type        = bool
  description = "(Optional) If true, creates a scheduled query alert for each backup execution"
  default     = true
}

variable "alert_frequency" {
  type        = number
  description = "(Optional) Frequency (in minutes) at which alert rule condition should be evaluated. Values must be between 5 and 1440 (inclusive)."
  default     = 60
}
variable "alert_time_window" {
  type        = number
  description = "(Optional) Time window for which data needs to be fetched for query (must be greater than or equal to frequency). Values must be between 5 and 2880 (inclusive)."
  default     = 1440 #24 hours
}
variable "alert_severity" {
  type        = number
  description = "(Optional) Severity of the alert. Possible values include: 0, 1, 2, 3, or 4."
  default     = 1
}
