variable "name" {
  type        = string
  description = "Eventhub namespace description."
}

variable "location" {
  type = string
}

// Resource Group
variable "resource_group_name" {
  type = string
}

variable "virtual_network_ids" {
  type        = list(string)
  description = "The IDs of the Virtual Network that should be linked to the DNS Zone."
}

variable "auto_inflate_enabled" {
  type        = bool
  description = "Is Auto Inflate enabled for the EventHub Namespace?"
  default     = false
}

variable "eventhubs" {
  description = "A list of event hubs to add to namespace."
  type = list(object({
    name              = string       # (Required) Specifies the name of the EventHub resource. Changing this forces a new resource to be created.
    partitions        = number       # (Required) Specifies the current number of shards on the Event Hub.
    message_retention = number       # (Required) Specifies the number of days to retain the events for this Event Hub.
    consumers         = list(string) # Manages a Event Hubs Consumer Group as a nested resource within an Event Hub.
    keys = list(object({
      name   = string # (Required) Specifies the name of the EventHub Authorization Rule resource. Changing this forces a new resource to be created.
      listen = bool   # (Optional) Does this Authorization Rule have permissions to Listen to the Event Hub? Defaults to false.
      send   = bool   # (Optional) Does this Authorization Rule have permissions to Send to the Event Hub? Defaults to false.
      manage = bool   # (Optional) Does this Authorization Rule have permissions to Manage to the Event Hub? When this property is true - both listen and send must be too. Defaults to false.
    }))               # Manages a Event Hubs authorization Rule within an Event Hub.
  }))
  default = []
}

variable "sku" {
  type        = string
  description = "(Required) Defines which tier to use. Valid options are Basic and Standard."
}

variable "capacity" {
  type        = number
  description = "Specifies the Capacity / Throughput Units for a Standard SKU namespace."
  default     = null
}

variable "maximum_throughput_units" {
  type        = number
  description = "Specifies the maximum number of throughput units when Auto Inflate is Enabled"
  default     = null
}

variable "network_rulesets" {
  type = list(object({
    default_action = string #  (Required) The default action to take when a rule is not matched. Possible values are Allow and Deny.
    virtual_network_rule = list(object({
      subnet_id                                       = string # (Required) The id of the subnet to match on.
      ignore_missing_virtual_network_service_endpoint = bool   # (Optional) Are missing virtual network service endpoints ignored?
    }))
    ip_rule = list(object({
      ip_mask = string # (Required) The IP mask to match on.
      action  = string # (Optional) The action to take when the rule is matched. Possible values are Allow. Defaults to Allow.
    }))
    trusted_service_access_enabled = bool #Whether Trusted Microsoft Services are allowed to bypass firewall.
  }))
  default = []
}

variable "zone_redundant" {
  type        = bool
  default     = true
  description = "Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones)."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "(Optional) The minimum supported TLS version for this EventHub Namespace. Valid values are: 1.0, 1.1 and 1.2. The current default minimum TLS version is 1.2."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Is public network access enabled for the EventHub Namespace? Defaults to true."
}

#
# Private endpoint
#

# If this variable contains empty arrays as in the default value a new private DNS Zone will be created
variable "private_dns_zones" {
  description = "Private DNS Zones where the private endpoint will be created"
  type = object({
    id                  = list(string)
    name                = list(string)
    resource_group_name = string
  })
  default = {
    id                  = []
    name                = []
    resource_group_name = ""
  }
}

variable "private_dns_zone_record_A_name" {
  description = "Name of the A record in the private dns zone"
  type        = string
  default     = "eventhub"

}

variable "private_endpoint_created" {
  description = "Choose to allow the creation of the private endpoint"
  type        = bool
}

variable "private_endpoint_resource_group_name" {
  description = "Name of the resource group where the private endpoint will be created"
  type        = string
  default     = null
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "The id of the subnet that will be used for the private endpoint."
}


variable "internal_private_dns_zone_created" {
  description = "(Deprecated: create a standalone dns zone) Choose to allow the creation of the dns zone"
  type        = bool
  default     = false
}

variable "internal_private_dns_zone_resource_group_name" {
  description = "(Deprecated: create a standalone dns zone) Name of the resource group record in the private dns zone"
  type        = string
  default     = null
}

#
# Alerts
#
variable "metric_alerts" {
  default = {}

  description = <<EOD
Map of name = criteria objects
EOD

  type = map(object({
    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]
    aggregation = string
    metric_name = string
    description = string
    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]
    operator  = string
    threshold = number
    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H
    frequency = string
    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.
    window_size = string

    dimension = list(object(
      {
        name     = string
        operator = string
        values   = list(string)
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

variable "alerts_enabled" {
  type        = bool
  default     = true
  description = "Should Metrics Alert be enabled?"
}

variable "tags" {
  type = map(any)
}
