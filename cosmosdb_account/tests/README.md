# Test for Azure the cosmosdb_account module

Terraform template to test the Azure cosmosdb_account module


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
| <a name="module_cosmosdb_account"></a> [cosmosdb\_account](#module\_cosmosdb\_account) | ../../cosmosdb_account | n/a |
| <a name="module_pendpoints_snet"></a> [pendpoints\_snet](#module\_pendpoints\_snet) | ../../subnet | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.privatelink_cassandra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_mongo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.cassandra_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.mongo_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.sql_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.table_core_private_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | The capabilities which should be enabled for this Cosmos DB account. | `list(string)` | `[]` | no |
| <a name="input_cidr_subnet_pendpoints"></a> [cidr\_subnet\_pendpoints](#input\_cidr\_subnet\_pendpoints) | n/a | `list(string)` | <pre>[<br/>  "10.0.250.0/23"<br/>]</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | (Optional) Specifies the domain of the CosmosDB Account. | `string` | `""` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. | `string` | `"GlobalDocumentDB"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"italynorth"` | no |
| <a name="input_main_geo_location_zone_redundant"></a> [main\_geo\_location\_zone\_redundant](#input\_main\_geo\_location\_zone\_redundant) | Should zone redundancy be enabled for main region? Set true for prod environments | `bool` | `false` | no |
| <a name="input_mongo_server_version"></a> [mongo\_server\_version](#input\_mongo\_server\_version) | The Server Version of a MongoDB account. Possible values are 4.0, 3.6, and 3.2. | `string` | `null` | no |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | The CosmosDB account offer type. At the moment can only be set to Standard | `string` | `"Standard"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmtest"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | CosmosDB account example | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3",<br/>  "Test": "cosmosdb-account"<br/>}</pre> | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | n/a | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
