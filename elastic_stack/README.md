# Elastic Stack

This module allow the creation of Elastic Stack

## Architecture

## Configurations

## How to use it

TODO

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.38.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | <= 2.16.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.16.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.apm_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.elastic_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.ingress_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.kibana_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.mounter_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.secret_manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_balancer_node_number"></a> [balancer\_node\_number](#input\_balancer\_node\_number) | Number of balancer nodes | `string` | `"0"` | no |
| <a name="input_balancer_storage_class"></a> [balancer\_storage\_class](#input\_balancer\_storage\_class) | Storage class of balancer node in GB | `string` | n/a | yes |
| <a name="input_balancer_storage_size"></a> [balancer\_storage\_size](#input\_balancer\_storage\_size) | Storage size of balancer node in GB | `string` | `"0"` | no |
| <a name="input_cold_node_number"></a> [cold\_node\_number](#input\_cold\_node\_number) | Number of cold nodes | `string` | `"0"` | no |
| <a name="input_cold_storage_class"></a> [cold\_storage\_class](#input\_cold\_storage\_class) | Storage class of cold node in GB | `string` | n/a | yes |
| <a name="input_cold_storage_size"></a> [cold\_storage\_size](#input\_cold\_storage\_size) | Storage size of cold node in GB | `string` | `"0"` | no |
| <a name="input_hot_node_number"></a> [hot\_node\_number](#input\_hot\_node\_number) | Number of hot nodes | `string` | `"1"` | no |
| <a name="input_hot_storage_class"></a> [hot\_storage\_class](#input\_hot\_storage\_class) | Storage class of hot node in GB | `string` | n/a | yes |
| <a name="input_hot_storage_size"></a> [hot\_storage\_size](#input\_hot\_storage\_size) | Storage size of hot node in GB | `string` | `"50"` | no |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | Keyvault name | `string` | n/a | yes |
| <a name="input_kibana_external_domain"></a> [kibana\_external\_domain](#input\_kibana\_external\_domain) | Kibana external domain | `string` | n/a | yes |
| <a name="input_kibana_internal_hostname"></a> [kibana\_internal\_hostname](#input\_kibana\_internal\_hostname) | Kibana internal hostname | `string` | n/a | yes |
| <a name="input_master_node_number"></a> [master\_node\_number](#input\_master\_node\_number) | Number of master nodes | `string` | `"1"` | no |
| <a name="input_master_storage_class"></a> [master\_storage\_class](#input\_master\_storage\_class) | Storage class of master node in GB | `string` | n/a | yes |
| <a name="input_master_storage_size"></a> [master\_storage\_size](#input\_master\_storage\_size) | Storage size of master node in GB | `string` | `"20"` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Secret certificate name | `string` | n/a | yes |
| <a name="input_warm_node_number"></a> [warm\_node\_number](#input\_warm\_node\_number) | Number of warm nodes | `string` | `"0"` | no |
| <a name="input_warm_storage_class"></a> [warm\_storage\_class](#input\_warm\_storage\_class) | Storage class of warm node in GB | `string` | n/a | yes |
| <a name="input_warm_storage_size"></a> [warm\_storage\_size](#input\_warm\_storage\_size) | Storage size of warm node in GB | `string` | `"0"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
