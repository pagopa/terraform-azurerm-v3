data "azurerm_key_vault_secret" "client_cert" {
  for_each     = { for t in var.trusted_client_certificates : t.secret_name => t }
  name         = each.value.secret_name
  key_vault_id = each.value.key_vault_id
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones

  sku {
    name = var.sku_name
    tier = var.sku_tier
  }

  gateway_ip_configuration {
    name      = "${var.name}-snet-conf"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "${var.name}-ip-conf"
    public_ip_address_id = var.public_ip_id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip_address
    iterator = private
    content {
      name                          = "${var.name}-private-ip-conf"
      private_ip_address            = private.value
      private_ip_address_allocation = "Static"
      subnet_id                     = var.subnet_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backends
    iterator = backend
    content {
      name         = "${backend.key}-address-pool"
      fqdns        = backend.value.ip_addresses == null ? backend.value.fqdns : null
      ip_addresses = backend.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backends
    iterator = backend

    content {
      name                                = "${backend.key}-http-settings"
      host_name                           = backend.value.host
      cookie_based_affinity               = "Disabled"
      affinity_cookie_name                = "ApplicationGatewayAffinity" # to avoid unwanted changes in terraform plan
      path                                = ""
      port                                = backend.value.port
      protocol                            = backend.value.protocol
      request_timeout                     = backend.value.request_timeout
      probe_name                          = backend.value.probe_name
      pick_host_name_from_backend_address = backend.value.pick_host_name_from_backend
    }
  }

  dynamic "probe" {
    for_each = var.backends
    iterator = backend

    content {
      host                                      = backend.value.host
      minimum_servers                           = 0
      name                                      = "probe-${backend.key}"
      path                                      = backend.value.probe
      pick_host_name_from_backend_http_settings = backend.value.pick_host_name_from_backend
      protocol                                  = backend.value.protocol
      timeout                                   = 30
      interval                                  = 30
      unhealthy_threshold                       = 3

      match {
        status_code = ["200-399"]
      }
    }
  }

  dynamic "frontend_port" {
    for_each = distinct([for listener in values(var.listeners) : listener.port])

    content {
      name = "${var.name}-${frontend_port.value}-port"
      port = frontend_port.value
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.listeners
    iterator = listener

    content {
      name                = listener.value.certificate.name
      key_vault_secret_id = listener.value.certificate.id
    }
  }

  dynamic "trusted_client_certificate" {
    for_each = var.trusted_client_certificates
    iterator = t
    content {
      name = t.value.secret_name
      data = data.azurerm_key_vault_secret.client_cert[t.value.secret_name].value
    }
  }

  dynamic "ssl_profile" {
    for_each = var.ssl_profiles
    iterator = p
    content {
      name                             = p.value.name
      trusted_client_certificate_names = p.value.trusted_client_certificate_names
      verify_client_cert_issuer_dn     = p.value.verify_client_cert_issuer_dn
      ssl_policy {
        disabled_protocols   = p.value.ssl_policy.disabled_protocols
        policy_type          = p.value.ssl_policy.policy_type
        policy_name          = p.value.ssl_policy.policy_name
        cipher_suites        = p.value.ssl_policy.cipher_suites
        min_protocol_version = p.value.ssl_policy.min_protocol_version
      }
    }
  }

  dynamic "http_listener" {
    for_each = { for key, listener in var.listeners : key => listener }
    iterator = listener

    content {
      name                           = "${listener.key}-listener"
      frontend_ip_configuration_name = listener.value.type == "Private" ? "${var.name}-private-ip-conf" : "${var.name}-ip-conf"
      frontend_port_name             = "${var.name}-${listener.value.port}-port"
      protocol                       = "Https"
      ssl_certificate_name           = listener.value.certificate.name
      require_sni                    = true
      host_name                      = listener.value.host
      ssl_profile_name               = listener.value.ssl_profile_name
      firewall_policy_id             = listener.value.firewall_policy_id
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routes_path_based
    iterator = route

    content {
      name               = "${route.key}-reqs-routing-rule-by-path"
      rule_type          = "PathBasedRouting"
      http_listener_name = "${route.value.listener}-listener"
      url_path_map_name  = "${route.value.url_map_name}-url-map"
      priority           = route.value.priority
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_map
    iterator = path

    content {
      name                               = "${path.key}-url-map"
      default_backend_address_pool_name  = "${path.value.default_backend}-address-pool"
      default_backend_http_settings_name = "${path.value.default_backend}-http-settings"
      default_rewrite_rule_set_name      = path.value.default_rewrite_rule_set_name

      dynamic "path_rule" {
        for_each = path.value.path_rule
        iterator = path_rule

        content {
          name                       = path_rule.key
          paths                      = path_rule.value.paths
          backend_address_pool_name  = "${path_rule.value.backend}-address-pool"
          backend_http_settings_name = "${path_rule.value.backend}-http-settings"
          rewrite_rule_set_name      = path_rule.value.rewrite_rule_set_name
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routes
    iterator = route

    content {
      #⚠️ backend_address_pool_name, backend_http_settings_name, redirect_configuration_name, and rewrite_rule_set_name are applicable only when rule_type is Basic.
      name                       = "${route.key}-reqs-routing-rule"
      rule_type                  = "Basic" #(Required) The Type of Routing that should be used for this Rule. Possible values are Basic and PathBasedRouting.
      http_listener_name         = "${route.value.listener}-listener"
      backend_address_pool_name  = "${route.value.backend}-address-pool"
      backend_http_settings_name = "${route.value.backend}-http-settings"
      rewrite_rule_set_name      = route.value.rewrite_rule_set_name
      priority                   = route.value.priority
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.rewrite_rule_sets
    iterator = rule_set
    content {
      name = rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rule_set.value.rewrite_rules
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = rewrite_rule.value.conditions
            iterator = condition
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = rewrite_rule.value.request_header_configurations
            iterator = req_header
            content {
              header_name  = req_header.value.header_name
              header_value = req_header.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = rewrite_rule.value.response_header_configurations
            iterator = res_header
            content {
              header_name  = res_header.value.header_name
              header_value = res_header.value.header_value
            }
          }

          dynamic "url" {
            for_each = rewrite_rule.value.url != null ? ["dummy"] : []

            content {
              path         = rewrite_rule.value.url.path
              query_string = rewrite_rule.value.url.query_string
            }
          }
        }
      }

    }
  }

  # see: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway#identity
  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }

  ssl_policy {
    policy_type = "Custom"
    # this cipher suites are the defaults ones
    cipher_suites = [
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    ]
    min_protocol_version = "TLSv1_2"
  }

  dynamic "waf_configuration" {
    for_each = var.waf_enabled ? ["dummy"] : []
    content {
      enabled                  = true
      firewall_mode            = "Detection"
      rule_set_type            = "OWASP"
      rule_set_version         = "3.1"
      request_body_check       = true
      file_upload_limit_mb     = 100
      max_request_body_size_kb = 128

      dynamic "disabled_rule_group" {
        for_each = var.waf_disabled_rule_group
        iterator = disabled_rule_group

        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }
    }
  }

  autoscale_configuration {
    min_capacity = var.app_gateway_min_capacity
    max_capacity = var.app_gateway_max_capacity
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "app_gw" {
  count                      = var.sec_log_analytics_workspace_id != null ? 1 : 0
  name                       = "LogSecurity"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.sec_log_analytics_workspace_id
  storage_account_id         = var.sec_storage_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

locals {
  metric_namespace              = "Microsoft.Network/applicationgateways"
  monitor_metric_alert_criteria = var.alerts_enabled ? var.monitor_metric_alert_criteria : {}
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = local.monitor_metric_alert_criteria

  name                = "${azurerm_application_gateway.this.name}-${upper(each.key)}"
  description         = each.value.description
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.this.id]
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  enabled             = true
  severity            = each.value.severity
  auto_mitigate       = each.value.auto_mitigate

  dynamic "action" {
    for_each = var.action
    content {
      # action_group_id - (required) is a type of string
      action_group_id = action.value["action_group_id"]
      # webhook_properties - (optional) is a type of map of string
      webhook_properties = action.value["webhook_properties"]
    }
  }

  dynamic "criteria" {
    for_each = each.value.criteria
    content {
      aggregation      = criteria.value.aggregation
      metric_namespace = local.metric_namespace
      metric_name      = criteria.value.metric_name
      operator         = criteria.value.operator
      threshold        = criteria.value.threshold

      dynamic "dimension" {
        for_each = criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  dynamic "dynamic_criteria" {
    for_each = each.value.dynamic_criteria
    content {
      aggregation              = dynamic_criteria.value.aggregation
      metric_namespace         = local.metric_namespace
      metric_name              = dynamic_criteria.value.metric_name
      operator                 = dynamic_criteria.value.operator
      alert_sensitivity        = dynamic_criteria.value.alert_sensitivity
      evaluation_total_count   = dynamic_criteria.value.evaluation_total_count
      evaluation_failure_count = dynamic_criteria.value.evaluation_failure_count

      dynamic "dimension" {
        for_each = dynamic_criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }
}
