## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.116.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.16.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | <= 2.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.16.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.opencost_identity_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.open_cost_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.opencost_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [helm_release.opencost](https://registry.terraform.io/providers/hashicorp/helm/2.16.1/docs/resources/release) | resource |
| [helm_release.prometheus_opencost_exporter](https://registry.terraform.io/providers/hashicorp/helm/2.16.1/docs/resources/release) | resource |
| [kubernetes_secret.azure_managed_identity_refs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_name"></a> [aks\_name](#input\_aks\_name) | (Required) Name of AKS cluster in Azure | `string` | n/a | yes |
| <a name="input_aks_rg_name"></a> [aks\_rg\_name](#input\_aks\_rg\_name) | (Required) Name of AKS cluster resource group in Azure | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | n/a | `string` | n/a | yes |
| <a name="input_k8s_kube_config_path_prefix"></a> [k8s\_kube\_config\_path\_prefix](#input\_k8s\_kube\_config\_path\_prefix) | n/a | `string` | `"~/.kube"` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | n/a | `string` | `"monitoring"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Location short like eg: weu, weu.. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | `"cstar"` | no |
| <a name="input_prometheus_chart_version"></a> [prometheus\_chart\_version](#input\_prometheus\_chart\_version) | (Optional) The prometheus chart version to use. | `string` | `"1.42.3"` | no |
| <a name="input_prometheus_namespace"></a> [prometheus\_namespace](#input\_prometheus\_namespace) | (Required) The prometheus namespace. | `string` | n/a | yes |
| <a name="input_prometheus_service_name"></a> [prometheus\_service\_name](#input\_prometheus\_service\_name) | (Required) The prometheus service name. | `string` | n/a | yes |
| <a name="input_prometheus_service_port"></a> [prometheus\_service\_port](#input\_prometheus\_service\_port) | (Required) The prometheus service port. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_identity_details"></a> [managed\_identity\_details](#output\_managed\_identity\_details) | Dettagli dell'identità gestita User-Assigned per OpenCost |
