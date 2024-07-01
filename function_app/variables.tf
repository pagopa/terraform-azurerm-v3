variable "location" {
  type = string
}

variable "name" {
  type        = string
  description = "(Required) Specifies the name of the Function App. Changing this forces a new resource to be created."
}

variable "domain" {
  type        = string
  description = "Specifies the domain of the Function App."
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name. If null it will be 'computed'"
  default     = null
}

variable "storage_account_durable_name" {
  type        = string
  description = "Storage account name only used by the durable function. If null it will be 'computed'"
  default     = null
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of the app service plan. If null it will be 'computed'"
  default     = null
}

variable "resource_group_name" {
  type = string
}

variable "runtime_version" {
  type        = string
  default     = "~3"
  description = "The runtime version associated with the Function App. Version ~3 is required for Linux Function Apps."
}

variable "storage_account_info" {
  type = object({
    account_kind                      = string # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.
    account_tier                      = string # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_replication_type          = string # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.
    access_tier                       = string # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.
    advanced_threat_protection_enable = bool
    use_legacy_defender_version       = bool
    public_network_access_enabled     = bool
  })

  default = {
    account_kind                      = "StorageV2"
    account_tier                      = "Standard"
    account_replication_type          = "ZRS"
    access_tier                       = "Hot"
    advanced_threat_protection_enable = true
    use_legacy_defender_version       = true
    public_network_access_enabled     = false
  }
}

variable "internal_storage_account_info" {
  type = object({
    account_kind                      = string # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.
    account_tier                      = string # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_replication_type          = string # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.
    access_tier                       = string # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.
    advanced_threat_protection_enable = bool
    use_legacy_defender_version       = bool
    public_network_access_enabled     = bool
  })

  default = null
}

variable "app_service_plan_id" {
  type        = string
  description = "The external app service plan id to associate to the function. If null a new plan is created, use app_service_plan_info to configure it."
  default     = null
}

variable "app_service_plan_info" {
  type = object({
    kind                         = string # The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan).
    sku_size                     = string # Specifies the plan's instance size.
    maximum_elastic_worker_count = number # The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan.
    worker_count                 = number # The number of Workers (instances) to be allocated.
    zone_balancing_enabled       = bool   # Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created.
  })

  description = "Allows to configurate the internal service plan"

  default = {
    kind                         = "Linux"
    sku_size                     = "P1v3"
    maximum_elastic_worker_count = 0
    worker_count                 = 0
    zone_balancing_enabled       = false
  }
}

variable "pre_warmed_instance_count" {
  type        = number
  description = "The number of pre-warmed instances for this function app. Only affects apps on the Premium plan."
  default     = 1
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
  type        = string
  description = "Application insights instrumentation key"
}

variable "app_settings" {
  type        = map(any)
  description = "(Optional) A map of key-value pairs for App Settings and custom values."
  default     = {}
}

variable "https_only" {
  type        = bool
  description = "(Required) Can the Function App only be accessed via HTTPS?. Defaults true"
  default     = true
}

variable "allowed_ips" {
  // List of ip
  type        = list(string)
  description = "The IP Address used for this IP Restriction in CIDR notation"
  default     = []
}

variable "allowed_subnets" {
  type        = list(string)
  description = "List of subnet ids, The Virtual Network Subnet ID used for this IP Restriction."
  default     = []
}

variable "ip_restriction_default_action" {
  description = "(Optional) The Default action for traffic that does not match any ip_restriction rule. possible values include 'Allow' and 'Deny'. If not set, it will be set to Allow if no ip restriction rules have been configured."
  type        = string
  default     = null
}

variable "cors" {
  type = object({
    allowed_origins = list(string) # A list of origins which should be able to make cross-origin calls. * can be used to allow all calls.
  })
  default = null
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

variable "internal_storage" {
  type = object({
    enable                     = bool
    private_endpoint_subnet_id = string
    private_dns_zone_blob_ids  = list(string)
    private_dns_zone_queue_ids = list(string)
    private_dns_zone_table_ids = list(string)
    queues                     = list(string) # Queues names
    containers                 = list(string) # Containers names
    blobs_retention_days       = number
  })

  default = {
    enable                     = false
    private_endpoint_subnet_id = "dummy"
    private_dns_zone_blob_ids  = []
    private_dns_zone_queue_ids = []
    private_dns_zone_table_ids = []
    queues                     = []
    containers                 = []
    blobs_retention_days       = 1
  }
}

variable "health_check_path" {
  type        = string
  description = "Path which will be checked for this function app health."
  default     = null
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

variable "system_identity_enabled" {
  type        = bool
  description = "Enable the System Identity and create relative Service Principal."
  default     = false
}

variable "client_certificate_enabled" {
  type        = bool
  description = "Should the function app use Client Certificates"
  default     = false
}

variable "client_certificate_mode" {
  type        = string
  default     = "Optional"
  description = "(Optional) The mode of the Function App's client certificates requirement for incoming requests. Possible values are Required, Optional, and OptionalInteractiveUser."
}

variable "sticky_app_setting_names" {
  type        = list(string)
  description = "(Optional) A list of app_setting names that the Linux Function App will not swap between Slots when a swap operation is triggered"
  default     = []
}

variable "sticky_connection_string_names" {
  type        = list(string)
  description = "(Optional) A list of connection string names that the Linux Function App will not swap between Slots when a swap operation is triggered"
  default     = null
}

variable "app_service_logs" {
  type = object({
    disk_quota_mb         = number
    retention_period_days = number
  })
  description = "disk_quota_mb - (Optional) The amount of disk space to use for logs. Valid values are between 25 and 100. Defaults to 35. retention_period_days - (Optional) The retention period for logs in days. Valid values are between 0 and 99999.(never delete)."
  default     = null
}

variable "enable_function_app_public_network_access" {
  type        = bool
  description = "(Optional) Should public network access be enabled for the Function App. Defaults to true."
  default     = true
}

# -------------------
# Alerts variables
# -------------------

variable "enable_healthcheck" {
  type        = bool
  description = "Enable the healthcheck alert. Default is true"
  default     = true
}

variable "healthcheck_threshold" {
  type        = number
  description = "The healthcheck threshold. If metric average is under this value, the alert will be triggered. Default is 50"
  default     = 50
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
