# GitHub Federated Identity for Azure Module

This module creates User Managed Identities federated with one or more GitHub repositories in order to use a passwordless authentication model between GitHub and Azure.
This module should only be used in `<product>-infra` repositories.

> more info about this approach on [Confluence page](https://pagopa.atlassian.net/wiki/spaces/Technology/pages/734527975/GitHub+OIDC+OP)

For debugging purposes, you might be useful module's output containing the brand new identities' data.

## Glossary

- `<prefix>`: product name, such as `io` or `selfc`
- `<shortenv>`: environment name in short form, such as `d` or `p`
- `<domain>`: optional, the product sub area, such as `sign`
- `<idrole>`: the role of the identity, it can be either `ci` or `cd`
- `<repo>`: the repository name, such as `io-infra`
- `<scope>`: the federation type, such as `environment` or `branch` or `tag`
- `<subject>`: the federation scope value, such as `dev` (for environments) or `v1.0` (for tags)

## Design

This module expects to find an existing resource group named `<prefix>-<shortenv>-identity-rg`. Then, it creates a [user managed identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp) in it using the naming convention `<prefix>-<shortenv>-<domain>-[<app_name>]-github-<idrole>-identity`; the `idrole` value is obtained from the input variable `identity_role` and can be either `ci` or `cd`. Finally, the variable `github_federations` defines the list of the repositories and GitHub environments to create a federation with. The federation output name uses the form `<prefix>-<shortenv>-<domain>-github"-<repo>-<scope>-<subject>`.

> Consume this module once for each identity. You are likely to invoke the module twice then, one time for CI identity and one time for CD identity.

### The need of two identities

Two scenarios have been identified. The first one is the Continuos Integration, where usually the agent performs a dry run over the current infrastructure. Since there is no write operation involved, the `ci` identity doesn't need privileged roles such as `Owner` or `Contributor` but some fine grained reader role depending on the kind of resources involved in the repository - reader role of KeyVault's in a particular subscription. For this reason, the module defaults on a generic subscription-wide `Reader` role. This setting can be however overridden.

On the other hand, the `cd` identity actually needs to write things, so the module defaults on a subscription-wide `Contributor` role, but that can be overridden too.

> This approach allows developers to match the minimum privilege principle.

At this point, it might be thought that having a pair of identities for each repository would be a convenient approach, and in an ideal world it is; however, having plenty of identities is a risk for the governability of the cloud and the clearness of the code, which may cause reading and comprehension difficulties.

## How to use it

The Terraform template in `./tests` folder can be used as an example or a template. It contains some documentation and guidance about variables and values. It is a good starting point.

### Requirements

As stated in the [Design](#design) section, you must define a new resource group before invoking this module. Look at the `./tests` to get an example. Remember: the resource group name should match the naming convention `<prefix>-<shortenv>-identity-rg`.

If the resource group is not found, an exception is thrown.

### RBAC roles

As explained in the [Design](#design) section, you should invoke the module twice - once for the `ci` identity and another one for the `cd` identity.

You can customize identities' IAM roles both at subscription and resource group level using the variables `cX_rbac_roles`. In particular, the variable accepts:

- a list of roles to assign to the _current_ subscription
- a dictionary of resource group names and list of roles

> probably, module can be improved by using a single variable for RBAC roles instead of having two identicals.

This granularity is useful in such scenario where is needed a writing-role on the Storage Account which contains Terraform state files but at the same time reading-only permissions on the others Storage Accounts.

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [azurerm_federated_identity_credential.identity_credentials](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.identity_rg_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.identity_subscription_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_resource_group.identity_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.resource_group_details](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name | `string` | `""` | no |
| <a name="input_cd_rbac_roles"></a> [cd\_rbac\_roles](#input\_cd\_rbac\_roles) | Set of CD identity roles for the current subscription and the specified resource groups | <pre>object({<br>    subscription_roles = set(string)<br>    resource_groups    = map(list(string))<br>  })</pre> | <pre>{<br>  "resource_groups": {},<br>  "subscription_roles": [<br>    "Contributor"<br>  ]<br>}</pre> | no |
| <a name="input_ci_rbac_roles"></a> [ci\_rbac\_roles](#input\_ci\_rbac\_roles) | Set of CI identity roles for the current subscription and the specified resource groups | <pre>object({<br>    subscription_roles = set(string)<br>    resource_groups    = map(list(string))<br>  })</pre> | <pre>{<br>  "resource_groups": {},<br>  "subscription_roles": [<br>    "Reader"<br>  ]<br>}</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | App domain name | `string` | `""` | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short environment prefix | `string` | n/a | yes |
| <a name="input_github_federations"></a> [github\_federations](#input\_github\_federations) | GitHub Organization, repository name and scope permissions | <pre>list(object({<br>    org               = optional(string, "pagopa")<br>    repository        = string<br>    audience          = optional(set(string), ["api://AzureADTokenExchange"])<br>    issuer            = optional(string, "https://token.actions.githubusercontent.com")<br>    credentials_scope = optional(string, "environment")<br>    subject           = string<br>  }))</pre> | n/a | yes |
| <a name="input_identity_role"></a> [identity\_role](#input\_identity\_role) | Identity role should be either ci or cd | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Managed Identity | `string` | `null` | no |
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
