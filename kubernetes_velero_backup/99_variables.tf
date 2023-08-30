variable "backup_scheduling" {
  type = object({
    backup_name = string
    volume_snapshot = optional(bool, false)
    namespaces = list(string)
    schedule = optional(string, "0 3 * * *")
    ttl = optional(string, "360h0m0s")
  })
  description = "(Required) Backup configuration, containing the namespaces to backup and the cron expression to be used to schedule the backup"
}
