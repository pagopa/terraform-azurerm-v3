# Azure Container App Job as GitHub Runners

This module creates the infrastructure to host GitHub self hosted runners using Azure Container Apps jobs and can be used by GitHub repositories which need access to private resources on Azure.

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

- a resource group for the Container App Environment named `<prefix>-<short_env>-github-runner-rg`
- a VNet
- a KeyVault
- a Log Analytics Workspace
- a secret in the mentioned KeyVault containing a GitHub PAT with access to the desired repos
  - PATs can be generated using [`bot` GitHub users](https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/466716501/Github+-+bots+for+projects). An Admin must approve the request
  - PATs have an expiration date

### What the module does

The module creates:

- a subnet (`/23`) in the specified VNet
- a Container App Environment in that subnet with the name `<prefix>-<short_env>-github-runner-snet` (name is overridable)
- a Container App job with the name `<prefix>-<short_env>-github-runner-job`
- a role assignment to allow the Container App Job to read secrets from the existing KeyVault (`Get` permission over KeyVault's secrets access policies)

### Example

Give a try to the example saved in `terraform-azurerm-v3/container_app_job_gh_runner/tests` to see a working demo of this module.

## Design

A Container App Job scales containers (jobs) based on event-driven rules (KEDA). A Container App Job might have multiple containers, each of them with different properties (VM size, secrets, images, volumes, etc.).
To support GitHub Actions, you need to use `github-runner` [scale rule](https://keda.sh/docs/2.12/scalers/github-runner/) with these metadata:

- owner: `pagopa`
- runnerScope: `repo`
  - most tighten
- repos: *the repository* you want to support
  - it supports multiple repositories but this module is designed to have a 1:1 match between containers and repositories
- targetWorkflowQueueLength: `1`
  - indicates how many job requests are necessary to trigger the container
- labels: the job name
  - field is optional but useful to apply the event-driven rule to a single container and not to the entire Container App Job

With the above settings, the scale rules start to poll the GitHub repositories (be careful to quota limits). When a job request is detected, it launches the container indicated in the `labels` metadata.

Containers needs these environment variables to connect to GitHub, [grab a registration token and register themself as runners](https://github.com/pagopa/github-self-hosted-runner-azure/blob/dockerfile-v2/github-runner-entrypoint.sh):

- GITHUB_PAT: reference to the KeyVault secret (no Kubernetes secrets are used)
- REPO_URL: GitHub repo URL
- REGISTRATION_TOKEN_API_URL: [GitHub API](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository) to get the registration token

### Notes

`azapi_resource` is required by CA because:

- `azurerm` doesn't support Container App *jobs* ([feature request](https://github.com/hashicorp/terraform-provider-azurerm/issues/23165))
- KeyVault reference not supported by `azurerm` ([feature request](https://github.com/hashicorp/terraform-provider-azurerm/issues/21739))

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | <= 1.12.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.50.0, <= 3.93.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.container_app_job](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_key_vault_access_policy.keyvault_containerapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_container_app_environment.container_app_environment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app_environment) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.rg_runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container"></a> [container](#input\_container) | Job Container configuration | <pre>object({<br>    cpu    = number<br>    memory = string<br>    image  = string<br>  })</pre> | <pre>{<br>  "cpu": 0.5,<br>  "image": "ghcr.io/pagopa/github-self-hosted-runner-azure:latest",<br>  "memory": "1Gi"<br>}</pre> | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short environment prefix | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Container App Environment configuration (Log Analytics Workspace) | <pre>object({<br>    name                = string<br>    resource_group_name = string<br>  })</pre> | n/a | yes |
| <a name="input_job"></a> [job](#input\_job) | Container App job configuration | <pre>object({<br>    name                 = string<br>    repo_owner           = optional(string, "pagopa")<br>    repo                 = string<br>    polling_interval     = optional(number, 30)<br>    scale_max_executions = optional(number, 5)<br>  })</pre> | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Data of the KeyVault which stores PAT as secret | <pre>object({<br>    resource_group_name = string<br>    name                = string<br>    secret_name         = string<br>  })</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Resource group and resources location | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Project prefix | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for new resources | `map(any)` | <pre>{<br>  "CreatedBy": "Terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Container App job id |
| <a name="output_name"></a> [name](#output\_name) | Container App job name |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Container App job resource group name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
