# GitHub Federated Identity for Azure

This module allows the creation of a User Managed Identity federated with GitHub.

Module is intended to be used against `infrastructure` repo. It is also designed to keep naming consistency, so most of them are auto calculated:
- resource group
- identity name

The module's output contains the identity data.

## How to use it

Use the Terraform template in `./tests` as template for testing and getting advices.

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
| [azurerm_federated_identity_credential.identity_credentials](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_resource_group.identity_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.identity_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cd_roles"></a> [cd\_roles](#input\_cd\_roles) | List of roles assigned to cd identity at subscription level | `list(string)` | <pre>[<br>  "Contributor",<br>  "Storage Account Contributor",<br>  "Storage Blob Data Contributor",<br>  "Storage File Data SMB Share Contributor",<br>  "Storage Queue Data Contributor",<br>  "Storage Table Data Contributor"<br>]</pre> | no |
| <a name="input_ci_roles"></a> [ci\_roles](#input\_ci\_roles) | List of roles assigned to ci identity at subscription level | `list(string)` | <pre>[<br>  "Reader",<br>  "Reader and Data Access",<br>  "Storage Blob Data Reader",<br>  "Storage File Data SMB Share Reader",<br>  "Storage Queue Data Reader",<br>  "Storage Table Data Reader",<br>  "PagoPA Export Deployments Template",<br>  "Key Vault Secrets User",<br>  "DocumentDB Account Contributor",<br>  "API Management Service Contributor"<br>]</pre> | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short environment prefix | `string` | n/a | yes |
| <a name="input_github"></a> [github](#input\_github) | GitHub Organization, repository name and scope permissions | <pre>object({<br>    org               = optional(string, "pagopa")<br>    repository        = string<br>    audience          = optional(list(string), ["api://AzureADTokenExchange"])<br>    issuer            = optional(string, "https://token.actions.githubusercontent.com")<br>    credentials_scope = optional(string, "environment")<br>    subject           = string<br>  })</pre> | n/a | yes |
| <a name="input_identity_role"></a> [identity\_role](#input\_identity\_role) | Identity role should be either ci or cd. Necessary permissions will be given according to the scope of the identity | `string` | `"ci"` | no |
| <a name="input_location"></a> [location](#input\_location) | Resource group and identity location | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Project prefix | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Identity tags | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_app_name"></a> [identity\_app\_name](#output\_identity\_app\_name) | User Managed Identity name |
| <a name="output_identity_client_id"></a> [identity\_client\_id](#output\_identity\_client\_id) | User Managed Identity client id |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | User Managed Identity principal id |
| <a name="output_identity_resource_group"></a> [identity\_resource\_group](#output\_identity\_resource\_group) | User Managed Identity resource group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
