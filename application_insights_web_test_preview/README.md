# Application insights we test preview

This module allow to create an alert for the fqdn host

## How to use

```ts
locals {

  test_urls = [
    {
      # management.env.cstar.pagopa.it
      host                 = "google.com",
      path                 = "/",
      expected_http_status = 200
    },
  ]

}

module "web_test_availability_alert_rules_for_api" {
  for_each = { for v in local.test_urls : v.host => v if v != null }
  source   = "git::https://github.com/pagopa/terraform-azurerm-v3.git//application_insights_web_test_preview?ref=application-insights-web-test-preview-migration-v2"

  subscription_id                   = data.azurerm_subscription.current.subscription_id
  name                              = "${each.value.host}-test-avail"
  location                          = azurerm_resource_group.monitor_rg.location
  resource_group                    = azurerm_resource_group.monitor_rg.name
  application_insight_name          = azurerm_application_insights.application_insights.name
  application_insight_id            = azurerm_application_insights.application_insights.id
  request_url                       = "https://${each.value.host}${each.value.path}"
  ssl_cert_remaining_lifetime_check = 7
  expected_http_status              = each.value.expected_http_status

  actions = [
    {
      action_group_id = azurerm_monitor_action_group.email.id,
    },
    {
      action_group_id = azurerm_monitor_action_group.slack.id,
    },
  ]
}
```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.30.0, <= 3.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_template_deployment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/template_deployment) | resource |
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actions"></a> [actions](#input\_actions) | n/a | <pre>list(object({<br>    action_group_id = string<br>  }))</pre> | n/a | yes |
| <a name="input_application_insight_name"></a> [application\_insight\_name](#input\_application\_insight\_name) | Application insight instance name. | `string` | n/a | yes |
| <a name="input_auto_mitigate"></a> [auto\_mitigate](#input\_auto\_mitigate) | (Optional) Should the alerts in this Metric Alert be auto resolved? Defaults to false. | `bool` | `false` | no |
| <a name="input_content_validation"></a> [content\_validation](#input\_content\_validation) | Required text that should appear in the response for this WebTest. | `string` | `"null"` | no |
| <a name="input_expected_http_status"></a> [expected\_http\_status](#input\_expected\_http\_status) | Expeced http status code. | `number` | `200` | no |
| <a name="input_failed_location_count"></a> [failed\_location\_count](#input\_failed\_location\_count) | The number of failed locations. | `number` | `1` | no |
| <a name="input_frequency"></a> [frequency](#input\_frequency) | Interval in seconds between test runs for this WebTest. | `number` | `300` | no |
| <a name="input_ignore_http_status"></a> [ignore\_http\_status](#input\_ignore\_http\_status) | Ignore http status code. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Application insight location. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Web test name | `string` | n/a | yes |
| <a name="input_request_url"></a> [request\_url](#input\_request\_url) | Url to check. | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group name | `string` | n/a | yes |
| <a name="input_severity"></a> [severity](#input\_severity) | The severity of this Metric Alert. | `number` | `1` | no |
| <a name="input_ssl_cert_remaining_lifetime_check"></a> [ssl\_cert\_remaining\_lifetime\_check](#input\_ssl\_cert\_remaining\_lifetime\_check) | Days before the ssl certificate will expire. An expiry certificate will cause the test failing. | `number` | `7` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) subscription id. | `string` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Seconds until this WebTest will timeout and fail. | `number` | `30` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
