variable "name" {
  type        = string
  description = "(Required) Specifies the name of the App Service. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  default     = "northitaly"
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

## Internal Storage
variable "internal_storage" {
  type = object({
    account_kind               = optional(string, "StorageV2") # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.
    account_tier               = optional(string, "Standard")  # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_replication_type   = optional(string, "ZRS")       # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.
    access_tier                = optional(string, "Hot")       # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.
    private_dns_zone_blob_ids  = optional(list(string), [])
    private_dns_zone_queue_ids = optional(list(string), [])
    private_dns_zone_table_ids = optional(list(string), [])
    private_endpoint_subnet_id = optional(string, "")
  })
}

## App service

variable "config" {
  type = object({
    sku_name                 = optional(string, "P0v3")
    app_settings             = optional(map(string), {})
    allowed_subnets          = optional(list(string), [])
    allowed_ips              = optional(list(string), [])
    docker_registry_url      = optional(string, "http://ghcr.io")
    cdc_docker_image         = optional(string, "pagopa/change-data-capturer-ms")
    cdc_docker_image_tag     = optional(string, "0.1.0@sha256:94379d99d78062e89353b45d6b463cd7bf80e24869b7d2d1a8b7cbf316fd07e4")
    data_ti_docker_image     = optional(string, "pagopa/data-ti-ms")
    data_ti_docker_image_tag = optional(string, "0.1.0@sha256:dc7b8cee0aa1e22658f61a0d5d19be44202f83f0533f35de2ef0eb87697cdb94")
    autoscale_minimum        = optional(number, 1)
    autoscale_maximum        = optional(number, 20)
    autoscale_default        = optional(number, 5)
    json_config_path         = string
  })
}

# Networking

variable "virtual_network" {
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "subnet" {
  type = object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [
      "Microsoft.Web",
      "Microsoft.AzureCosmosDB",
      "Microsoft.Storage",
      "Microsoft.Sql",
      "Microsoft.EventHub"
    ])
  })
}

# Event Hub
variable "evh_config" {
  type = object({
    hub_ids = map(string)
    topics  = set(string)
  })
  description = "The Internal Event Hubs (topics) configuration and related ids"
}

# tag

variable "tags" {
  type = map(any)
}