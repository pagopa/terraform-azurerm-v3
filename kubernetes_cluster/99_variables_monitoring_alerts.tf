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

# Setting locals logs alerts, because i need interpolation to set query correctly
locals {
  default_logs_alerts = {
    ### NODE NOT READY ALERT
    node_not_ready = {
      display_name            = "AKS Node not ready alert"
      description             = "Detect nodes that is not ready on AKS cluster"
      query                   = <<-KQL
        KubeNodeInventory
        | where ClusterId == "${azurerm_kubernetes_cluster.this.id}"
        | where TimeGenerated > ago(10m)
        | where Status == "NotReady"
        | summarize count() by Computer, Status
      KQL
      severity                = 1
      window_duration         = "PT5M"
      evaluation_frequency    = "PT5M"
      operator                = "GreaterThan"
      threshold               = 1
      time_aggregation_method = "Average"
      resource_id_column      = "Status"
      metric_measure_column   = "count_Status"
      dimension = [
        {
          name     = "Status"
          operator = "Include"
          values   = ["*"]
        }
      ]
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
      auto_mitigation_enabled                  = true
      workspace_alerts_storage_enabled         = false
      skip_query_validation                    = true
    }
    ### NODE DISK ALERT
    node_disk_usage = {
      display_name            = "AKS Node disk usage alert"
      description             = "Detect nodes disk is going to run out of space"
      query                   = <<-KQL
        InsightsMetrics
        | where _ResourceId == "${lower(azurerm_kubernetes_cluster.this.id)}"
        | where TimeGenerated > ago(10m)
        | where Namespace == "container.azm.ms/disk"
        | where Name == "used_percent"
        | project TimeGenerated, Computer, Val, Origin
        | summarize AvgDiskUsage = avg(Val) by Computer
        | where AvgDiskUsage > 80
        | summarize any(AvgDiskUsage)
      KQL
      severity                = 1
      window_duration         = "PT5M"
      evaluation_frequency    = "PT5M"
      operator                = "GreaterThan"
      threshold               = 1
      time_aggregation_method = "Average"
      resource_id_column      = "AvgDiskUsage"
      metric_measure_column   = "any_AvgDiskUsage"
      dimension = [
        {
          name     = "AvgDiskUsage"
          operator = "Include"
          values   = ["*"]
        }
      ]
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
      auto_mitigation_enabled                  = true
      workspace_alerts_storage_enabled         = false
      skip_query_validation                    = true
    }
  }
}

variable "custom_logs_alerts" {
  description = <<EOD
  Map of name = criteria objects
  EOD

  default = {}

  type = map(object({
    # (Optional) Specifies the display name of the alert rule.
    display_name = string
    # (Optional) Specifies the description of the scheduled query rule.
    description = string
    # Assuming each.value includes this attribute for Kusto Query Language (KQL)
    query = string
    # (Required) Severity of the alert. Should be an integer between 0 and 4.
    # Value of 0 is severest.
    severity = number
    # (Required) Specifies the period of time in ISO 8601 duration format on
    # which the Scheduled Query Rule will be executed (bin size).
    # If evaluation_frequency is PT1M, possible values are PT1M, PT5M, PT10M,
    # PT15M, PT30M, PT45M, PT1H, PT2H, PT3H, PT4H, PT5H, and PT6H. Otherwise,
    # possible values are PT5M, PT10M, PT15M, PT30M, PT45M, PT1H, PT2H, PT3H,
    # PT4H, PT5H, PT6H, P1D, and P2D.
    window_duration = string
    # (Optional) How often the scheduled query rule is evaluated, represented
    # in ISO 8601 duration format. Possible values are PT1M, PT5M, PT10M, PT15M,
    # PT30M, PT45M, PT1H, PT2H, PT3H, PT4H, PT5H, PT6H, P1D.
    evaluation_frequency = string
    # Evaluation operation for rule - 'GreaterThan', GreaterThanOrEqual',
    # 'LessThan', or 'LessThanOrEqual'.
    operator = string
    # Result or count threshold based on which rule should be triggered.
    # Values must be between 0 and 10000 inclusive.
    threshold = number
    # (Required) The type of aggregation to apply to the data points in
    # aggregation granularity. Possible values are Average, Count, Maximum,
    # Minimum,and Total.
    time_aggregation_method = string
    # (Optional) Specifies the column containing the resource ID. The content
    # of the column must be an uri formatted as resource ID.
    resource_id_column = string

    # (Optional) Specifies the column containing the metric measure number.
    metric_measure_column = string

    dimension = list(object(
      {
        # (Required) Name of the dimension.
        name = string
        # (Required) Operator for dimension values. Possible values are
        # Exclude,and Include.
        operator = string
        # (Required) List of dimension values. Use a wildcard * to collect all.
        values = list(string)
      }
    ))

    # (Required) Specifies the number of violations to trigger an alert.
    # Should be smaller or equal to number_of_evaluation_periods.
    # Possible value is integer between 1 and 6.
    minimum_failing_periods_to_trigger_alert = number
    # (Required) Specifies the number of aggregated look-back points.
    # The look-back time window is calculated based on the aggregation
    # granularity window_duration and the selected number of aggregated points.
    # Possible value is integer between 1 and 6.
    number_of_evaluation_periods = number

    # (Optional) Specifies the flag that indicates whether the alert should
    # be automatically resolved or not. Value should be true or false.
    # The default is false.
    auto_mitigation_enabled = bool
    # (Optional) Specifies the flag which indicates whether this scheduled
    # query rule check if storage is configured. Value should be true or false.
    # The default is false.
    workspace_alerts_storage_enabled = bool
    # (Optional) Specifies the flag which indicates whether the provided
    # query should be validated or not. The default is false.
    skip_query_validation = bool
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
  log_alerts = merge(var.custom_logs_alerts, local.default_logs_alerts)
}
