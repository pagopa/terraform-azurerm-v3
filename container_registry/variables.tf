variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type        = string
  description = "(Required) The SKU name of the container registry. Possible values are Basic, Standard and Premium."
  default     = "Premium"
}

variable "zone_redundancy_enabled" {
  type        = string
  description = "(Optional) Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created. Defaults to false."
  default     = true
}

variable "admin_enabled" {
  type        = bool
  description = "(Optional) Specifies whether the admin user is enabled. Defaults to false."
  default     = false
}

variable "anonymous_pull_enabled" {
  type        = bool
  description = "(Optional) Whether allows anonymous (unauthenticated) pull access to this Container Registry? Defaults to false. This is only supported on resources with the Standard or Premium SKU."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Whether public network access is allowed for the container registry. Defaults to true."
  default     = false
}

variable "network_rule_bypass_option" {
  type        = string
  description = "(Optional) Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are None and AzureServices. Defaults to AzureServices."
  default     = "AzureServices"
}

variable "georeplications" {
  type = list(object({
    location                  = string
    regional_endpoint_enabled = bool
    zone_redundancy_enabled   = bool
  }))
  description = "A list of Azure locations where the container registry should be geo-replicated."
  default     = []
}

variable "network_rule_set" {
  type = list(object({
    default_action = string
    ip_rule = list(object({
      action   = string
      ip_range = string
    }))
    virtual_network = list(object({
      action    = string
      subnet_id = string
    }))
  }))
  description = "A list of network rule set defined at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry#network_rule_set"
  default = [{
    default_action  = "Deny"
    ip_rule         = []
    virtual_network = []
  }]
}

variable "private_endpoint_enabled" {
  type = bool
  description = "Enable private endpoint, default: true"
  default = true
}

variable "private_endpoint" {
  type = object({
    virtual_network_id   = string
    subnet_id            = string
    private_dns_zone_ids = list(string)
  })
  default = {
    virtual_network_id   = null
    subnet_id            = null
    private_dns_zone_ids = [""]
  }

  description = "(Required) Enable and configure private endpoint with required params"
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

variable "monitor_diagnostic_setting_enabled" {
  type = bool
  description = "Enable monitor diagnostic setting"
  default = false
}
