variable "location" {
  type        = string
  default     = "northitaly"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the App Service and App Service Plan."
}

## Internal Storage

variable "private_endpoint_subnet_id" {
  type        = string
  description = "(Required) The ID of the private endpoints subnet to use"
}
variable "internal_storage" {
  type = object({
    private_dns_zone_blob_ids  = list(string)
    private_dns_zone_queue_ids = list(string)
    private_dns_zone_table_ids = list(string)

  })

  default = {
    private_dns_zone_blob_ids  = []
    private_dns_zone_queue_ids = []
    private_dns_zone_table_ids = []
  }
}

variable "internal_storage_account_info" {
  type = object({
    account_kind             = string # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.
    account_tier             = string # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_replication_type = string # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.
    access_tier              = string # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.
  })

  default = {
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "GZRS"
    access_tier              = "Hot"
  }
}

## App service plan

variable "plan_type" {
  type        = string
  description = "(Required) Specifies if app service plan is external or internal"
  validation {
    condition = (
      var.plan_type == "internal" ||
      var.plan_type == "external"
    )
    error_message = "Plan type can be only internal or external."
  }
  default = "internal"
}

variable "plan_id" {
  type        = string
  description = "(Optional only if plan_type=internal) Specifies the external app service plan id."
  default     = null
}

variable "plan_name" {
  type        = string
  description = "(Optional) Specifies the name of the App Service Plan component. Changing this forces a new resource to be created."
  default     = null
}

variable "plan_kind" {
  type        = string
  description = "(Optional) The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux, elastic (for Premium Consumption) and FunctionApp (for a Consumption Plan). Changing this forces a new resource to be created."
  default     = null
}

variable "sku_name" {
  type        = string
  description = "(Required) The SKU for the plan."
  default     = "P0v3"
}

variable "sticky_settings" {
  type        = list(string)
  description = "(Optional) A list of app_setting names that the Linux Function App will not swap between Slots when a swap operation is triggered"
  default     = []
}

variable "plan_maximum_elastic_worker_count" {
  type        = number
  description = "(Optional) The maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan."
  default     = null
}

variable "plan_per_site_scaling" {
  type        = bool
  description = "(Optional) Can Apps assigned to this App Service Plan be scaled independently? If set to false apps assigned to this plan will scale to all instances of the plan. Defaults to false."
  default     = false
}

## App service

variable "name" {
  type        = string
  description = "(Required) Specifies the name of the App Service. Changing this forces a new resource to be created."
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "health_check_path" {
  type        = string
  description = "(Optional) The health check path to be pinged by App Service."
  default     = null
}

variable "health_check_maxpingfailures" {
  type        = number
  description = "Max ping failures allowed"
  default     = null

  validation {
    condition     = var.health_check_maxpingfailures == null ? true : (var.health_check_maxpingfailures >= 2 && var.health_check_maxpingfailures <= 10)
    error_message = "Possible values are null or a number between 2 and 10"
  }
}

variable "allowed_subnets" {
  type        = list(string)
  description = "(Optional) List of subnet allowed to call the appserver endpoint."
  default     = []
}

variable "allowed_ips" {
  type        = list(string)
  description = "(Optional) List of ips allowed to call the appserver endpoint."
  default     = []
}

variable "vnet_integration" {
  type        = bool
  description = "(optional) enable vnet integration. Wheter it's true the subnet_id should not be null."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "(Optional) Subnet id wether you want to integrate the app service to a subnet."
  default     = null
}

variable "tags" {
  type = map(any)
}

# Subnet

variable "subnet_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "address_prefixes" {
  type        = list(string)
  description = "(Optional) The address prefixes to use for the subnet. (e.g. ['10.1.137.0/24'])"
  default     = []
}

variable "service_endpoints" {
  type = list(string)
  default = [
    "Microsoft.Web",
    "Microsoft.AzureCosmosDB",
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.EventHub"
  ]
  description = "(Optional) The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
}
##########

# Framework choice

variable "docker_registry_url" {
  type    = string
  default = "http://ghcr.io/"
}
variable "cdc_docker_image" {
  type    = string
  default = "pagopa/change-data-capturer-ms"
}
variable "cdc_docker_image_tag" {
  type    = string
  default = "0.1.0"
}

variable "data_ti_docker_image" {
  type    = string
  default = "pagopa/data-ti-ms"
}
variable "data_ti_docker_image_tag" {
  type    = string
  default = "0.1.0"
}

# Scaling rules

variable "autoscale_minimum" {
  type        = number
  description = "The minimum number of instances for this resource."
  default     = 1
}

variable "autoscale_maximum" {
  type        = number
  description = "The maximum number of instances for this resource."
  default     = 20
}

variable "autoscale_default" {
  type        = number
  description = "The number of instances that are available for scaling if metrics are not available for evaluation."
  default     = 5
}

# Event Hub
variable "evh_config" {
  type = object({
    name                = string
    resource_group_name = string
    topics              = set(string)
  })
  description = "The Internal Event Hubs (topics) configuration"
}

# App service JSON CONFIG

variable "json_config_path" {
  type        = string
  description = "The Internal JSON configuration file path"
}