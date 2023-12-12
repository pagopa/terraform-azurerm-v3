# Azure Container App Job as GitHub Runners

This module creates the infrastructure to host GitHub self hosted runners using Azure Container Apps jobs and can be used by repositories which need private resource access on Azure.

- [Azure Container App Job as GitHub Runners](#azure-container-app-job-as-github-runners)
  - [How to use it](#how-to-use-it)
    - [Requirements](#requirements)
    - [What the module does](#what-the-module-does)
    - [Example](#example)
  - [Design](#design)
    - [Notes](#notes)
  - [Requirements](#requirements-1)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## How to use it

### Requirements

Before using the module, developer needs the following existing resources:

- a VNet
- a KeyVault
- a Log Analytics Workspace
- a secret in the mentioned KeyVault containing a GitHub PAT with access to the desired repos
  - PATs can be generated using [`bot` GitHub users](https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/466716501/Github+-+bots+for+projects). An Admin must approve the request
  - PATs have an expiration date

### What the module does

The module creates:

- a subnet (/23)
- a resource group
- a Container App Environment
- a Container App job
- a role assignment to allow the container app job to read the secret (`Get` permission over KeyVault's secrets)

### Example

Give a try to the example saved in `terraform-azurerm-v3/container_app_job_gh_runner/tests` to see a working demo of this module.

## Design

A Container App job scales jobs based on event-driven rules (KEDA). To support GitHub Actions, you need to use [`github-runner` scale rule](https://keda.sh/docs/2.12/scalers/github-runner/) with these metadata:

- owner: `pagopa`
- runnerScope: `repo`
  - most tighten
- repos: *the repository* you want to support
  - it supports multiple repositories but we need a 1:1 match between containers and repositories
- targetWorkflowQueueLength: `1`
  - indicates how many job requests are necessary to trigger the container
- labels: the job name
  - field is optional but allows us to set a 1:1 match between containers and repositories

With the above settings, the app will be able to poll the GitHub repository (be careful to quota limits). When a job request is detected, it launches the job indicated in the `labels` metadata.

On the other hand, containers needs these environment variables to connect to GitHub, [grab a registration token and register themself as runners](https://github.com/pagopa/github-self-hosted-runner-azure/blob/dockerfile-v2/github-runner-entrypoint.sh):

- GITHUB_PAT: reference to the KeyVault secret (no Kubernetes secrets are used)
- REPO_URL: GitHub repo URL
- REGISTRATION_TOKEN_API_URL: [GitHub API](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository) to get the registration token

### Notes

`azapi_resource` is required by CAE because:

- `zoneRedundant` property must be true but `azurerm` supports it since v3.50 (too recent for us?)

`azapi_resource` is required by CA because:

- `azurerm` doesn't support Container App *jobs* ([feature request](https://github.com/hashicorp/terraform-provider-azurerm/issues/23165))
- KeyVault reference not supported by `azurerm` ([feature request](https://github.com/hashicorp/terraform-provider-azurerm/issues/21739))

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
| <a name="input_app"></a> [app](#input\_app) | Container App job configuration | <pre>object({<br>    repo_owner = optional(string, "pagopa")<br>    repos      = set(string)<br>    image      = optional(string, "ghcr.io/pagopa/github-self-hosted-runner-azure:beta-dockerfile-v2@sha256:c7ebe4453578c9df426b793366b8498c030ec0f47f753ea2c685a3c0ec0bb646")<br>  })</pre> | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short environment prefix | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Container App Environment logging configuration (Log Analytics Workspace) | <pre>object({<br>    customerId = string<br>    sharedKey  = string<br>  })</pre> | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Data of the KeyVault which stores PAT as secret | <pre>object({<br>    resource_group_name = string<br>    name                = string<br>    secret_name         = string<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Resource group and resources location | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Existing VNet information and subnet CIDR block to use (must be /23) | <pre>object({<br>    vnet_resource_group_name = string<br>    vnet_name                = string<br>    subnet_cidr_block        = string<br>  })</pre> | n/a | yes |
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
