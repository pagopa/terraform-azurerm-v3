# Data indexer

This module allow the creation of an app service.
In terraform output you can get the the app service's name and id.

## How to use it
Use the example Terraform template, saved in `./tests`, to test this module and get some advices.

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.39.0, <= 3.84.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_internal_storage_account"></a> [internal\_storage\_account](#module\_internal\_storage\_account) | ../storage_account | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_web_app.cdc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_linux_web_app.data_ti](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_monitor_autoscale_setting.appservice_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_private_endpoint.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.evh_listener](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.evh_sender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_eventhub.evh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | n/a | <pre>object({<br>    sku_name                 = optional(string, "P0v3")<br>    app_settings             = optional(map(string), {})<br>    allowed_subnets          = optional(list(string), [])<br>    allowed_ips              = optional(list(string), [])<br>    docker_registry_url      = optional(string, "http://ghcr.io")<br>    cdc_docker_image         = optional(string, "pagopa/change-data-capturer-ms")<br>    cdc_docker_image_tag     = optional(string, "0.1.0@sha256:94379d99d78062e89353b45d6b463cd7bf80e24869b7d2d1a8b7cbf316fd07e4")<br>    data_ti_docker_image     = optional(string, "pagopa/data-ti-ms")<br>    data_ti_docker_image_tag = optional(string, "0.1.0@sha256:dc7b8cee0aa1e22658f61a0d5d19be44202f83f0533f35de2ef0eb87697cdb94")<br>    autoscale_minimum        = optional(number, 1)<br>    autoscale_maximum        = optional(number, 20)<br>    autoscale_default        = optional(number, 5)<br>    json_config_path         = string<br>  })</pre> | n/a | yes |
| <a name="input_evh_config"></a> [evh\_config](#input\_evh\_config) | The Internal Event Hubs (topics) configuration | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>    topics              = set(string)<br>  })</pre> | n/a | yes |
| <a name="input_internal_storage"></a> [internal\_storage](#input\_internal\_storage) | # Internal Storage | <pre>object({<br>    account_kind               = optional(string, "StorageV2") # Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Changing this forces a new resource to be created. Defaults to Storage.<br>    account_tier               = optional(string, "Standard")  # Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.<br>    account_replication_type   = optional(string, "ZRS")       # Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.<br>    access_tier                = optional(string, "Hot")       # Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot.<br>    private_dns_zone_blob_ids  = optional(list(string), [])<br>    private_dns_zone_queue_ids = optional(list(string), [])<br>    private_dns_zone_table_ids = optional(list(string), [])<br>    private_endpoint_subnet_id = optional(string, "")<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | `"northitaly"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Specifies the name of the App Service. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | n/a | <pre>object({<br>    address_prefixes = list(string)<br>    service_endpoints = optional(list(string), [<br>      "Microsoft.Web",<br>      "Microsoft.AzureCosmosDB",<br>      "Microsoft.Storage",<br>      "Microsoft.Sql",<br>      "Microsoft.EventHub"<br>    ])<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_virtual_network"></a> [virtual\_network](#input\_virtual\_network) | n/a | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
