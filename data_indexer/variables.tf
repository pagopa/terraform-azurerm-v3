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

variable "sku_name" {
  type        = string
  description = "(Required) The SKU for the plan."
  default     = "P0v3"
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

variable "tags" {
  type = map(any)
}

# Subnet

variable "virtual_network" {
  type = object({
    name                = string
    resource_group_name = string
  })
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
  default = "0.1.0@sha256:94379d99d78062e89353b45d6b463cd7bf80e24869b7d2d1a8b7cbf316fd07e4"
}

variable "data_ti_docker_image" {
  type    = string
  default = "pagopa/data-ti-ms"
}
variable "data_ti_docker_image_tag" {
  type    = string
  default = "0.1.0@sha256:dc7b8cee0aa1e22658f61a0d5d19be44202f83f0533f35de2ef0eb87697cdb94"
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