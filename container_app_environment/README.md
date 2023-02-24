# Container app environment

This resource allow the creation of a Container app environment

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.44.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group_template_deployment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_debug_level"></a> [debug\_level](#input\_debug\_level) | (Optional) The Debug Level which should be used for this Resource Group Template Deployment. Possible values are none, requestContent, responseContent and requestContent, responseContent. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Resource location. | `string` | n/a | yes |
| <a name="input_log_analytics_customer_id"></a> [log\_analytics\_customer\_id](#input\_log\_analytics\_customer\_id) | Workspace ID if log\_destination is log-analytics type | `string` | n/a | yes |
| <a name="input_log_analytics_shared_key"></a> [log\_analytics\_shared\_key](#input\_log\_analytics\_shared\_key) | Workspace ID if log\_destination is log-analytics type | `string` | n/a | yes |
| <a name="input_log_destination"></a> [log\_destination](#input\_log\_destination) | How to send container environment logs | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Resource name | `string` | n/a | yes |
| <a name="input_outbound_type"></a> [outbound\_type](#input\_outbound\_type) | Outbound connectivity type, at the moment only allowed value is LoadBalancer | `string` | `"LoadBalancer"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Sku type, at the moment only allowed value is Consumption | `string` | `"Consumption"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id if container environment is in a virtual network | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_vnet_internal"></a> [vnet\_internal](#input\_vnet\_internal) | Virtual network integration | `bool` | n/a | yes |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Deploy multi zone container environment | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
