# EventHub

This module allow the creation of a EventHub

## How to use it

See `tests` folder for example and how to use it

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.events](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_hub_namespace_name"></a> [event\_hub\_namespace\_name](#input\_event\_hub\_namespace\_name) | EventHub namespace name | `string` | n/a | yes |
| <a name="input_event_hub_namespace_resource_group_name"></a> [event\_hub\_namespace\_resource\_group\_name](#input\_event\_hub\_namespace\_resource\_group\_name) | EventHub namespace resource group name | `string` | n/a | yes |
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | A list of event hubs to add to namespace. | <pre>list(object({<br>    name              = string       # (Required) Specifies the name of the EventHub resource. Changing this forces a new resource to be created.<br>    partitions        = number       # (Required) Specifies the current number of shards on the Event Hub.<br>    message_retention = number       # (Required) Specifies the number of days to retain the events for this Event Hub.<br>    consumers         = list(string) # Manages a Event Hubs Consumer Group as a nested resource within an Event Hub.<br>    keys = list(object({<br>      name   = string # (Required) Specifies the name of the EventHub Authorization Rule resource. Changing this forces a new resource to be created.<br>      listen = bool   # (Optional) Does this Authorization Rule have permissions to Listen to the Event Hub? Defaults to false.<br>      send   = bool   # (Optional) Does this Authorization Rule have permissions to Send to the Event Hub? Defaults to false.<br>      manage = bool   # (Optional) Does this Authorization Rule have permissions to Manage to the Event Hub? When this property is true - both listen and send must be too. Defaults to false.<br>    }))               # Manages a Event Hubs authorization Rule within an Event Hub.<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_ids"></a> [hub\_ids](#output\_hub\_ids) | Map of hubs and their ids. |
| <a name="output_key_ids"></a> [key\_ids](#output\_key\_ids) | List of key ids. |
| <a name="output_keys"></a> [keys](#output\_keys) | Map of hubs with keys => primary\_key / secondary\_key mapping. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
