# TLS Checker

This modules allow the creation of a tls checker using <https://pagopa.github.io/aks-microservice-chart-blueprint>

## How to use

```ts
module "tls_checker" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//tls_checker?ref=tls_cheker_improve_docs"

  https_endpoint                      = local.ecommerce_hostname
  alert_name                          = local.ecommerce_hostname
  alert_enabled                       = true
  helm_chart_present                  = true
  helm_chart_version                  = var.tls_cert_check_helm.chart_version
  namespace                           = kubernetes_namespace.namespace.metadata[0].name
  helm_chart_image_name               = var.tls_cert_check_helm.image_name
  helm_chart_image_tag                = var.tls_cert_check_helm.image_tag
  location_string                     = var.location_string
  application_insights_resource_group = data.azurerm_resource_group.monitor_rg.name
  application_insights_id             = data.azurerm_application_insights.application_insights.id
  application_insights_action_group_ids = [
    data.azurerm_monitor_action_group.slack.id,
    data.azurerm_monitor_action_group.email.id
  ]
  kv_secret_name_for_application_insights_connection_string = "applicationinsights-connection-string"
  keyvault_name                                             = data.azurerm_key_vault.kv.name
  keyvault_tenant_id                                        = data.azurerm_client_config.current.tenant_id
}

```

## Migration

if you use a version of the module <= 6.6.0 please change this params names:

* `application_insights_connection_string` -> kv_secret_name_for_application_insights_connection_string
* `keyvault_tenantid` -> `keyvault_tenant_id`


<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.64.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | <= 2.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.64.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.7.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.alert_this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [helm_release.helm_this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_enabled"></a> [alert\_enabled](#input\_alert\_enabled) | (Optional) Is this alert enabled? | `bool` | `true` | no |
| <a name="input_alert_name"></a> [alert\_name](#input\_alert\_name) | (Optional) Alert name | `string` | `null` | no |
| <a name="input_application_insights_action_group_ids"></a> [application\_insights\_action\_group\_ids](#input\_application\_insights\_action\_group\_ids) | (Required) Application insights action group ids | `list(string)` | n/a | yes |
| <a name="input_application_insights_id"></a> [application\_insights\_id](#input\_application\_insights\_id) | (Required) Application Insights id | `string` | n/a | yes |
| <a name="input_application_insights_resource_group"></a> [application\_insights\_resource\_group](#input\_application\_insights\_resource\_group) | (Required) Application Insights resource group | `string` | n/a | yes |
| <a name="input_expiration_delta_in_days"></a> [expiration\_delta\_in\_days](#input\_expiration\_delta\_in\_days) | (Optional) | `string` | `"7"` | no |
| <a name="input_helm_chart_image_name"></a> [helm\_chart\_image\_name](#input\_helm\_chart\_image\_name) | Docker image name | `string` | n/a | yes |
| <a name="input_helm_chart_image_tag"></a> [helm\_chart\_image\_tag](#input\_helm\_chart\_image\_tag) | Docker image tag | `string` | n/a | yes |
| <a name="input_helm_chart_present"></a> [helm\_chart\_present](#input\_helm\_chart\_present) | Is this helm chart present? | `bool` | `true` | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Helm chart version for the tls checker application | `string` | n/a | yes |
| <a name="input_https_endpoint"></a> [https\_endpoint](#input\_https\_endpoint) | Https endpoint to check | `string` | n/a | yes |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | (Required) Keyvault name | `string` | n/a | yes |
| <a name="input_keyvault_tenant_id"></a> [keyvault\_tenant\_id](#input\_keyvault\_tenant\_id) | (Required) Keyvault tenant id | `string` | n/a | yes |
| <a name="input_kv_secret_name_for_application_insights_connection_string"></a> [kv\_secret\_name\_for\_application\_insights\_connection\_string](#input\_kv\_secret\_name\_for\_application\_insights\_connection\_string) | (Required) The name of the secret inside the kv that contains the application insights connection string | `string` | n/a | yes |
| <a name="input_location_string"></a> [location\_string](#input\_location\_string) | (Required) Location string | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (Required) Namespace where the helm chart will be installed | `string` | n/a | yes |
| <a name="input_time_trigger"></a> [time\_trigger](#input\_time\_trigger) | cron trigger pattern | `string` | `"*/1 * * * *"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
