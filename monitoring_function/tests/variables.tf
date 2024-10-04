# general

variable "prefix" {
  type = string
  validation {
    condition = (
      length(var.prefix) <= 6
    )
    error_message = "Max length is 6 chars."
  }
}


variable "env_short" {
  type = string
  validation {
    condition = (
      length(var.env_short) == 1
    )
    error_message = "Length must be 1 chars."
  }
}

variable "env" {
  type = string
}

variable "location" {
  type        = string
  description = "One of westeurope, northeurope"
}

variable "location_short" {
  type = string
  validation {
    condition = (
      length(var.location_short) == 3
    )
    error_message = "Length must be 3 chars."
  }
  description = "One of wue, neu"
}



variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "legacy" {
  type        = bool
  description = "(Optional) Enable new terraform resource features for container app job."
}

#
# Feature flags
#
variable "enabled_resource" {
  type = object({
    container_app_tools_cae = optional(bool, false),
  })
}

variable "storage_account_replication_type" {
  type        = string
  description = "(Required) table storage replication type"
}

variable "use_private_endpoint" {
  type        = bool
  description = "(Required) if true enables the usage of private endpoint"
}


## Monitor
variable "law_sku" {
  type        = string
  description = "Sku of the Log Analytics Workspace"
  default     = "PerGB2018"
}

variable "law_retention_in_days" {
  type        = number
  description = "The workspace data retention in days"
  default     = 30
}

variable "law_daily_quota_gb" {
  type        = number
  description = "The workspace daily quota for ingestion in GB."
  default     = -1
}

variable "self_alert_enabled" {
  type        = bool
  description = "(Optional) enables the alert on the function itself"
  default     = true
}

variable "alert_set_auto_mitigate" {
  type        = bool
  default     = true
  description = "(Optional) Should the alerts in this Metric Alert be auto resolved? Defaults to true."
}
