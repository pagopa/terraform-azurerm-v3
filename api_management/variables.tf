variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "publisher_name" {
  type        = string
  description = "The name of publisher/company."
}

variable "publisher_email" {
  type        = string
  description = "The email of publisher/company."
}

variable "notification_sender_email" {
  type        = string
  description = "Email address from which the notification will be sent."
  default     = null
}

variable "sku_name" {
  type        = string
  description = "A string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
}

variable "autoscale" {
  type = object(
    {
      enabled                       = bool
      default_instances             = number
      minimum_instances             = number
      maximum_instances             = number
      scale_out_capacity_percentage = number
      scale_out_time_window         = string
      scale_out_value               = string
      scale_out_cooldown            = string
      scale_in_capacity_percentage  = number
      scale_in_time_window          = string
      scale_in_value                = string
      scale_in_cooldown             = string
    }
  )
  default = {
    enabled                       = true
    default_instances             = 1
    minimum_instances             = 1
    maximum_instances             = 5
    scale_out_capacity_percentage = 60
    scale_out_time_window         = "PT10M"
    scale_out_value               = "2"
    scale_out_cooldown            = "PT45M"
    scale_in_capacity_percentage  = 30
    scale_in_time_window          = "PT30M"
    scale_in_value                = "1"
    scale_in_cooldown             = "PT30M"
  }
  description = "Configure Apim autoscale rule on capacity metric"
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "The id of the subnet that will be used for the API Management."
}

variable "application_insights" {
  type = object({
    enabled             = bool
    instrumentation_key = string
  })
  description = "Application Insights integration The instrumentation key used to push data"
}

variable "virtual_network_type" {
  type        = string
  description = "The type of virtual network you want to use, valid values include: None, External, Internal"
  default     = null
}

variable "policy_path" {
  type        = string
  default     = null
  description = "(Deprecated). Path of the policy file."
}

variable "xml_content" {
  type        = string
  default     = null
  description = "Xml content for all api policy"
}

variable "hostname_configuration" {
  type = object({

    proxy = list(object(
      {
        default_ssl_binding = bool
        host_name           = string
        key_vault_id        = string
    }))

    management = object({
      host_name    = string
      key_vault_id = string
    })

    portal = object({
      host_name    = string
      key_vault_id = string
    })

    developer_portal = object({
      host_name    = string
      key_vault_id = string
    })

  })
  default     = null
  description = "Custom domains"
}

variable "diagnostic_sampling_percentage" {
  type        = number
  default     = 5.0
  description = "Sampling (%). For high traffic APIs, please read the documentation to understand performance implications and log sampling. Valid values are between 0.0 and 100.0."
}

variable "diagnostic_always_log_errors" {
  type        = bool
  default     = true
  description = "Always log errors. Send telemetry if there is an erroneous condition, regardless of sampling settings."
}

variable "diagnostic_log_client_ip" {
  type        = bool
  default     = true
  description = "Log client IP address."
}

variable "diagnostic_http_correlation_protocol" {
  type        = string
  default     = "W3C"
  description = "The HTTP Correlation Protocol to use. Possible values are None, Legacy or W3C."
}

variable "diagnostic_verbosity" {
  type        = string
  default     = "error"
  description = "Logging verbosity. Possible values are verbose, information or error."
}

variable "diagnostic_backend_request" {
  description = "Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1"
  type = set(object(
    {
      body_bytes     = number
      headers_to_log = set(string)
    }
  ))
  default = []
}

variable "diagnostic_backend_response" {
  description = "Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1"
  type = set(object(
    {
      body_bytes     = number
      headers_to_log = set(string)
    }
  ))
  default = []
}

variable "diagnostic_frontend_request" {
  description = "Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1"
  type = set(object(
    {
      body_bytes     = number
      headers_to_log = set(string)
    }
  ))
  default = []
}

variable "diagnostic_frontend_response" {
  description = "Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1"
  type = set(object(
    {
      body_bytes     = number
      headers_to_log = set(string)
    }
  ))
  default = []
}


variable "metric_alerts" {
  default = {}

  description = <<EOD
Map of name = criteria objects
EOD

  type = map(object({
    description = string
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string
    # Possible values are 0, 1, 2, 3.
    severity = number
    # Possible values are true, false
    auto_mitigate = bool

    criteria = set(object(
      {
        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
        aggregation = string
        dimension = list(object(
          {
            name     = string
            operator = string
            values   = list(string)
          }
        ))
        metric_name      = string
        metric_namespace = string
        # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
        operator               = string
        skip_metric_validation = bool
        threshold              = number
      }
    ))

    dynamic_criteria = set(object(
      {
        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
        aggregation       = string
        alert_sensitivity = string
        dimension = list(object(
          {
            name     = string
            operator = string
            values   = list(string)
          }
        ))
        evaluation_failure_count = number
        evaluation_total_count   = number
        ignore_data_before       = string
        metric_name              = string
        metric_namespace         = string
        operator                 = string
        skip_metric_validation   = bool
      }
    ))
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

variable "redis_connection_string" {
  type        = string
  description = "Connection string for redis external cache. Set `redis_cache_enabled` = true tuse this value"
  default     = null
}

variable "redis_cache_id" {
  type        = string
  description = "The resource ID of the Cache for Redis. Set `redis_cache_enabled` = true tuse this value"
}

variable "alerts_enabled" {
  type        = bool
  default     = true
  description = "Should Metrics Alert be enabled?"
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "Key vault id."
}

variable "certificate_names" {
  type        = list(string)
  default     = []
  description = "List of key vault certificate name"
}

variable "sign_up_enabled" {
  type        = bool
  default     = false
  description = "Can users sign up on the development portal?"
}

variable "sign_up_terms_of_service" {
  type = object(
    {
      consent_required = bool
      enabled          = bool
      text             = string
    }
  )
  default     = null
  description = "the development portal terms_of_service"
}

variable "lock_enable" {
  type        = bool
  default     = false
  description = "Apply lock to block accedentaly deletions."
}

variable "sec_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log analytics workspace security (it should be in a different subscription)."
}

variable "sec_storage_id" {
  type        = string
  default     = null
  description = "Storage Account security (it should be in a different subscription)."
}

variable "tags" {
  type = map(any)
}

variable "zones" {
  type        = list(string)
  default     = []
  description = "List of availability zones"
}

variable "public_ip_address_id" {
  type        = string
  default     = null
  description = "A Public Ip resource ID"
}

variable "redis_cache_enabled" {
  type        = bool
  description = "(Optional) if true, enables redis caching"
  default     = false
}

variable "management_logger_applicaiton_insight_enabled" {
  type        = bool
  description = "(Optional) if false, disables management logger application insight block"
  default     = true
}

variable "min_api_version" {
  type        = string
  description = "(Optional) The minimum API version"
  default     = null
}