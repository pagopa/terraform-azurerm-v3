#
# Alerts
#
variable "default_metric_alerts" {
  description = <<EOD
  Map of name = criteria objects
  EOD

  type = map(object({
    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
    aggregation = string
    # "Insights.Container/pods" "Insights.Container/nodes"
    metric_namespace = string
    metric_name      = string
    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
    operator  = string
    threshold = number
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string
    # Skip metrics validation
    skip_metric_validation = optional(bool, false)


    dimension = list(object(
      {
        name     = string
        operator = string
        values   = list(string)
      }
    ))
  }))

  default = {
    node_cpu_usage_percentage = {
      aggregation      = "Average"
      metric_namespace = "Microsoft.ContainerService/managedClusters"
      metric_name      = "node_cpu_usage_percentage"
      operator         = "GreaterThan"
      threshold        = 80
      frequency        = "PT15M"
      window_size      = "PT1H"
      dimension = [
        {
          name     = "node"
          operator = "Include"
          values   = ["*"]
        }
      ]
    }

    node_memory_working_set_percentage = {
      aggregation      = "Average"
      metric_namespace = "Microsoft.ContainerService/managedClusters"
      metric_name      = "node_memory_working_set_percentage"
      operator         = "GreaterThan"
      threshold        = 80
      frequency        = "PT15M"
      window_size      = "PT1H"
      dimension = [
        {
          name     = "node"
          operator = "Include"
          values   = ["*"]
        }
      ],
    }
    node_disk = {
      aggregation      = "Average"
      metric_namespace = "Microsoft.ContainerService/managedClusters"
      metric_name      = "node_disk_usage_percentage"
      operator         = "GreaterThan"
      threshold        = 80
      frequency        = "PT15M"
      window_size      = "PT1H"
      dimension = [
        {
          name     = "node"
          operator = "Include"
          values   = ["*"]
        },
        {
          name     = "device"
          operator = "Include"
          values   = ["*"]
        }
      ]
    }
    node_not_ready = {
      aggregation      = "Average"
      metric_namespace = "Microsoft.ContainerService/managedClusters"
      metric_name      = "kube_node_status_condition"
      operator         = "GreaterThan"
      threshold        = 0
      frequency        = "PT15M"
      window_size      = "PT1H"
      dimension = [
        {
          name     = "status2"
          operator = "Include"
          values   = ["NotReady"]
        }
      ],
    }
    pods_failed = {
      aggregation      = "Average"
      metric_namespace = "Microsoft.ContainerService/managedClusters"
      metric_name      = "kube_pod_status_phase"
      operator         = "GreaterThan"
      threshold        = 0
      frequency        = "PT15M"
      window_size      = "PT1H"
      dimension = [
        {
          name     = "phase"
          operator = "Include"
          values   = ["Failed"]
        },
        {
          name     = "namespace"
          operator = "Include"
          values   = ["*"]
        }
      ]
    }
  }
}

variable "custom_metric_alerts" {
  description = <<EOD
  Map of name = criteria objects
  EOD

  default = {}

  type = map(object({
    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
    aggregation = string
    # "Insights.Container/pods" "Insights.Container/nodes"
    metric_namespace = string
    metric_name      = string
    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
    operator  = string
    threshold = number
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string
    # Skip metrics validation
    skip_metric_validation = optional(bool, false)

    dimension = list(object(
      {
        name     = string
        operator = string
        values   = list(string)
      }
    ))
  }))
}

variable "custom_logs_alerts" {
  description = <<EOD
  Map of name = criteria objects
  EOD

  default = {}

  type = map(object({
    # Assuming each.value includes this attribute for Kusto Query Language (KQL)
    query = string
    # Severity of the alert. Possible values include: 0, 1, 2, 3, or 4.
    severity = number
    # Time window for which data needs to be fetched for query (must be greater than or equal to frequency). Values must be between 5 and 2880 (inclusive).
    time_window = number
    # Evaluation operation for rule - 'GreaterThan', GreaterThanOrEqual', 'LessThan', or 'LessThanOrEqual'.
    operator = string
    # Result or count threshold based on which rule should be triggered. Values must be between 0 and 10000 inclusive.
    threshold = number
    # Frequency (in minutes) at which rule condition should be evaluated. Values must be between 5 and 1440 (inclusive).
    frequency = number
    # Custom subject override for all email ids in Azure action group.
    email_subject = string
    # Custom payload to be sent for all webhook payloads in alerting action.
    custom_webhook_payload = string
  }))
}


variable "action" {
  description = "The ID of the Action Group and optional map of custom string properties to include with the post webhook operation."
  type = set(object(
    {
      action_group_id    = string
      webhook_properties = map(string)
    }
  ))
  default = []
}

variable "alerts_enabled" {
  type        = bool
  default     = true
  description = "Should Metrics Alert be enabled?"
}

locals {
  metric_alerts = merge(var.default_metric_alerts, var.custom_metric_alerts)
}

locals {
  log_alerts = merge(var.custom_logs_alerts)
}
