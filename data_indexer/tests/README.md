# Test for Azure the app_service module

Terraform template to test the Azure function_app module


## How to use it
- terraform init
- terraform plan
- terraform apply
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.85.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_indexer"></a> [data\_indexer](#module\_data\_indexer) | ../../data_indexer | n/a |
| <a name="module_event_hub"></a> [event\_hub](#module\_event\_hub) | ../../eventhub | n/a |
| <a name="module_pendpoints_snet"></a> [pendpoints\_snet](#module\_pendpoints\_snet) | ../../subnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.privatelink_blob_core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_queue_core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_table_core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.blob_core_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.queue_core_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.servicebus_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.table_core_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_subnet_pendpoints"></a> [cidr\_subnet\_pendpoints](#input\_cidr\_subnet\_pendpoints) | n/a | `list(string)` | <pre>[<br/>  "10.0.250.0/23"<br/>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"italynorth"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmtest"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Data Indexer example | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3",<br/>  "Test": "data-indexer"<br/>}</pre> | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | n/a | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
