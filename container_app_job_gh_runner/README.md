# Azure Container App Job as GitHub Runners

This module creates the infrastructure to host GitHub self hosted runners using Azure Container Apps jobs.

## Included resources

The following resources are created and managed by this module:

- resource group
- subnet
- container app environment
- container app job

## How to use it

Give a try to the example saved in `terraform-azurerm-v3/container_app_job_gh_runner/tests` to see a working demo of this module

### Prerequisites

Before running the demo, you need to manually create:

- vnet
- keyvault
- a valid GitHub PAT stored as secret

Names of these resources are required as module input

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | <= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.44.0, <= 3.76.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.runner_environment](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.runner_job](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_key_vault_access_policy.keyvault_containerapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_resource_group.runner_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.runner_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | n/a | <pre>object({<br>    repo_owner = optional(string, "pagopa")<br>    repos      = set(string)<br>    image      = optional(string, "ghcr.io/pagopa/github-self-hosted-runner-azure:beta-dockerfile-v2@sha256:ed51ac419d78b6410be96ecaa8aa8dbe645aa0309374132886412178e2739a47")<br>  })</pre> | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short environment prefix | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | <pre>object({<br>    workspace_id = string<br>    customerId   = string<br>    sharedKey    = string<br>  })</pre> | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | n/a | <pre>object({<br>    resource_group_name = string<br>    name                = string<br>    secret_name         = string<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Resource group and resources location | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | n/a | <pre>object({<br>    rg_vnet      = string<br>    vnet         = string<br>    cidr_subnets = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Project prefix | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for new resources | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_name"></a> [ca\_name](#output\_ca\_name) | Container App job name |
| <a name="output_cae_name"></a> [cae\_name](#output\_cae\_name) | Container App Environment name |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | Resource group name |
| <a name="output_subnet_cidr"></a> [subnet\_cidr](#output\_subnet\_cidr) | Subnet CIDR blocks |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | Subnet name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
