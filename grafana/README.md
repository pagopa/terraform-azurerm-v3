# Grafana Managed

## Requirements

| Name                                                                      | Version   |
| ------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.5  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)       | >= 3.20.0 |

## Providers

| Name                                                          | Version   |
| ------------------------------------------------------------- | --------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.20.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_dashboard_grafana.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana) | resource |

## Inputs

| Name                                                                                                                                        | Description                                                                                                                                                              | Type       | Default            | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | ------------------ | :------: |
| <a name="input_api_key_enabled"></a> [api\_key\_enabled](#input\_api\_key\_enabled)                                                         | Whether to enable the api key setting of the Grafana instance                                                                                                            | `bool`     | `false`            |    no    |
| <a name="input_deterministic_outbound_ip_enabled"></a> [deterministic\_outbound\_ip\_enabled](#input\_deterministic\_outbound\_ip\_enabled) | Whether to enable the Grafana instance to use deterministic outbound IPs                                                                                                 | `bool`     | `false`            |    no    |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type)                                                                 | n/a                                                                                                                                                                      | `string`   | `"SystemAssigned"` |    no    |
| <a name="input_location"></a> [location](#input\_location)                                                                                  | n/a                                                                                                                                                                      | `string`   | `"westeurope"`     |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                              | n/a                                                                                                                                                                      | `string`   | n/a                |   yes    |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)             | Whether to enable traffic over the public interface                                                                                                                      | `bool`     | `true`             |    no    |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)                                             | n/a                                                                                                                                                                      | `string`   | n/a                |   yes    |
| <a name="input_sku"></a> [sku](#input\_sku)                                                                                                 | The name of the SKU used for the Grafana instance. The only possible value is Standard. Defaults to Standard. Changing this forces a new Dashboard Grafana to be created | `string`   | `"Standard"`       |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                              | n/a                                                                                                                                                                      | `map(any)` | n/a                |   yes    |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled)                                 | Whether to enable the zone redundancy setting of the Grafana instance                                                                                                    | `bool`     | `false`            |    no    |

## Outputs

| Name                                                                    | Description |
| ----------------------------------------------------------------------- | ----------- |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint)            | n/a         |
| <a name="output_id"></a> [id](#output\_id)                              | n/a         |
| <a name="output_name"></a> [name](#output\_name)                        | n/a         |
| <a name="output_outbound_ip"></a> [outbound\_ip](#output\_outbound\_ip) | n/a         |
| <a name="output_version"></a> [version](#output\_version)               | n/a         |