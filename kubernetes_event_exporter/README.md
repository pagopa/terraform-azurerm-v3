## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.helm_this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_config"></a> [custom\_config](#input\_custom\_config) | (Optional) Use this param to deploy a custom ConfigMap on exporter services | `string` | `null` | no |
| <a name="input_custom_variables"></a> [custom\_variables](#input\_custom\_variables) | (Optional) This maps contains the custom variable declare by the user on the custom\_config | `map(string)` | `null` | no |
| <a name="input_enable_opsgenie"></a> [enable\_opsgenie](#input\_enable\_opsgenie) | (Optional) Flag to enable opsgenie integration. | `bool` | `false` | no |
| <a name="input_enable_slack"></a> [enable\_slack](#input\_enable\_slack) | (Optional) Enable slack integration to send alert on your dedicated channel. | `bool` | `true` | no |
| <a name="input_helm_chart_name"></a> [helm\_chart\_name](#input\_helm\_chart\_name) | Is this helm chart present? | `string` | `"kubernetes-event-exporter"` | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Helm chart version for the kubernetes-event-exporter application | `string` | `"3.2.12"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (Required) Namespace where the helm chart will be installed. | `string` | n/a | yes |
| <a name="input_opsgenie_api_key"></a> [opsgenie\_api\_key](#input\_opsgenie\_api\_key) | (Optional) OpsGenie API token required for integration https://support.atlassian.com/opsgenie/docs/create-a-default-api-integration/ | `string` | `""` | no |
| <a name="input_opsgenie_receiver_name"></a> [opsgenie\_receiver\_name](#input\_opsgenie\_receiver\_name) | (Optional) Set custom receiver name for opsgenie integration. | `string` | `"opsgenie"` | no |
| <a name="input_slack_author"></a> [slack\_author](#input\_slack\_author) | (Optional) The name of author to display on slack message sent. | `string` | `"kubexporter"` | no |
| <a name="input_slack_channel"></a> [slack\_channel](#input\_slack\_channel) | (Optional) Slack channel for receive messages from exporter. | `string` | n/a | yes |
| <a name="input_slack_message_prefix"></a> [slack\_message\_prefix](#input\_slack\_message\_prefix) | (Optional) Formatting the message prefix of your slack alert. | `string` | `"Received a Kubernetes Event:"` | no |
| <a name="input_slack_receiver_name"></a> [slack\_receiver\_name](#input\_slack\_receiver\_name) | (Optional) Set custom receiver name for slack integration. | `string` | `"slack"` | no |
| <a name="input_slack_title"></a> [slack\_title](#input\_slack\_title) | (Optional) The name of message title of your app. | `string` | `"kubernetes event exporter app"` | no |
| <a name="input_slack_token"></a> [slack\_token](#input\_slack\_token) | (Optional) Slack app token to be able to connect on your workspace and send messages. | `string` | n/a | yes |

## Outputs

No outputs.
