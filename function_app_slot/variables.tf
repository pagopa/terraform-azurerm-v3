variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "function_app_id" {
  type        = string
  description = "Id of the function app. (The production slot)"
}

variable "resource_group_name" {
  type = string
}

variable "runtime_version" {
  type    = string
  default = "~4"
}

variable "app_service_plan_id" {
  type        = string
  description = "The app service plan id to associate to the function."
  default     = null
}

variable "pre_warmed_instance_count" {
  type    = number
  default = 1
}

variable "always_on" {
  type        = bool
  description = "(Optional) Should the app be loaded at all times? Defaults to null."
  default     = null
}

variable "use_32_bit_worker_process" {
  type        = bool
  description = "(Optional) Should the Function App run in 32 bit mode, rather than 64 bit mode? Defaults to false."
  default     = false
}

variable "application_insights_instrumentation_key" {
  type = string
}

variable "app_settings" {
  type    = map(any)
  default = {}
}

variable "allowed_ips" {
  type        = list(string)
  default     = []
  description = "Ip from wich is allowed to call the function. An empty list means from everywhere."
}

variable "cors" {
  type = object({
    allowed_origins = list(string)
  })
  default = null
}

variable "allowed_subnets" {
  type        = list(string)
  default     = []
  description = "List of subnet ids which are allowed to call the function. An empty list means from each subnet."
}

variable "ip_restriction_default_action" {
  description = "(Optional) The Default action for traffic that does not match any ip_restriction rule. possible values include 'Allow' and 'Deny'. If not set, it will be set to Allow if no ip restriction rules have been configured."
  type        = string
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet the app service will be associated to (the subnet must have a service_delegation configured for Microsoft.Web/serverFarms)"
}

variable "vnet_integration" {
  type        = bool
  description = "(optional) Enable vnet integration. Wheter it's true the subnet_id should not be null."
  default     = true
}

variable "os_type" {
  type        = string
  description = "(Optional) A string indicating the Operating System type for this function app. This value will be linux for Linux derivatives, or an empty string for Windows (default). When set to linux you must also set azurerm_app_service_plan arguments as kind = Linux and reserved = true"
  default     = null
}

variable "https_only" {
  type        = bool
  description = "(Required) n the Function App only be accessed via HTTPS? Defaults to true."
  default     = true
}

variable "storage_account_name" {
  type        = string
  description = "Storage account in use by the function."
  default     = null
}

variable "storage_account_access_key" {
  type        = string
  description = "Access key of the sorege account used by the function."
  default     = null
}

variable "internal_storage_connection_string" {
  type        = string
  description = "Storage account connection string for durable functions. Null in case of standard function"
  default     = null
}

variable "auto_swap_slot_name" {
  type        = string
  description = "The name of the slot to automatically swap to during deployment"
  default     = null
}

variable "health_check_path" {
  type        = string
  default     = null
  description = "Path which will be checked for this function app health."
}

variable "health_check_maxpingfailures" {
  type        = number
  description = "Max ping failures allowed"
  default     = 10

  validation {
    condition     = var.health_check_maxpingfailures == null ? true : (var.health_check_maxpingfailures >= 2 && var.health_check_maxpingfailures <= 10)
    error_message = "Possible values are null or a number between 2 and 10"
  }
}

variable "export_keys" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(any)
}

variable "client_certificate_enabled" {
  type        = bool
  description = "Should the function app use Client Certificates"
  default     = false
}

######################
# Framework choice
######################
variable "docker" {
  type    = any
  default = {}
}
variable "dotnet_version" {
  type    = string
  default = null
}
variable "use_dotnet_isolated_runtime" {
  type    = string
  default = null
}
variable "java_version" {
  type    = string
  default = null
}
variable "node_version" {
  type    = string
  default = null
}
variable "python_version" {
  type    = string
  default = null
}
variable "powershell_core_version" {
  type    = string
  default = null
}
variable "use_custom_runtime" {
  type    = string
  default = null
}
variable "system_identity_enabled" {
  type        = bool
  description = "Enable the System Identity and create relative Service Principal."
  default     = false
}
