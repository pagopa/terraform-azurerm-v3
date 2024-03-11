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


variable "data_source_id" {
  type = string
}
variable "action_group_ids" {
  type = list(string)
  default = []
}
variable "rg_name" {
  type = string
}
variable "location" {
  type = string
}
