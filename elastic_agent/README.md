# Elastic Stack

This module allow the creation of Elastic Stack

## Configurations

## How to use it

TODO

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.27 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.elastic_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dedicated_log_instance_name"></a> [dedicated\_log\_instance\_name](#input\_dedicated\_log\_instance\_name) | n/a | `list(string)` | n/a | yes |
| <a name="input_eck_version"></a> [eck\_version](#input\_eck\_version) | ECK (Elastic Cloud on Kubernetes) version, see: https://www.elastic.co/guide/en/cloud-on-k8s/index.html for futher versions | `string` | n/a | yes |
| <a name="input_es_host"></a> [es\_host](#input\_es\_host) | Elastic Host | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for ECK Operator | `string` | `"elastic-system"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
