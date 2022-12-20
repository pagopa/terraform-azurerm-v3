# app gateway

<!-- vscode-markdown-toc -->
* 1. [Architecture](#Architecture)
* 2. [How to use it](#Howtouseit)
	* 2.1. [External resources](#Externalresources)
	* 2.2. [App gateway definition](#Appgatewaydefinition)
* 3. [Requirements](#Requirements)
* 4. [Providers](#Providers)
* 5. [Modules](#Modules)
* 6. [Resources](#Resources)
* 7. [Inputs](#Inputs)
* 8. [Outputs](#Outputs)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


Module that allows the creation of an App Gateway.

##  1. <a name='Architecture'></a>Architecture

![architecture](./docs/module-arch.drawio.png)

##  2. <a name='Howtouseit'></a>How to use it

###  2.1. <a name='Externalresources'></a>External resources

```ts
data "azurerm_public_ip" "appgateway_public_ip" {
  resource_group_name = data.azurerm_resource_group.rg_vnet.name
  name                = local.pip_appgw_name
}

data "azurerm_key_vault_certificate" "app_gw_api" {
  name         = var.app_gateway_api_certificate_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

## user assined identity: (application gateway) ##
resource "azurerm_user_assigned_identity" "appgateway" {
  resource_group_name = data.azurerm_resource_group.kv_rg.name
  location            = data.azurerm_resource_group.kv_rg.location
  name                = format("%s-appgateway-identity", local.project)

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "app_gateway_policy" {
  key_vault_id            = data.azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_user_assigned_identity.appgateway.principal_id
  key_permissions         = []
  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
  storage_permissions     = []
}

# Subnet to host the application gateway
module "appgateway_snet" {
  source               = "git::https://github.com/pagopa/azurerm.git//subnet?ref=v2.1.21"

  name                 = "${local.project}-appgateway-snet"
  address_prefixes     = var.cidr_subnet_appgateway
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  
  resource_group_name  = data.azurerm_resource_group.rg_vnet.name
}
```

###  2.2. <a name='Appgatewaydefinition'></a>App gateway definition

```ts
## Application gateway ##
module "app_gw" {
  source = "git::https://github.com/pagopa/azurerm.git//app_gateway?ref=v2.1.21"

  name                = "${local.project}-app-gw"
  resource_group_name = data.azurerm_resource_group.rg_vnet.name
  location            = data.azurerm_resource_group.rg_vnet.location

  # SKU
  sku_name = var.app_gateway_sku_name
  sku_tier = var.app_gateway_sku_tier

  # WAF
  waf_enabled = var.app_gateway_waf_enabled

  # Networking
  subnet_id    = module.appgateway_snet.id
  public_ip_id = data.azurerm_public_ip.appgateway_public_ip.id

  # Configure backends
  backends = {

    apim = {
      protocol                    = "Https"
      host                        = "api.internal.devopslab.pagopa.it"
      port                        = 443
      ip_addresses                = null # with null value use fqdns
      fqdns                       = ["api.internal.devopslab.pagopa.it"]
      probe_name                  = "probe-apim"
      probe                       = "/status-0123456789abcdef"
      request_timeout             = 2
      pick_host_name_from_backend = false
    }
  }

  trusted_client_certificates = []

  # Configure listeners
  listeners = {

    api = {
      protocol           = "Https"
      host               = "api.${var.prod_dns_zone_prefix}.${var.external_domain}"
      port               = 443
      ssl_profile_name   = null
      firewall_policy_id = null

      certificate = {
        name = var.app_gateway_api_certificate_name
        id = replace(
          data.azurerm_key_vault_certificate.app_gw_api.secret_id,
          "/${data.azurerm_key_vault_certificate.app_gw_api.version}",
          ""
        )
      }
    }
  }

  # maps listener to backend
  routes = {
    api = {
      listener              = "api"
      backend               = "apim"
      rewrite_rule_set_name = "rewrite-rule-set-api"
    }
  }

  rewrite_rule_sets = [
    {
      name = "rewrite-rule-set-api"
      rewrite_rules = [{
        name          = "http-headers-api"
        rule_sequence = 100
        condition     = null
        request_header_configurations = [
          {
            header_name  = "X-Forwarded-For"
            header_value = "{var_client_ip}"
          },
          {
            header_name  = "X-Client-Ip"
            header_value = "{var_client_ip}"
          },
        ]
        response_header_configurations = []
        url = null
      }]
    },
  ]

  # TLS
  identity_ids = [azurerm_user_assigned_identity.appgateway.id]

  # Scaling
  app_gateway_min_capacity = var.app_gateway_min_capacity
  app_gateway_max_capacity = var.app_gateway_max_capacity

  # Logs
  # sec_log_analytics_workspace_id = var.env_short == "p" ? data.azurerm_key_vault_secret.sec_workspace_id[0].value : null
  # sec_storage_id                 = var.env_short == "p" ? data.azurerm_key_vault_secret.sec_storage_id[0].value : null

  alerts_enabled = var.app_gateway_alerts_enabled

  action = [
    {
      action_group_id    = data.azurerm_monitor_action_group.slack.id
      webhook_properties = null
    },
    {
      action_group_id    = data.azurerm_monitor_action_group.email.id
      webhook_properties = null
    }
  ]

  # metrics docs
  # https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported#microsoftnetworkapplicationgateways
  monitor_metric_alert_criteria = {

    compute_units_usage = {
      description   = "Abnormal compute units usage, probably an high traffic peak"
      frequency     = "PT5M"
      window_size   = "PT5M"
      severity      = 2
      auto_mitigate = true

      criteria = []
      dynamic_criteria = [
        {
          aggregation              = "Average"
          metric_name              = "ComputeUnits"
          operator                 = "GreaterOrLessThan"
          alert_sensitivity        = "High"
          evaluation_total_count   = 2
          evaluation_failure_count = 2
          dimension                = []
        }
      ]
    }

    backend_pools_status = {
      description   = "One or more backend pools are down, check Backend Health on Azure portal"
      frequency     = "PT5M"
      window_size   = "PT5M"
      severity      = 0
      auto_mitigate = true

      criteria = [
        {
          aggregation = "Average"
          metric_name = "UnhealthyHostCount"
          operator    = "GreaterThan"
          threshold   = 0
          dimension   = []
        }
      ]
      dynamic_criteria = []
    }

    response_time = {
      description   = "Backends response time is too high"
      frequency     = "PT5M"
      window_size   = "PT5M"
      severity      = 2
      auto_mitigate = true

      criteria = []
      dynamic_criteria = [
        {
          aggregation              = "Average"
          metric_name              = "BackendLastByteResponseTime"
          operator                 = "GreaterThan"
          alert_sensitivity        = "High"
          evaluation_total_count   = 2
          evaluation_failure_count = 2
          dimension                = []
        }
      ]
    }

    total_requests = {
      description   = "Traffic is raising"
      frequency     = "PT5M"
      window_size   = "PT15M"
      severity      = 3
      auto_mitigate = true

      criteria = []
      dynamic_criteria = [
        {
          aggregation              = "Total"
          metric_name              = "TotalRequests"
          operator                 = "GreaterThan"
          alert_sensitivity        = "Medium"
          evaluation_total_count   = 1
          evaluation_failure_count = 1
          dimension                = []
        }
      ]
    }

    failed_requests = {
      description   = "Abnormal failed requests"
      frequency     = "PT5M"
      window_size   = "PT5M"
      severity      = 1
      auto_mitigate = true

      criteria = []
      dynamic_criteria = [
        {
          aggregation              = "Total"
          metric_name              = "FailedRequests"
          operator                 = "GreaterThan"
          alert_sensitivity        = "High"
          evaluation_total_count   = 2
          evaluation_failure_count = 2
          dimension                = []
        }
      ]
    }
  }

  tags = var.tags
}

```

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | <= 3.36.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_monitor_diagnostic_setting.app_gw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_key_vault_secret.client_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | The ID of the Action Group and optional map of custom string properties to include with the post webhook operation. | <pre>set(object(<br>    {<br>      action_group_id    = string<br>      webhook_properties = map(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_alerts_enabled"></a> [alerts\_enabled](#input\_alerts\_enabled) | Should Metric Alerts be enabled? | `bool` | `true` | no |
| <a name="input_app_gateway_max_capacity"></a> [app\_gateway\_max\_capacity](#input\_app\_gateway\_max\_capacity) | (Optional) Maximum capacity for autoscaling. Accepted values are in the range 2 to 125. | `string` | n/a | yes |
| <a name="input_app_gateway_min_capacity"></a> [app\_gateway\_min\_capacity](#input\_app\_gateway\_min\_capacity) | (Required) Minimum capacity for autoscaling. Accepted values are in the range 0 to 100. | `string` | n/a | yes |
| <a name="input_backends"></a> [backends](#input\_backends) | Obj that allow to configure: backend\_address\_pool, backend\_http\_settings, probe | <pre>map(object({<br>    protocol                    = string       # The Protocol which should be used. Possible values are Http and Https<br>    host                        = string       # The Hostname used for this Probe. If the Application Gateway is configured for a single site, by default the Host name should be specified as ‘127.0.0.1’, unless otherwise configured in custom probe. Cannot be set if pick_host_name_from_backend_http_settings is set to true<br>    port                        = number       # Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from http settings will be used.<br>    ip_addresses                = list(string) # A list of IP Addresses which should be part of the Backend Address Pool.<br>    fqdns                       = list(string) # A list of FQDN's which should be part of the Backend Address Pool.<br>    probe                       = string       # The Path used for this Probe.<br>    probe_name                  = string       # The Name of the Probe.<br>    request_timeout             = number       # The Timeout used for this Probe, which indicates when a probe becomes unhealthy. Possible values range from 1 second to a maximum of 86,400 seconds.<br>    pick_host_name_from_backend = bool         # Whether the host header should be picked from the backend http settings<br>  }))</pre> | n/a | yes |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | n/a | <pre>map(object({<br>    protocol           = string # The Protocol which should be used. Possible values are Http and Https<br>    host               = string # The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to 'Multi site'.<br>    port               = number # The port used for this Frontend Port.<br>    ssl_profile_name   = string # The name of the associated SSL Profile which should be used for this HTTP Listener.<br>    firewall_policy_id = string # The ID of the Web Application Firewall Policy which should be used for this HTTP Listener.<br>    certificate = object({<br>      name = string # The Name of the SSL certificate that is unique within this Application Gateway<br>      id   = string # Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set.<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"westeurope"` | no |
| <a name="input_monitor_metric_alert_criteria"></a> [monitor\_metric\_alert\_criteria](#input\_monitor\_metric\_alert\_criteria) | Map of name = criteria objects, see these docs for options<br>https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported#microsoftnetworkapplicationgateways | <pre>map(object({<br><br>    description = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M and PT1H<br>    frequency = string<br>    # Possible values are PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H and P1D.<br>    window_size = string<br>    # Possible values are 0, 1, 2, 3.<br>    severity = number<br>    # Possible values are true, false<br>    auto_mitigate = bool<br><br>    # static<br>    criteria = list(object(<br>      {<br>        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>        aggregation = string<br>        metric_name = string<br>        # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>        operator  = string<br>        threshold = number<br><br>        dimension = list(object(<br>          {<br>            name     = string<br>            operator = string<br>            values   = list(string)<br>          }<br>        ))<br>      }<br>    ))<br><br>    # dynamic<br>    dynamic_criteria = list(object(<br>      {<br>        # criteria.*.aggregation to be one of [Average Count Minimum Maximum Total]<br>        aggregation = string<br>        metric_name = string<br>        # criteria.0.operator to be one of [Equals NotEquals GreaterThan GreaterThanOrEqual LessThan LessThanOrEqual]<br>        operator = string<br>        # Possible values are Low, Medium, High<br>        alert_sensitivity = string<br><br>        evaluation_total_count   = number<br>        evaluation_failure_count = number<br><br>        dimension = list(object(<br>          {<br>            name     = string<br>            operator = string<br>            values   = list(string)<br>          }<br>        ))<br>      }<br>    ))<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_public_ip_id"></a> [public\_ip\_id](#input\_public\_ip\_id) | Public IP | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_rewrite_rule_sets"></a> [rewrite\_rule\_sets](#input\_rewrite\_rule\_sets) | Rewrite rules sets obj descriptor | <pre>list(object({<br>    name = string # Unique name of the rewrite rule set block<br>    rewrite_rules = list(object({<br>      name          = string # Unique name of the rewrite rule block<br>      rule_sequence = number # Rule sequence of the rewrite rule that determines the order of execution in a set.<br>      condition = object({   # One or more condition blocks as defined above.<br>        variable    = string # The variable of the condition.<br>        pattern     = string # The pattern, either fixed string or regular expression, that evaluates the truthfulness of the condition.<br>        ignore_case = bool   # Perform a case in-sensitive comparison. Defaults to false<br>        negate      = bool   # Negate the result of the condition evaluation. Defaults to false<br>      })<br><br>      request_header_configurations = list(object({<br>        header_name  = string # Header name of the header configuration.<br>        header_value = string # Header value of the header configuration. To delete a request header set this property to an empty string.<br>      }))<br><br>      response_header_configurations = list(object({<br>        header_name  = string # Header name of the header configuration.<br>        header_value = string # Header value of the header configuration. To delete a response header set this property to an empty string.<br>      }))<br><br>      url = object({<br>        path         = string # The URL path to rewrite.<br>        query_string = string # The query string to rewrite.<br>      })<br><br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | n/a | <pre>map(object({<br>    listener              = string # Prefix for http_listener_name<br>    backend               = string # Prefix for backend_address_pool_name, backend_http_settings_name<br>    rewrite_rule_set_name = string # The Name of the Rewrite Rule Set which should be used for this Routing Rule.<br>  }))</pre> | n/a | yes |
| <a name="input_routes_path_based"></a> [routes\_path\_based](#input\_routes\_path\_based) | To configure path based routing | <pre>map(object({<br>    listener     = string # Prefix for http_listener_name<br>    url_map_name = string # The Name of the URL Path Map which should be associated with this Routing Rule.<br>    priority     = number # Rule evaluation order can be dictated by specifying an integer value from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.<br>  }))</pre> | `{}` | no |
| <a name="input_sec_log_analytics_workspace_id"></a> [sec\_log\_analytics\_workspace\_id](#input\_sec\_log\_analytics\_workspace\_id) | Log analytics workspace security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sec_storage_id"></a> [sec\_storage\_id](#input\_sec\_storage\_id) | Storage Account security (it should be in a different subscription). | `string` | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU Name of the App GW | `string` | n/a | yes |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier of the App GW | `string` | n/a | yes |
| <a name="input_ssl_profiles"></a> [ssl\_profiles](#input\_ssl\_profiles) | n/a | <pre>list(object({<br>    name                             = string       # The name of the SSL Profile that is unique within this Application Gateway.<br>    trusted_client_certificate_names = list(string) # The name of the Trusted Client Certificate that will be used to authenticate requests from clients.<br>    verify_client_cert_issuer_dn     = bool         # Should client certificate issuer DN be verified? Defaults to false<br><br>    ssl_policy = object({<br>      disabled_protocols   = list(string) # A list of SSL Protocols which should be disabled on this Application Gateway. Possible values are TLSv1_0, TLSv1_1 and TLSv1_2.<br>      policy_type          = string       # The Type of the Policy. Possible values are Predefined and Custom.<br>      policy_name          = string       # The Name of the Policy e.g AppGwSslPolicy20170401S. Required if policy_type is set to Predefined. Possible values can change over time and are published here https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview. Not compatible with disabled_protocols.<br>      cipher_suites        = list(string) # A List of accepted cipher suites. see https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#cipher_suites for possible values<br>      min_protocol_version = string       # The minimal TLS version. Possible values are TLSv1_0, TLSv1_1 and TLSv1_2.<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet dedicated to the app gateway | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |
| <a name="input_trusted_client_certificates"></a> [trusted\_client\_certificates](#input\_trusted\_client\_certificates) | Note: the attribute secret\_name refers to the secret contaning the client certificate. Secrects'name in the key vault can't have low hyphens but just hyphens in it. | <pre>list(object({<br>    secret_name  = string # The name of the Trusted Client Certificate that is unique within this Application Gateway.<br>    key_vault_id = string # Key vault id, that contains the certificate.<br>  }))</pre> | n/a | yes |
| <a name="input_url_path_map"></a> [url\_path\_map](#input\_url\_path\_map) | To configure the mapping between path and backend | <pre>map(object({<br>    default_backend               = string # Prefix for backend_address_pool_name, backend_http_settings_name<br>    default_rewrite_rule_set_name = string # The Name of the Rewrite Rule Set which should be used for this Routing Rule.<br>    path_rule = map(object({<br>      paths                 = list(string) # A list of Paths used in this Path Rule<br>      backend               = string<br>      rewrite_rule_set_name = string # The Name of the Rewrite Rule Set which should be used for this URL Path Map<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_waf_disabled_rule_group"></a> [waf\_disabled\_rule\_group](#input\_waf\_disabled\_rule\_group) | n/a | <pre>list(object({<br>    rule_group_name = string       # The rule group where specific rules should be disabled.<br>    rules           = list(string) # A list of rules which should be disabled in that group. Disables all rules in the specified group if rules is not specified.<br>  }))</pre> | `[]` | no |
| <a name="input_waf_enabled"></a> [waf\_enabled](#input\_waf\_enabled) | Enable WAF | `bool` | `true` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | (Optional) Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created. | `list(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
