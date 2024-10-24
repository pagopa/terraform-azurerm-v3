# Application insights standard web test

This module create an alert for a http(s) webservice

## Example

```hcl
module "webservice_monitor_01" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//application_insights_standard_web_test?ref=v8.8.0"
  

  https_endpoint                         = "https://api.dev.platform.pagopa.it"
  https_endpoint_path                    = "/contextpath/rest"
  alert_name                             = "WebServiceProbeName"
  location                               = var.location
  alert_enabled                          = true
  application_insights_resource_group    = data.azurerm_resource_group.monitor_rg.name
  application_insights_id                = data.azurerm_application_insights.application_insights.id
  https_probe_headers                    = "{\"HeaderName\":\"HeaderValue\"}"
  application_insights_action_group_ids  = [data.azurerm_monitor_action_group.slack.id, data.azurerm_monitor_action_group.email.id]
  https_probe_body                       = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" ....  </soapenv:Envelope>"
  https_probe_method                     = "POST"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.30 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights_standard_web_test.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) | resource |
| [azurerm_monitor_metric_alert.alert_this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_auto_mitigate"></a> [alert\_auto\_mitigate](#input\_alert\_auto\_mitigate) | (Optional) auto mitigate the alert when triggered | `bool` | `false` | no |
| <a name="input_alert_enabled"></a> [alert\_enabled](#input\_alert\_enabled) | (Optional) Is this alert enabled? | `bool` | `true` | no |
| <a name="input_alert_name"></a> [alert\_name](#input\_alert\_name) | (Optional) Alert name | `string` | `null` | no |
| <a name="input_alert_use_web_test_criteria"></a> [alert\_use\_web\_test\_criteria](#input\_alert\_use\_web\_test\_criteria) | (Optional) if true, uses the application\_insights\_web\_test\_location\_availability\_criteria instead of criteria block to read the web test result | `bool` | `false` | no |
| <a name="input_application_insights_action_group_ids"></a> [application\_insights\_action\_group\_ids](#input\_application\_insights\_action\_group\_ids) | (Required) Application insights action group ids | `list(string)` | n/a | yes |
| <a name="input_application_insights_id"></a> [application\_insights\_id](#input\_application\_insights\_id) | (Required) Application Insights id | `string` | n/a | yes |
| <a name="input_application_insights_resource_group"></a> [application\_insights\_resource\_group](#input\_application\_insights\_resource\_group) | (Required) Application Insights resource group | `string` | n/a | yes |
| <a name="input_availability_failed_location_threshold"></a> [availability\_failed\_location\_threshold](#input\_availability\_failed\_location\_threshold) | (Optional) number of failed location that should trigger the alert. used when 'alert\_use\_web\_test\_criteria' is true | `number` | `1` | no |
| <a name="input_frequency"></a> [frequency](#input\_frequency) | (Optional) Interval in seconds between test runs for this WebTest. Valid options are 300, 600 and 900. Defaults to 300. | `number` | `300` | no |
| <a name="input_https_endpoint"></a> [https\_endpoint](#input\_https\_endpoint) | Https endpoint to check | `string` | n/a | yes |
| <a name="input_https_endpoint_path"></a> [https\_endpoint\_path](#input\_https\_endpoint\_path) | Https endpoint path to check | `string` | n/a | yes |
| <a name="input_https_probe_body"></a> [https\_probe\_body](#input\_https\_probe\_body) | Https request body | `string` | `null` | no |
| <a name="input_https_probe_headers"></a> [https\_probe\_headers](#input\_https\_probe\_headers) | Https request headers | `string` | `"{}"` | no |
| <a name="input_https_probe_method"></a> [https\_probe\_method](#input\_https\_probe\_method) | Https request method | `string` | n/a | yes |
| <a name="input_https_probe_threshold"></a> [https\_probe\_threshold](#input\_https\_probe\_threshold) | threshold for metric alert | `number` | `90` | no |
| <a name="input_location"></a> [location](#input\_location) | Application insight location. | `string` | n/a | yes |
| <a name="input_metric_frequency"></a> [metric\_frequency](#input\_metric\_frequency) | (Optional) The evaluation frequency of this Metric Alert, represented in ISO 8601 duration format. Possible values are PT1M, PT5M, PT15M, PT30M and PT1H. Defaults to PT5M. | `string` | `"PT5M"` | no |
| <a name="input_metric_severity"></a> [metric\_severity](#input\_metric\_severity) | (Optional) The severity of this Metric Alert. Possible values are 0, 1, 2, 3 and 4. Defaults to 0. | `number` | `0` | no |
| <a name="input_metric_window_size"></a> [metric\_window\_size](#input\_metric\_window\_size) | (Optional) The period of time that is used to monitor alert activity, represented in ISO 8601 duration format. This value must be greater than frequency. Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D. Defaults to PT5M. | `string` | `"PT5M"` | no |
| <a name="input_replace_non_words_in_name"></a> [replace\_non\_words\_in\_name](#input\_replace\_non\_words\_in\_name) | (Optional) if true, replaces non words characters in web test name with dash | `bool` | `false` | no |
| <a name="input_request_follow_redirects"></a> [request\_follow\_redirects](#input\_request\_follow\_redirects) | (Optional) Should the following of redirects be enabled? | `bool` | `true` | no |
| <a name="input_request_parse_dependent_requests_enabled"></a> [request\_parse\_dependent\_requests\_enabled](#input\_request\_parse\_dependent\_requests\_enabled) | (Optional) Should the parsing of dependend requests be enabled? Defaults to true. | `bool` | `true` | no |
| <a name="input_retry_enabled"></a> [retry\_enabled](#input\_retry\_enabled) | (Optional) Should the retry on WebTest failure be enabled? | `bool` | `false` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | (Optional) Seconds until this WebTest will timeout and fail. Default is 30. | `number` | `30` | no |
| <a name="input_validation_rules"></a> [validation\_rules](#input\_validation\_rules) | (Optional) validation rules block | <pre>object({<br/>    content = optional(object({<br/>      content_match      = string<br/>      ignore_case        = optional(bool, false)<br/>      pass_if_text_found = optional(bool, true)<br/>    }), null)<br/>    expected_status_code        = optional(number, 200)<br/>    ssl_cert_remaining_lifetime = optional(number, 7)<br/>    ssl_check_enabled           = optional(bool, true)<br/><br/>  })</pre> | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
