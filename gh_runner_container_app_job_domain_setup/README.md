# Domain setup for Azure Container App Job as GitHub Runners

This module relies on `container_app_job_gh_runner_v2` and other resources to create the necessary infrastructure to execute gh runner as container app jobs.
It creates a container app job for each defined repository, and then creates the required federated identity, federating it to each defined repo in order to be able to execute the gh actions.

## How to use it

```hcl 
# container app environment data
locals {
  tools_cae_name = "${local.product}-tools-cae"
  tools_cae_rg = "${local.product}-core-tools-rg"
}

module "gh_runner_job" {
  source = "github.com/pagopa/terraform-azurerm-v3//gh_runner_container_app_job_domain_setup?ref=PAYMCLOUD-151"

  domain_name = "paymentoptions"
  env_short = var.env_short
  environment_name = local.tools_cae_name
  environment_rg = local.tools_cae_rg
  gh_repositories = [
    {
      name: "pagopa-payment-options-service",
      short_name: "payopt"
    }
  ]
  job = {
    name = "paymentoption"
  }
  job_meta = {}
  key_vault = {
    name        = "${local.product}-kv" # Name of the KeyVault which stores PAT as secret
    rg          = "${local.product}-sec-rg" # Resource group of the KeyVault which stores PAT as secret
    secret_name = "gh-runner-job-pat" # Data of the KeyVault which stores PAT as secret
  }
  kubernetes_deploy = {
    enabled      = true
    namespace    = "payopt"
    cluster_name = "${local.product}-${var.location_short}-${var.instance}-aks"
    rg           = "${local.product}-${var.location_short}-${var.instance}-aks-rg"
  }
  location = var.location
  prefix = var.prefix
  resource_group_name = data.azurerm_resource_group.identity_rg.name

  tags = var.tags

}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.116.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_app_job"></a> [container\_app\_job](#module\_container\_app\_job) | ../container_app_job_gh_runner_v2 | n/a |
| <a name="module_identity_cd"></a> [identity\_cd](#module\_identity\_cd) | github.com/pagopa/terraform-azurerm-v3//github_federated_identity | v8.22.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_access_policy.gha_iac_managed_identities](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [null_resource.github_runner_app_permissions_to_namespace_cd](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_resource_group.gh_runner_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container"></a> [container](#input\_container) | Job Container configuration | <pre>object({<br/>    cpu    = number<br/>    memory = string<br/>    image  = string<br/>  })</pre> | <pre>{<br/>  "cpu": 0.5,<br/>  "image": "ghcr.io/pagopa/github-self-hosted-runner-azure:latest",<br/>  "memory": "1Gi"<br/>}</pre> | no |
| <a name="input_custom_rg_permissions"></a> [custom\_rg\_permissions](#input\_custom\_rg\_permissions) | (Optional) List of resource group permission assigned to the job identity | <pre>list(object({<br/>    rg_name     = string       #name of the resource group on which the permissions are given<br/>    permissions = list(string) # list of permission assigned on with rg_name scope<br/>  }))</pre> | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | (Required) Domain name for the configured repositories | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short environment prefix | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | (Required) Container App Environment configuration (Log Analytics Workspace) | `string` | n/a | yes |
| <a name="input_environment_rg"></a> [environment\_rg](#input\_environment\_rg) | (Required) Container App Environment configuration (Log Analytics Workspace) | `string` | n/a | yes |
| <a name="input_function_deploy"></a> [function\_deploy](#input\_function\_deploy) | (Optional) Enables and specifies the function app deploy permissions | <pre>object({<br/>    enabled = optional(bool, false)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_gh_identity_suffix"></a> [gh\_identity\_suffix](#input\_gh\_identity\_suffix) | (Optional) Suffix used in the gh identity name. Necessary to distinguish the identities when more than 20 repos are used | `string` | `"01"` | no |
| <a name="input_gh_repositories"></a> [gh\_repositories](#input\_gh\_repositories) | (Required) List of gh repository names and short names on which the managed identity will have permission. Max 20 repos. All repos must belong to the same organization, check `job_meta` variable | <pre>list(object({<br/>    name       = string<br/>    short_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_job"></a> [job](#input\_job) | Container App job configuration | <pre>object({<br/>    name                 = string<br/>    scale_max_executions = optional(number, 5)<br/>    scale_min_executions = optional(number, 0)<br/>  })</pre> | n/a | yes |
| <a name="input_job_meta"></a> [job\_meta](#input\_job\_meta) | Scaling rules metadata. | <pre>object({<br/>    repo_owner                   = optional(string, "pagopa")<br/>    runner_scope                 = optional(string, "repo")<br/>    target_workflow_queue_length = optional(string, "1")<br/>    github_runner                = optional(string, "https://api.github.com")<br/>  })</pre> | <pre>{<br/>  "github_runner": "https://api.github.com",<br/>  "repo_owner": "pagopa",<br/>  "runner_scope": "repo",<br/>  "target_workflow_queue_length": "1"<br/>}</pre> | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | n/a | <pre>object({<br/>    name        = string # Name of the KeyVault which stores PAT as secret<br/>    rg          = string # Resource group of the KeyVault which stores PAT as secret<br/>    secret_name = string # Data of the KeyVault which stores PAT as secret<br/>  })</pre> | n/a | yes |
| <a name="input_kubernetes_deploy"></a> [kubernetes\_deploy](#input\_kubernetes\_deploy) | (Optional) Enables and specifies the kubernetes deply permissions | <pre>object({<br/>    enabled      = optional(bool, false)<br/>    namespace    = optional(string, "")<br/>    cluster_name = optional(string, "")<br/>    rg           = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "cluster_name": "",<br/>  "enabled": false,<br/>  "namespace": "",<br/>  "rg": ""<br/>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Resource group and resources location | `string` | n/a | yes |
| <a name="input_parallelism"></a> [parallelism](#input\_parallelism) | (Optional) Number of parallel replicas of a job that can run at a given time. | `number` | `1` | no |
| <a name="input_polling_interval_in_seconds"></a> [polling\_interval\_in\_seconds](#input\_polling\_interval\_in\_seconds) | (Optional) Interval to check each event source in seconds. | `number` | `30` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Project prefix | `string` | n/a | yes |
| <a name="input_replica_completion_count"></a> [replica\_completion\_count](#input\_replica\_completion\_count) | (Optional) Minimum number of successful replica completions before overall job completion. | `number` | `1` | no |
| <a name="input_replica_retry_limit"></a> [replica\_retry\_limit](#input\_replica\_retry\_limit) | (Optional) The maximum number of times a replica is allowed to retry. | `number` | `1` | no |
| <a name="input_replica_timeout_in_seconds"></a> [replica\_timeout\_in\_seconds](#input\_replica\_timeout\_in\_seconds) | (Required) The maximum number of seconds a replica is allowed to run. | `number` | `1800` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels) | Labels that allow a GH action to call a specific runner | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for new resources | `map(any)` | <pre>{<br/>  "CreatedBy": "Terraform"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

