# Test for Azure module

Terraform template to test the module.

You need the access to DevOpsLab Subscription or change backend.ini value.

`resources.tf` file contains all resources to test.

## How to use it

- ./terraform.sh plan
- ./terraform.sh apply
- ./terraform.sh destroy
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.94.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_identity-cd"></a> [identity-cd](#module\_identity-cd) | ../ | n/a |
| <a name="module_identity-ci"></a> [identity-ci](#module\_identity-ci) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.identity_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_id.unique](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | App domain name | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Resorce location | `string` | `"westeurope"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resorce prefix | `string` | `"azrmtest"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository name | `string` | `"terraform-azurerm-v3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Azurerm test tags | `map(string)` | <pre>{<br/>  "CreatedBy": "Terraform",<br/>  "Source": "https://github.com/pagopa/terraform-azurerm-v3"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_cd_app_name"></a> [identity\_cd\_app\_name](#output\_identity\_cd\_app\_name) | User Managed Identity name |
| <a name="output_identity_cd_client_id"></a> [identity\_cd\_client\_id](#output\_identity\_cd\_client\_id) | User Managed Identity client id |
| <a name="output_identity_cd_principal_id"></a> [identity\_cd\_principal\_id](#output\_identity\_cd\_principal\_id) | User Managed Identity principal id |
| <a name="output_identity_cd_resource_group_name"></a> [identity\_cd\_resource\_group\_name](#output\_identity\_cd\_resource\_group\_name) | User Managed Identity resource group |
| <a name="output_identity_ci_app_name"></a> [identity\_ci\_app\_name](#output\_identity\_ci\_app\_name) | User Managed Identity name |
| <a name="output_identity_ci_client_id"></a> [identity\_ci\_client\_id](#output\_identity\_ci\_client\_id) | User Managed Identity client id |
| <a name="output_identity_ci_principal_id"></a> [identity\_ci\_principal\_id](#output\_identity\_ci\_principal\_id) | User Managed Identity principal id |
| <a name="output_identity_ci_resource_group_name"></a> [identity\_ci\_resource\_group\_name](#output\_identity\_ci\_resource\_group\_name) | User Managed Identity resource group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
