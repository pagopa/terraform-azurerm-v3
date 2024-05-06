# api management

This module allow the creation of api management

## Architecture

![This is an image](./docs/module-arch.drawio.png)

## How to use it

```ts
# 🔐 KV
data "azurerm_key_vault_secret" "apim_publisher_email" {
  name         = "apim-publisher-email"
  key_vault_id = data.azurerm_key_vault.kv.id
}

## 🎫  Certificates

data "azurerm_key_vault_certificate" "apim_internal_certificate" {
  name         = var.apim_api_internal_certificate_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

#--------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "rg_api" {
  name     = "${local.program}-api-rg"
  location = var.location

  tags = var.tags
}

# APIM subnet
module "apim_snet" {
  source               = "git::https://github.com/pagopa/terraform-azurerm-v3.git//subnet?ref=v8.8.0"
  name                 = "${local.program}-apim-snet"
  resource_group_name  = data.azurerm_resource_group.rg_vnet.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = var.cidr_subnet_apim

  private_endpoint_network_policies_enabled = true
  service_endpoints                         = ["Microsoft.Web"]
}

###########################
## Api Management (apim) ##
###########################

module "apim" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//api_management?ref=v8.8.0"

  name = "${local.program}-apim"

  subnet_id           = module.apim_snet.id
  location            = azurerm_resource_group.rg_api.location
  resource_group_name = azurerm_resource_group.rg_api.name

  publisher_name       = var.apim_publisher_name
  publisher_email      = data.azurerm_key_vault_secret.apim_publisher_email.value
  sku_name             = var.apim_sku
  virtual_network_type = "Internal"

  redis_connection_string = null
  redis_cache_id          = null

  # This enables the Username and Password Identity Provider
  sign_up_enabled = false

  lock_enable                              = var.lock_enable
  application_insights_instrumentation_key = data.azurerm_application_insights.application_insights.instrumentation_key

  tags = var.tags
}

#
# 🔐 Key Vault Access Policies
#

## api management policy ##
resource "azurerm_key_vault_access_policy" "api_management_policy" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.apim.principal_id

  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  storage_permissions     = []
}

#
# 🏷 custom domain
#
resource "azurerm_api_management_custom_domain" "api_custom_domain" {
  api_management_id = module.apim.id

  gateway {
    host_name = local.api_internal_domain
    key_vault_id = replace(
      data.azurerm_key_vault_certificate.apim_internal_certificate.secret_id,
      "/${data.azurerm_key_vault_certificate.apim_internal_certificate.version}",
      ""
    )
  }
}

# api.internal.*.userregistry.pagopa.it
resource "azurerm_private_dns_a_record" "api_internal" {

  name    = "api"
  records = module.apim.*.private_ip_addresses[0]
  ttl     = var.dns_default_ttl_sec

  zone_name           = data.azurerm_private_dns_zone.internal.name
  resource_group_name = data.azurerm_resource_group.rg_vnet.name

  tags = var.tags
}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_api_management.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | resource |
| [azurerm_api_management_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_certificate) | resource |
| [azurerm_api_management_diagnostic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_diagnostic) | resource |
| [azurerm_api_management_logger.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_logger) | resource |
| [azurerm_api_management_redis_cache.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_redis_cache) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_autoscale_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_autoscale_setting) | resource |
| [azurerm_monitor_diagnostic_setting.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_key_vault_certificate.key_vault_certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | Should Metrics Alert be enabled? | `bool` | `true` | no |
| <a name="input_application_insights"></a> [application\_insights](#input\_application\_insights) | Application Insights integration The instrumentation key used to push data | <pre>object({<br>    enabled             = bool<br>    instrumentation_key = string<br>  })</pre> | n/a | yes |
| <a name="input_autoscale"></a> [autoscale](#input\_autoscale) | Configure Apim autoscale rule on capacity metric | <pre>object(<br>    {<br>      enabled                       = bool<br>      default_instances             = number<br>      minimum_instances             = number<br>      maximum_instances             = number<br>      scale_out_capacity_percentage = number<br>      scale_out_time_window         = string<br>      scale_out_value               = string<br>      scale_out_cooldown            = string<br>      scale_in_capacity_percentage  = number<br>      scale_in_time_window          = string<br>      scale_in_value                = string<br>      scale_in_cooldown             = string<br>    }<br>  )</pre> | <pre>{<br>  "default_instances": 1,<br>  "enabled": true,<br>  "maximum_instances": 5,<br>  "minimum_instances": 1,<br>  "scale_in_capacity_percentage": 30,<br>  "scale_in_cooldown": "PT30M",<br>  "scale_in_time_window": "PT30M",<br>  "scale_in_value": "1",<br>  "scale_out_capacity_percentage": 60,<br>  "scale_out_cooldown": "PT45M",<br>  "scale_out_time_window": "PT10M",<br>  "scale_out_value": "2"<br>}</pre> | no |
| <a name="input_certificate_names"></a> [certificate\_names](#input\_certificate\_names) | List of key vault certificate name | `list(string)` | `[]` | no |
| <a name="input_diagnostic_always_log_errors"></a> [diagnostic\_always\_log\_errors](#input\_diagnostic\_always\_log\_errors) | Always log errors. Send telemetry if there is an erroneous condition, regardless of sampling settings. | `bool` | `true` | no |
| <a name="input_diagnostic_backend_request"></a> [diagnostic\_backend\_request](#input\_diagnostic\_backend\_request) | Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1 | <pre>set(object(<br>    {<br>      body_bytes     = number<br>      headers_to_log = set(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_diagnostic_backend_response"></a> [diagnostic\_backend\_response](#input\_diagnostic\_backend\_response) | Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1 | <pre>set(object(<br>    {<br>      body_bytes     = number<br>      headers_to_log = set(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_diagnostic_frontend_request"></a> [diagnostic\_frontend\_request](#input\_diagnostic\_frontend\_request) | Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1 | <pre>set(object(<br>    {<br>      body_bytes     = number<br>      headers_to_log = set(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_diagnostic_frontend_response"></a> [diagnostic\_frontend\_response](#input\_diagnostic\_frontend\_response) | Number of payload bytes to log (up to 8192) and a list of headers to log, min items: 0, max items: 1 | <pre>set(object(<br>    {<br>      body_bytes     = number<br>      headers_to_log = set(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_diagnostic_http_correlation_protocol"></a> [diagnostic\_http\_correlation\_protocol](#input\_diagnostic\_http\_correlation\_protocol) | The HTTP Correlation Protocol to use. Possible values are None, Legacy or W3C. | `string` | `"W3C"` | no |
| <a name="input_diagnostic_log_client_ip"></a> [diagnostic\_log\_client\_ip](#input\_diagnostic\_log\_client\_ip) | Log client IP address. | `bool` | `true` | no |
| <a name="input_diagnostic_sampling_percentage"></a> [diagnostic\_sampling\_percentage](#input\_diagnostic\_sampling\_percentage) | Sampling (%). For high traffic APIs, please read the documentation to understand performance implications and log sampling. Valid values are between 0.0 and 100.0. | `number` | `5` | no |
| <a name="input_diagnostic_verbosity"></a> [diagnostic\_verbosity](#input\_diagnostic\_verbosity) | Logging verbosity. Possible values are verbose, information or error. | `string` | `"error"` | no |
| <a name="input_hostname_configuration"></a> [hostname\_configuration](#input\_hostname\_configuration) | Custom domains | <pre>object({<br><br>    proxy = list(object(<br>      {<br>        default_ssl_binding = bool<br>        host_name           = string<br>        key_vault_id        = string<br>    }))<br><br>    management = object({<br>      host_name    = string<br>      key_vault_id = string<br>    })<br><br>    portal = object({<br>      host_name    = string<br>      key_vault_id = string<br>    })<br><br>    developer_portal = object({<br>      host_name    = string<br>      key_vault_id = string<br>    })<br><br>  })</pre> | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Key vault id. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_lock_enable"></a> [lock\_enable](#input\_lock\_enable) | Apply lock to block accedentaly deletions. | `bool` | `false` | no |
| <a name="input_metric_alerts"></a> [metric\_alerts](#input\_metric\_alerts) | Map of name = criteria objects | <pre>map(object({<br>    description = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br>    # Possible values are 0, 1, 2, 3.<br>    severity = number<br>    # Possible values are true, false<br>    auto_mitigate = bool<br><br>    criteria = set(object(<br>      {<br>        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>        aggregation = string<br>        dimension = list(object(<br>          {<br>            name     = string<br>            operator = string<br>            values   = list(string)<br>          }<br>        ))<br>        metric_name      = string<br>        metric_namespace = string<br>        # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>        operator               = string<br>        skip_metric_validation = bool<br>        threshold              = number<br>      }<br>    ))<br><br>    dynamic_criteria = set(object(<br>      {<br>        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>        aggregation       = string<br>        alert_sensitivity = string<br>        dimension = list(object(<br>          {<br>            name     = string<br>            operator = string<br>            values   = list(string)<br>          }<br>        ))<br>        evaluation_failure_count = number<br>        evaluation_total_count   = number<br>        ignore_data_before       = string<br>        metric_name              = string<br>        metric_namespace         = string<br>        operator                 = string<br>        skip_metric_validation   = bool<br>      }<br>    ))<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email) | Email address from which the notification will be sent. | `string` | `null` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | (Deprecated). Path of the policy file. | `string` | `null` | no |
| <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id) | A Public Ip resource ID | `string` | `null` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | The email of publisher/company. | `string` | n/a | yes |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | The name of publisher/company. | `string` | n/a | yes |
| <a name="input_redis_cache_enabled"></a> [redis\_cache\_enabled](#input\_redis\_cache\_enabled) | (Optional) if true, enables redis caching | `bool` | `false` | no |
| <a name="input_redis_cache_id"></a> [redis\_cache\_id](#input\_redis\_cache\_id) | The resource ID of the Cache for Redis. Set `redis_cache_enabled` = true tuse this value | `string` | n/a | yes |
| <a name="input_redis_connection_string"></a> [redis\_connection\_string](#input\_redis\_connection\_string) | Connection string for redis external cache. Set `redis_cache_enabled` = true tuse this value | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_sec_log_analytics_workspace_id"></a> [sec\_log\_analytics\_workspace\_id](#input\_sec\_log\_analytics\_workspace\_id) | Log analytics workspace security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sec_storage_id"></a> [sec\_storage\_id](#input\_sec\_storage\_id) | Storage Account security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sign_up_enabled"></a> [sign\_up\_enabled](#input\_sign\_up\_enabled) | Can users sign up on the development portal? | `bool` | `false` | no |
| <a name="input_sign_up_terms_of_service"></a> [sign\_up\_terms\_of\_service](#input\_sign\_up\_terms\_of\_service) | the development portal terms\_of\_service | <pre>object(<br>    {<br>      consent_required = bool<br>      enabled          = bool<br>      text             = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | A string consisting of two parts separated by an underscore(\_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer\_1). | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The id of the subnet that will be used for the API Management. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type) | The type of virtual network you want to use, valid values include: None, External, Internal | `string` | `null` | no |
| <a name="input_xml_content"></a> [xml\_content](#input\_xml\_content) | Xml content for all api policy | `string` | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | List of availability zones | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_id"></a> [diagnostic\_id](#output\_diagnostic\_id) | n/a |
| <a name="output_gateway_hostname"></a> [gateway\_hostname](#output\_gateway\_hostname) | n/a |
| <a name="output_gateway_url"></a> [gateway\_url](#output\_gateway\_url) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_logger_id"></a> [logger\_id](#output\_logger\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | n/a |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
