variable "name" {
  type        = string
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "location" {
  type        = string
  description = "(Required) The Azure Region where the PostgreSQL Flexible Server should exist."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group where the PostgreSQL Flexible Server should exist."
}


#
# Network
#

variable "private_endpoint_enabled" {
  type        = bool
  description = "Is this instance private only?"
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the private dns zone to create the PostgreSQL Flexible Server. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "delegated_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated."
}

#
# ♊️ High Availability
#
variable "high_availability_enabled" {
  type        = bool
  description = "(Required) Is the High Availability Enabled"
}

variable "standby_availability_zone" {
  type        = number
  default     = null
  description = "(Optional) Specifies the Availability Zone in which the standby Flexible Server should be located."
}

variable "maintenance_window_config" {
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })

  default = {
    day_of_week  = 3
    start_hour   = 2
    start_minute = 0
  }

  description = "(Optional) Allows the configuration of the maintenance window, if not configured default is Wednesday@2.00am"

}

#
# Administration
#
variable "sku_name" {
  type        = string
  description = "The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
}




variable "zone" {
  type        = number
  description = "(Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  default     = null
}

#
# DB Configurations
#
variable "pgbouncer_enabled" {
  type        = bool
  default     = true
  description = "Is PgBouncer enabled into configurations?"
}


#
# Monitoring & Alert
#

variable "replica_server_metric_alerts" {

  description = <<EOD
  Map of name = criteria objects
  EOD

  type = map(object({
    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
    aggregation = string
    metric_name = string
    # "Insights.Container/pods" "Insights.Container/nodes"
    metric_namespace = string
    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
    operator  = string
    threshold = number
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string
    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3.
    severity = number
  }))

  default = {
    replica_lag = {
      frequency        = "PT5M"
      window_size      = "PT30M"
      metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
      aggregation      = "Average"
      metric_name      = "physical_replication_delay_in_seconds"
      operator         = "GreaterThanOrEqual"
      threshold        = 240
      severity         = 2
    }
  }
}


variable "main_server_additional_alerts" {

  description = <<EOD
  Map of name = criteria objects
  EOD

  type = map(object({
    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
    aggregation = string
    metric_name = string
    # "Insights.Container/pods" "Insights.Container/nodes"
    metric_namespace = string
    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
    operator  = string
    threshold = number
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string
    # severity: The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 3.
    severity = number
  }))

  default = {
    replication_delay_bytes = {
      frequency        = "PT5M"
      window_size      = "PT30M"
      metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
      aggregation      = "Average"
      metric_name      = "physical_replication_delay_in_bytes"
      operator         = "GreaterThanOrEqual"
      threshold        = 240
      severity         = 2
    }
  }
}

variable "alerts_enabled" {
  type        = bool
  default     = true
  description = "Should Metrics Alert be enabled?"
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

variable "diagnostic_settings_enabled" {
  type        = bool
  default     = true
  description = "Is diagnostic settings enabled?"
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent."
}

variable "diagnostic_setting_destination_storage_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Storage Account where logs should be sent. Changing this forces a new resource to be created."
}

variable "source_server_id" {
  type = string
  description = "(Required) Id of the source server to be replicated"
}

variable "tags" {
  type = map(any)
}

