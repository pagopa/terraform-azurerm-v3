variable "prefix" {
  type = string
}
variable "name" {
  type = string
}

variable "tenant_id" {
  type    = string
  default = null
}

variable "storage_account_kind" {
  type    = string
  default = "StorageV2"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication_type" {
  type    = string
  default = "GRS"
}

variable "storage_access_tier" {
  type    = string
  default = "Hot"
}

variable "location" {
  type = string
}

variable "cdn_location" {
  type        = string
  default     = null
  description = "If the location of the CDN needs to be different from that of the storage account, set this variable to the location where the CDN should be created. For example, cdn_location = westeurope and location = northitaly"
}
variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "querystring_caching_behaviour" {
  type    = string
  default = "IgnoreQueryString"
}

variable "global_delivery_rule" {
  type = object({
    cache_expiration_action = list(object({
      behavior = string
      duration = string
    }))
    cache_key_query_string_action = list(object({
      behavior   = string
      parameters = string
    }))
    modify_request_header_action = list(object({
      action = string
      name   = string
      value  = string
    }))
    modify_response_header_action = list(object({
      action = string
      name   = string
      value  = string
    }))
  })
  # TODO improvements
  # validation {
  #   condition = (
  #     length(var.global_delivery_rule.modify_response_header_action[*].value) <= 128
  #   )
  #   error_message = "Max length is 128 chars."
  # }
  default = null
}

variable "delivery_rule_url_path_condition_cache_expiration_action" {
  type = list(object({
    name            = string
    order           = number
    operator        = string
    match_values    = list(string)
    behavior        = string
    duration        = string
    response_action = string
    response_name   = string
    response_value  = string
  }))
  default = []
}

variable "delivery_rule_request_scheme_condition" {
  type = list(object({
    name         = string
    order        = number
    operator     = string
    match_values = list(string)
    url_redirect_action = object({
      redirect_type = string
      protocol      = string
      hostname      = string
      path          = string
      fragment      = string
      query_string  = string
    })
  }))
  default = []
}

variable "delivery_rule_redirect" {
  type = list(object({
    name         = string
    order        = number
    operator     = string
    match_values = list(string)
    url_redirect_action = object({
      redirect_type = string
      protocol      = string
      hostname      = string
      path          = string
      fragment      = string
      query_string  = string
    })
  }))
  default = []
}

variable "delivery_rule_rewrite" {
  type = list(object({
    name  = string
    order = number
    conditions = list(object({
      condition_type   = string
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))
    url_rewrite_action = object({
      source_pattern          = string
      destination             = string
      preserve_unmatched_path = string
    })
  }))
  default = []
}

variable "delivery_rule" {
  type = list(object({
    name  = string
    order = number

    // start conditions
    cookies_conditions = list(object({
      selector         = string
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    device_conditions = list(object({
      operator         = string
      match_values     = string
      negate_condition = bool
    }))

    http_version_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
    }))

    post_arg_conditions = list(object({
      selector         = string
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    query_string_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    remote_address_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
    }))

    request_body_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    request_header_conditions = list(object({
      selector         = string
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    request_method_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
    }))

    request_scheme_conditions = list(object({
      operator         = string
      match_values     = string
      negate_condition = bool
    }))

    request_uri_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    url_file_extension_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    url_file_name_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))

    url_path_conditions = list(object({
      operator         = string
      match_values     = list(string)
      negate_condition = bool
      transforms       = list(string)
    }))
    // end conditions

    // start actions
    cache_expiration_actions = list(object({
      behavior = string
      duration = string
    }))

    cache_key_query_string_actions = list(object({
      behavior   = string
      parameters = string
    }))

    modify_request_header_actions = list(object({
      action = string
      name   = string
      value  = string
    }))

    modify_response_header_actions = list(object({
      action = string
      name   = string
      value  = string
    }))

    url_redirect_actions = list(object({
      redirect_type = string
      protocol      = string
      hostname      = string
      path          = string
      fragment      = string
      query_string  = string
    }))

    url_rewrite_actions = list(object({
      source_pattern          = string
      destination             = string
      preserve_unmatched_path = string
    }))
    // end actions
  }))
  default = []
}

variable "https_rewrite_enabled" {
  type    = bool
  default = true
}

variable "hostname" {
  type = string
}

variable "index_document" {
  type = string
}

variable "error_404_document" {
  type = string
}

variable "keyvault_resource_group_name" {
  type        = string
  description = "Key vault resource group name"
}

variable "keyvault_subscription_id" {
  type        = string
  description = "Key vault subscription id"
}

variable "keyvault_vault_name" {
  type        = string
  description = "Key vault name"
}

variable "keyvault_id" {
  type        = string
  description = "Key vault id"
  default     = null
}

variable "azuread_service_principal_azure_cdn_frontdoor_id" {
  type        = string
  description = "Azure CDN Front Door Principal ID - Microsoft.AzureFrontDoor-Cdn"
  default     = null
}

variable "custom_hostname_kv_enabled" {
  type        = bool
  default     = false
  description = "Flag required to enable the association between KV certificate and CDN when the hostname is different from the APEX"
}

variable "dns_zone_name" {
  type = string
}

variable "dns_zone_resource_group_name" {
  type = string
}

variable "advanced_threat_protection_enabled" {
  type    = bool
  default = false
}

variable "storage_account_nested_items_public" {
  type        = bool
  default     = true
  description = "(Optional) reflects to property 'allow_nested_items_to_be_public' on storage account module"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace id to send logs to"
}
