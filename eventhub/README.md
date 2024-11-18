# EventHub

This module allow the creation of a EventHub

## Architecture

![This is an image](./docs/module-arch.drawio.png)

## How to use it

see folder ../test for more info

## Migration

### Parameters

* `var.resource_group_name`: is used only for eventhub
** now every resource has it's own resource group variable

* `var.private_endpoint_created` is now mandatory to allow the creation of the private endpoint
* `var.private_endpoint_subnet_id`: subnet id for the private endpoint, and not `var.subnet_id` that is dropped
* private endpoint: now use `var.private_endpoint_resource_group_name` and not `var.resource_group_name``

* `var.internal_private_dns_zone_created`: allows the creation of private dns zone, default is FALSE
* private dns zone: now use `var.internal_private_dns_zone_resource_group_name` and not `var.resource_group_name``

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_dns_a_record.private_dns_a_record_eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br/>    {<br/>      action_group_id    = string<br/>      webhook_properties = map(string)<br/>    }<br/>  ))</pre> | `[]` | no |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | Should Metrics Alert be enabled? | `bool` | `true` | no |
| <a name="input_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#input\_auto\_inflate\_enabled) | Is Auto Inflate enabled for the EventHub Namespace? | `bool` | `false` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Specifies the Capacity / Throughput Units for a Standard SKU namespace. | `number` | `null` | no |
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | A list of event hubs to add to namespace. | <pre>list(object({<br/>    name              = string       # (Required) Specifies the name of the EventHub resource. Changing this forces a new resource to be created.<br/>    partitions        = number       # (Required) Specifies the current number of shards on the Event Hub.<br/>    message_retention = number       # (Required) Specifies the number of days to retain the events for this Event Hub.<br/>    consumers         = list(string) # Manages a Event Hubs Consumer Group as a nested resource within an Event Hub.<br/>    keys = list(object({<br/>      name   = string # (Required) Specifies the name of the EventHub Authorization Rule resource. Changing this forces a new resource to be created.<br/>      listen = bool   # (Optional) Does this Authorization Rule have permissions to Listen to the Event Hub? Defaults to false.<br/>      send   = bool   # (Optional) Does this Authorization Rule have permissions to Send to the Event Hub? Defaults to false.<br/>      manage = bool   # (Optional) Does this Authorization Rule have permissions to Manage to the Event Hub? When this property is true - both listen and send must be too. Defaults to false.<br/>    }))               # Manages a Event Hubs authorization Rule within an Event Hub.<br/>  }))</pre> | `[]` | no |
| <a name="input_internal_private_dns_zone_created"></a> [internal\_private\_dns\_zone\_created](#input\_internal\_private\_dns\_zone\_created) | (Deprecated: create a standalone dns zone) Choose to allow the creation of the dns zone | `bool` | `false` | no |
| <a name="input_internal_private_dns_zone_resource_group_name"></a> [internal\_private\_dns\_zone\_resource\_group\_name](#input\_internal\_private\_dns\_zone\_resource\_group\_name) | (Deprecated: create a standalone dns zone) Name of the resource group record in the private dns zone | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units) | Specifies the maximum number of throughput units when Auto Inflate is Enabled | `number` | `null` | no |
| <a name="input_metric_alerts"></a> [metric\_alerts](#input\_metric\_alerts) | Map of name = criteria objects | <pre>map(object({<br/>    # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br/>    aggregation = string<br/>    metric_name = string<br/>    description = string<br/>    # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br/>    operator  = string<br/>    threshold = number<br/>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br/>    frequency = string<br/>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br/>    window_size = string<br/><br/>    dimension = list(object(<br/>      {<br/>        name     = string<br/>        operator = string<br/>        values   = list(string)<br/>      }<br/>    ))<br/>  }))</pre> | `{}` | no |
| <a name="input_metric_alerts_create"></a> [metric\_alerts\_create](#input\_metric\_alerts\_create) | Create metric alerts | `bool` | `true` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | (Optional) The minimum supported TLS version for this EventHub Namespace. Valid values are: 1.0, 1.1 and 1.2. The current default minimum TLS version is 1.2. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Eventhub namespace description. | `string` | n/a | yes |
| <a name="input_network_rulesets"></a> [network\_rulesets](#input\_network\_rulesets) | n/a | <pre>list(object({<br/>    default_action = string #  (Required) The default action to take when a rule is not matched. Possible values are Allow and Deny.<br/>    virtual_network_rule = list(object({<br/>      subnet_id                                       = string # (Required) The id of the subnet to match on.<br/>      ignore_missing_virtual_network_service_endpoint = bool   # (Optional) Are missing virtual network service endpoints ignored?<br/>    }))<br/>    ip_rule = list(object({<br/>      ip_mask = string # (Required) The IP mask to match on.<br/>      action  = string # (Optional) The action to take when the rule is matched. Possible values are Allow. Defaults to Allow.<br/>    }))<br/>    trusted_service_access_enabled = bool #Whether Trusted Microsoft Services are allowed to bypass firewall.<br/>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zone_record_A_name"></a> [private\_dns\_zone\_record\_A\_name](#input\_private\_dns\_zone\_record\_A\_name) | Name of the A record in the private dns zone | `string` | `"eventhub"` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Private DNS Zones where the private endpoint will be created | <pre>object({<br/>    id                  = list(string)<br/>    name                = list(string)<br/>    resource_group_name = string<br/>  })</pre> | <pre>{<br/>  "id": [],<br/>  "name": [],<br/>  "resource_group_name": ""<br/>}</pre> | no |
| <a name="input_private_endpoint_created"></a> [private\_endpoint\_created](#input\_private\_endpoint\_created) | Choose to allow the creation of the private endpoint | `bool` | n/a | yes |
| <a name="input_private_endpoint_resource_group_name"></a> [private\_endpoint\_resource\_group\_name](#input\_private\_endpoint\_resource\_group\_name) | Name of the resource group where the private endpoint will be created | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | The id of the subnet that will be used for the private endpoint. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Is public network access enabled for the EventHub Namespace? Defaults to true. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | (Required) Defines which tier to use. Valid options are Basic and Standard. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_virtual_network_ids"></a> [virtual\_network\_ids](#input\_virtual\_network\_ids) | The IDs of the Virtual Network that should be linked to the DNS Zone. | `list(string)` | n/a | yes |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones). | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_ids"></a> [hub\_ids](#output\_hub\_ids) | Map of hubs and their ids. |
| <a name="output_key_ids"></a> [key\_ids](#output\_key\_ids) | List of key ids. |
| <a name="output_keys"></a> [keys](#output\_keys) | Map of hubs with keys => primary\_key / secondary\_key mapping. |
| <a name="output_name"></a> [name](#output\_name) | The name of this Event Hub |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | Id of Event Hub Namespace. |
| <a name="output_private_dns_zone"></a> [private\_dns\_zone](#output\_private\_dns\_zone) | ID of the private DNS zone which resolves the name of the Private Endpoint used to connect to EventHub |
<!-- END_TF_DOCS -->
