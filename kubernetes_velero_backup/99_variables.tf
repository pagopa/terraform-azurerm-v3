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

variable "tags" {
  type = map(any)
}

variable "location" {
  type        = string
  description = " (Required) Specifies the Azure Region where the resource should exist. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type = string
  description = "(Optional) Required if alerts enabled. The name of the resource group in which to create the scheduled query rule instance. Changing this forces a new resource to be created."
  default = null
}


variable "alert_action" {
  description = "The ID of the Action Group and optional map of custom string properties to include with the post webhook operation."
  type = set(object(
    {
      action_group_id    = string
      webhook_properties = map(string)
    }
  ))
  default = []
}

variable "log_analytics_workspace_id" {
  type = string
  description = "(Optional) Required if alert enabled. The log analytics workspace id where to run the query to analyze logs"
  default = null
}

variable "alert_frequency" {
  type = number
  description = "(Optional) Required when alert enabled. frequency in minutes for which the alarm should be evaluated. min 5 max 1440"
  default = 1440
}

variable "alert_window" {
  type = number
  description = "(Optional) Required when alert enabled. Number of minutes for which the data should be fetched. min 5 max 2880"
  default = 1440
}

variable "alert_min_events" {
  type = number
  description = "(Optional) minimum number of backup events that should be found in the query result to not trigger the alert"
  default = 1
}

variable "alert_enabled" {
  type = bool
  description = "(Optional) If true creates log insight alerts for each backed up namespace"
  default = false
}
