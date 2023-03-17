# Virtual network peering

This module allow the creation of a virtual network peering

## How to use it

```ts
module "vnet_peering_core_2_aks" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//virtual_network_peering?ref=v3.15.0"

  for_each = { for n in var.aks_networks : n.domain_name => n }

  location = var.location

  source_resource_group_name       = data.azurerm_resource_group.rg_vnet.name
  source_virtual_network_name      = data.azurerm_virtual_network.vnet.name
  source_remote_virtual_network_id = data.azurerm_virtual_network.vnet.id
  source_allow_gateway_transit     = false # needed by vpn gateway for enabling routing from vnet to vnet_integration

  target_resource_group_name       = azurerm_resource_group.rg_vnet_aks[each.key].name
  target_virtual_network_name      = module.vnet_aks[each.key].name
  target_remote_virtual_network_id = module.vnet_aks[each.key].id
  target_use_remote_gateways       = false # needed by vpn gateway for enabling routing from vnet to vnet_integration
}
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.45.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.source](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.target](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_source_allow_forwarded_traffic"></a> [source\_allow\_forwarded\_traffic](#input\_source\_allow\_forwarded\_traffic) | Controls if forwarded traffic from VMs in the remote virtual network is allowed. | `bool` | `false` | no |
| <a name="input_source_allow_gateway_transit"></a> [source\_allow\_gateway\_transit](#input\_source\_allow\_gateway\_transit) | Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network. | `bool` | `false` | no |
| <a name="input_source_allow_virtual_network_access"></a> [source\_allow\_virtual\_network\_access](#input\_source\_allow\_virtual\_network\_access) | Controls if the VMs in the remote virtual network can access VMs in the local virtual network. | `bool` | `true` | no |
| <a name="input_source_remote_virtual_network_id"></a> [source\_remote\_virtual\_network\_id](#input\_source\_remote\_virtual\_network\_id) | The full Azure resource ID of the remote virtual network from which the peering starts. | `string` | n/a | yes |
| <a name="input_source_resource_group_name"></a> [source\_resource\_group\_name](#input\_source\_resource\_group\_name) | The name of the resource group in which to start the virtual network peering | `string` | n/a | yes |
| <a name="input_source_use_remote_gateways"></a> [source\_use\_remote\_gateways](#input\_source\_use\_remote\_gateways) | Controls if remote gateways can be used on the local virtual network | `bool` | `false` | no |
| <a name="input_source_virtual_network_name"></a> [source\_virtual\_network\_name](#input\_source\_virtual\_network\_name) | The name of the virtual network from which the peering starts | `string` | n/a | yes |
| <a name="input_target_allow_forwarded_traffic"></a> [target\_allow\_forwarded\_traffic](#input\_target\_allow\_forwarded\_traffic) | Controls if forwarded traffic from VMs in the remote virtual network is allowed. | `bool` | `false` | no |
| <a name="input_target_allow_gateway_transit"></a> [target\_allow\_gateway\_transit](#input\_target\_allow\_gateway\_transit) | Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network. | `bool` | `false` | no |
| <a name="input_target_allow_virtual_network_access"></a> [target\_allow\_virtual\_network\_access](#input\_target\_allow\_virtual\_network\_access) | Controls if the VMs in the remote virtual network can access VMs in the local virtual network. | `bool` | `true` | no |
| <a name="input_target_remote_virtual_network_id"></a> [target\_remote\_virtual\_network\_id](#input\_target\_remote\_virtual\_network\_id) | The full Azure resource ID of the remote virtual network from which the peering ends. | `string` | n/a | yes |
| <a name="input_target_resource_group_name"></a> [target\_resource\_group\_name](#input\_target\_resource\_group\_name) | The name of the resource group in which to end the virtual network peering | `string` | `null` | no |
| <a name="input_target_use_remote_gateways"></a> [target\_use\_remote\_gateways](#input\_target\_use\_remote\_gateways) | Controls if remote gateways can be used on the local virtual network | `bool` | `false` | no |
| <a name="input_target_virtual_network_name"></a> [target\_virtual\_network\_name](#input\_target\_virtual\_network\_name) | The name of the virtual network from which the peering ends | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_source_id"></a> [source\_id](#output\_source\_id) | n/a |
| <a name="output_source_name"></a> [source\_name](#output\_source\_name) | n/a |
| <a name="output_target_id"></a> [target\_id](#output\_target\_id) | n/a |
| <a name="output_target_name"></a> [target\_name](#output\_target\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
