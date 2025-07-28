variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "name" {
  type = string
}

variable "sku_name" {
  type        = string
  description = "SKU Name of the App GW"
}

variable "sku_tier" {
  type        = string
  description = "SKU tier of the App GW"
}

variable "zones" {
  type        = list(any)
  default     = null
  description = "(Optional) Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created."
}

# Networkig

variable "subnet_id" {
  type        = string
  description = "Subnet dedicated to the app gateway"
}

variable "public_ip_id" {
  type        = string
  description = "Public IP"
}

variable "backends" {
  type = map(object({
    protocol                    = string       # The Protocol which should be used. Possible values are Http and Https
    host                        = string       # The Hostname used for this Probe. If the Application Gateway is configured for a single site, by default the Host name should be specified as ‘127.0.0.1’, unless otherwise configured in custom probe. Cannot be set if pick_host_name_from_backend_http_settings is set to true
    port                        = number       # Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from http settings will be used.
    ip_addresses                = list(string) # A list of IP Addresses which should be part of the Backend Address Pool.
    fqdns                       = list(string) # A list of FQDN's which should be part of the Backend Address Pool.
    probe                       = string       # The Path used for this Probe.
    probe_name                  = string       # The Name of the Probe.
    request_timeout             = number       # The Timeout used for this Probe, which indicates when a probe becomes unhealthy. Possible values range from 1 second to a maximum of 86,400 seconds.
    pick_host_name_from_backend = bool         # Whether the host header should be picked from the backend http settings
  }))

  description = "Obj that allow to configure: backend_address_pool, backend_http_settings, probe"
}

variable "listeners" {
  type = map(object({
    protocol           = string                     # The Protocol which should be used. Possible values are Http and Https
    host               = string                     # The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to 'Multi site'.
    port               = number                     # The port used for this Frontend Port.
    ssl_profile_name   = string                     # The name of the associated SSL Profile which should be used for this HTTP Listener.
    firewall_policy_id = string                     # The ID of the Web Application Firewall Policy which should be used for this HTTP Listener.
    type               = optional(string, "Public") # The type of Listener "Public" - "Private"
    certificate = object({
      name = string # The Name of the SSL certificate that is unique within this Application Gateway
      id   = string # Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set.
    })
  }))
}

variable "ssl_profiles" {
  type = list(object({
    name                             = string       # The name of the SSL Profile that is unique within this Application Gateway.
    trusted_client_certificate_names = list(string) # The name of the Trusted Client Certificate that will be used to authenticate requests from clients.
    verify_client_cert_issuer_dn     = bool         # Should client certificate issuer DN be verified? Defaults to false

    ssl_policy = object({
      disabled_protocols   = list(string) # A list of SSL Protocols which should be disabled on this Application Gateway. Possible values are TLSv1_0, TLSv1_1 and TLSv1_2.
      policy_type          = string       # The Type of the Policy. Possible values are Predefined and Custom.
      policy_name          = string       # The Name of the Policy e.g AppGwSslPolicy20170401S. Required if policy_type is set to Predefined. Possible values can change over time and are published here https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview. Not compatible with disabled_protocols.
      cipher_suites        = list(string) # A List of accepted cipher suites. see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites for possible values
      min_protocol_version = string       # The minimal TLS version. Possible values are TLSv1_0, TLSv1_1 and TLSv1_2.
    })
  }))
  default = []
}

# Note: the attribute secret_name refers to the secret contaning the client certificate.
# Secrects'name in the key vault can't have low hyphens but just hyphens in it.
variable "trusted_client_certificates" {
  type = list(object({
    secret_name  = string # The name of the Trusted Client Certificate that is unique within this Application Gateway.
    key_vault_id = string # Key vault id, that contains the certificate.
  }))
}

variable "routes" {
  type = map(object({
    listener              = string # Prefix for http_listener_name
    backend               = string # Prefix for backend_address_pool_name, backend_http_settings_name
    rewrite_rule_set_name = string # The Name of the Rewrite Rule Set which should be used for this Routing Rule.
    priority              = number # Rule evaluation order can be dictated by specifying an integer value from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.
  }))
}

variable "routes_path_based" {
  description = "To configure path based routing"
  type = map(object({
    listener     = string # Prefix for http_listener_name
    url_map_name = string # The Name of the URL Path Map which should be associated with this Routing Rule.
    priority     = number # Rule evaluation order can be dictated by specifying an integer value from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.
  }))
  default = {}
}

variable "url_path_map" {
  type = map(object({
    default_backend               = string # Prefix for backend_address_pool_name, backend_http_settings_name
    default_rewrite_rule_set_name = string # The Name of the Rewrite Rule Set which should be used for this Routing Rule.
    path_rule = map(object({
      paths                 = list(string) # A list of Paths used in this Path Rule
      backend               = string
      rewrite_rule_set_name = string # The Name of the Rewrite Rule Set which should be used for this URL Path Map
    }))
  }))
  default     = {}
  description = "To configure the mapping between path and backend"
}

variable "rewrite_rule_sets" {
  type = list(object({
    name = string # Unique name of the rewrite rule set block
    rewrite_rules = list(object({
      name          = string     # Unique name of the rewrite rule block
      rule_sequence = number     # Rule sequence of the rewrite rule that determines the order of execution in a set.
      conditions = list(object({ # One or more condition blocks as defined above.
        variable    = string     # The variable of the condition.
        pattern     = string     # The pattern, either fixed string or regular expression, that evaluates the truthfulness of the condition.
        ignore_case = bool       # Perform a case in-sensitive comparison. Defaults to false
        negate      = bool       # Negate the result of the condition evaluation. Defaults to false
      }))

      request_header_configurations = list(object({
        header_name  = string # Header name of the header configuration.
        header_value = string # Header value of the header configuration. To delete a request header set this property to an empty string.
      }))

      response_header_configurations = list(object({
        header_name  = string # Header name of the header configuration.
        header_value = string # Header value of the header configuration. To delete a response header set this property to an empty string.
      }))

      url = object({
        path         = string                 # The URL path to rewrite.
        query_string = string                 # The query string to rewrite.
        reroute      = optional(bool, false)  # Whether the URL path map should be reevaluated after this rewrite has been applied.
        components   = optional(string, null) # The components used to rewrite the URL. Possible values are path_only and query_string_only to limit the rewrite to the URL Path or URL Query String only.
      })

    }))
  }))
  default     = []
  description = "Rewrite rules sets obj descriptor"
}

variable "custom_error_configurations" {
  type = list(object({
    status_code           = string # HTTP status code for which to display the error page
    custom_error_page_url = string # URL of the custom error page, must be publicly reachable
  }))
  default     = []
  description = "Configurations of custom error pages for common error status codes"

  validation {
    condition = alltrue([
      for c in var.custom_error_configurations : contains([
        # Commented statuses are available in azurerm provider v4
        # "HttpStatus400",
        "HttpStatus403",
        # "HttpStatus404",
        # "HttpStatus405",
        # "HttpStatus408",
        # "HttpStatus500",
        "HttpStatus502",
        # "HttpStatus503",
        # "HttpStatus504",
      ], c.status_code)
    ])
    error_message = "status_code must be one of HttpStatus403, HttpStatus502"
  }
}

# TLS

variable "identity_ids" {
  type = list(string)
}

# WAF
variable "waf_enabled" {
  type        = bool
  default     = true
  description = "Enable WAF"
}

variable "waf_disabled_rule_group" {
  type = list(object({
    rule_group_name = string       # The rule group where specific rules should be disabled.
    rules           = list(string) # A list of rules which should be disabled in that group. Disables all rules in the specified group if rules is not specified.
  }))
  default = []
}

variable "firewall_policy_id" {
  type        = string
  default     = null
  description = "(Optional) Id of the WAF policy to attach to the gateway"
}

# Scaling

variable "app_gateway_max_capacity" {
  type        = string
  description = "(Optional) Maximum capacity for autoscaling. Accepted values are in the range 2 to 125."
}

variable "app_gateway_min_capacity" {
  type        = string
  description = "(Required) Minimum capacity for autoscaling. Accepted values are in the range 0 to 100."
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

# Monitoring

variable "alerts_enabled" {
  type        = bool
  default     = true
  description = "Should Metric Alerts be enabled?"
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

variable "monitor_metric_alert_criteria" {
  default = {}

  description = <<EOD
Map of name = criteria objects, see these docs for options
https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported#microsoftnetworkapplicationgateways
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

    # static
    criteria = list(object(
      {
        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
        aggregation = string
        metric_name = string
        # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
        operator  = string
        threshold = number

        dimension = list(object(
          {
            name     = string
            operator = string
            values   = list(string)
          }
        ))
      }
    ))

    # dynamic
    dynamic_criteria = list(object(
      {
        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
        aggregation = string
        metric_name = string
        # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
        operator = string
        # Possible values are Low, Medium, High
        alert_sensitivity = string

        evaluation_total_count   = number
        evaluation_failure_count = number

        dimension = list(object(
          {
            name     = string
            operator = string
            values   = list(string)
          }
        ))
      }
    ))
  }))
}

variable "tags" {
  type = map(any)
}

variable "private_ip_address" {
  type        = list(string)
  description = "Private frontend ip"
  default     = []
  validation {
    condition     = length(var.private_ip_address) <= 1
    error_message = "Private IP address must contain at most one element"
  }
}