locals {
  cdn_location = var.cdn_location != null ? var.cdn_location : var.location
}

/**
 * Storage account
 **/
module "cdn_storage_account" {

  source = "github.com/pagopa/terraform-azurerm-v3.git//storage_account?ref=v8.8.0"

  name = replace("${var.prefix}-${var.name}-sa", "-", "")

  account_kind                    = var.storage_account_kind
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  access_tier                     = var.storage_access_tier
  blob_versioning_enabled         = true
  resource_group_name             = var.resource_group_name
  location                        = var.location
  allow_nested_items_to_be_public = var.storage_account_nested_items_public
  public_network_access_enabled   = true

  advanced_threat_protection                 = var.advanced_threat_protection_enabled
  enable_resource_advanced_threat_protection = var.resource_advanced_threat_protection_enabled

  index_document     = var.index_document
  error_404_document = var.error_404_document

  tags = var.tags
}

/**
 * cdn profile
 **/
resource "azurerm_cdn_profile" "this" {
  name                = "${var.prefix}-${var.name}-cdn-profile"
  resource_group_name = var.resource_group_name
  location            = local.cdn_location
  sku                 = "Standard_Microsoft"

  tags = var.tags
}

resource "azurerm_cdn_endpoint" "this" {
  name                          = "${var.prefix}-${var.name}-cdn-endpoint"
  resource_group_name           = var.resource_group_name
  location                      = local.cdn_location
  profile_name                  = azurerm_cdn_profile.this.name
  is_https_allowed              = true
  is_http_allowed               = true
  querystring_caching_behaviour = var.querystring_caching_behaviour
  origin_host_header            = module.cdn_storage_account.primary_web_host

  origin {
    name      = "primary"
    host_name = module.cdn_storage_account.primary_web_host
  }

  dynamic "global_delivery_rule" {
    for_each = var.global_delivery_rule == null ? [] : [var.global_delivery_rule]
    iterator = gdr
    content {

      dynamic "cache_expiration_action" {
        for_each = gdr.value.cache_expiration_action
        iterator = cea
        content {
          behavior = cea.value.behavior
          duration = cea.value.duration
        }
      }

      dynamic "modify_request_header_action" {
        for_each = gdr.value.modify_request_header_action
        iterator = mrha
        content {
          action = mrha.value.action
          name   = mrha.value.name
          value  = mrha.value.value
        }
      }

      dynamic "modify_response_header_action" {
        for_each = gdr.value.modify_response_header_action
        iterator = mrha
        content {
          action = mrha.value.action
          name   = mrha.value.name
          value  = mrha.value.value
        }
      }
    }
  }

  dynamic "delivery_rule" {
    for_each = { for d in var.delivery_rule_url_path_condition_cache_expiration_action : d.order => d }
    content {
      order = delivery_rule.key
      name  = delivery_rule.value.name
      url_path_condition {
        operator     = delivery_rule.value.operator
        match_values = delivery_rule.value.match_values
      }
      cache_expiration_action {
        behavior = delivery_rule.value.behavior
        duration = delivery_rule.value.duration
      }
      modify_response_header_action {
        action = delivery_rule.value.response_action
        name   = delivery_rule.value.response_name
        value  = delivery_rule.value.response_value
      }
    }
  }

  dynamic "delivery_rule" {
    for_each = { for d in var.delivery_rule_request_scheme_condition : d.order => d }
    content {
      name  = delivery_rule.value.name
      order = delivery_rule.value.order

      request_scheme_condition {
        operator     = delivery_rule.value.operator
        match_values = delivery_rule.value.match_values
      }

      url_redirect_action {
        redirect_type = delivery_rule.value.url_redirect_action.redirect_type
        protocol      = delivery_rule.value.url_redirect_action.protocol
        hostname      = delivery_rule.value.url_redirect_action.hostname
        path          = delivery_rule.value.url_redirect_action.path
        fragment      = delivery_rule.value.url_redirect_action.fragment
        query_string  = delivery_rule.value.url_redirect_action.query_string
      }

    }
  }

  dynamic "delivery_rule" {
    for_each = { for d in var.delivery_rule_redirect : d.order => d }
    content {
      name  = delivery_rule.value.name
      order = delivery_rule.value.order

      request_uri_condition {
        operator     = delivery_rule.value.operator
        match_values = delivery_rule.value.match_values
      }

      url_redirect_action {
        redirect_type = delivery_rule.value.url_redirect_action.redirect_type
        protocol      = delivery_rule.value.url_redirect_action.protocol
        hostname      = delivery_rule.value.url_redirect_action.hostname
        path          = delivery_rule.value.url_redirect_action.path
        fragment      = delivery_rule.value.url_redirect_action.fragment
        query_string  = delivery_rule.value.url_redirect_action.query_string
      }

    }
  }

  # rewrite HTTP to HTTPS
  dynamic "delivery_rule" {
    for_each = var.https_rewrite_enabled ? [1] : []

    content {
      name  = "EnforceHTTPS"
      order = 1

      request_scheme_condition {
        operator     = "Equal"
        match_values = ["HTTP"]
      }

      url_redirect_action {
        redirect_type = "Found"
        protocol      = "Https"
        hostname      = null
        path          = null
        fragment      = null
        query_string  = null
      }
    }
  }

  dynamic "delivery_rule" {
    for_each = { for d in var.delivery_rule_rewrite : d.order => d }
    content {
      name  = delivery_rule.value.name
      order = delivery_rule.value.order

      dynamic "request_uri_condition" {
        for_each = [for c in delivery_rule.value.conditions : c if c.condition_type == "request_uri_condition"]
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "url_path_condition" {
        for_each = [for c in delivery_rule.value.conditions : c if c.condition_type == "url_path_condition"]
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "url_file_extension_condition" {
        for_each = [for c in delivery_rule.value.conditions : c if c.condition_type == "url_file_extension_condition"]
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      url_rewrite_action {
        source_pattern          = delivery_rule.value.url_rewrite_action.source_pattern
        destination             = delivery_rule.value.url_rewrite_action.destination
        preserve_unmatched_path = delivery_rule.value.url_rewrite_action.preserve_unmatched_path
      }

    }
  }

  dynamic "delivery_rule" {
    for_each = { for d in var.delivery_rule : d.order => d }
    content {
      name  = delivery_rule.value.name
      order = delivery_rule.value.order

      // start conditions
      dynamic "cookies_condition" {
        for_each = delivery_rule.value.cookies_conditions
        iterator = c

        content {
          selector         = c.value.selector
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "device_condition" {
        for_each = delivery_rule.value.device_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
        }
      }

      dynamic "http_version_condition" {
        for_each = delivery_rule.value.http_version_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
        }
      }

      dynamic "post_arg_condition" {
        for_each = delivery_rule.value.post_arg_conditions
        iterator = c

        content {
          selector         = c.value.selector
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "query_string_condition" {
        for_each = delivery_rule.value.query_string_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "remote_address_condition" {
        for_each = delivery_rule.value.remote_address_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
        }
      }

      dynamic "request_body_condition" {
        for_each = delivery_rule.value.request_body_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "request_header_condition" {
        for_each = delivery_rule.value.request_header_conditions
        iterator = c

        content {
          selector         = c.value.selector
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "request_method_condition" {
        for_each = delivery_rule.value.request_method_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
        }
      }

      dynamic "request_scheme_condition" {
        for_each = delivery_rule.value.request_scheme_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
        }
      }

      dynamic "request_uri_condition" {
        for_each = delivery_rule.value.request_uri_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "url_file_extension_condition" {
        for_each = delivery_rule.value.url_file_extension_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "url_file_name_condition" {
        for_each = delivery_rule.value.url_file_name_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }

      dynamic "url_path_condition" {
        for_each = delivery_rule.value.url_path_conditions
        iterator = c

        content {
          operator         = c.value.operator
          match_values     = c.value.match_values
          negate_condition = c.value.negate_condition
          transforms       = c.value.transforms
        }
      }
      // end conditions

      // start actions
      dynamic "cache_expiration_action" {
        for_each = delivery_rule.value.cache_expiration_actions
        iterator = c

        content {
          behavior = c.value.behavior
          duration = c.value.duration
        }
      }

      dynamic "cache_key_query_string_action" {
        for_each = delivery_rule.value.cache_key_query_string_actions
        iterator = c

        content {
          behavior   = c.value.behavior
          parameters = c.value.parameters
        }
      }

      dynamic "modify_request_header_action" {
        for_each = delivery_rule.value.modify_request_header_actions
        iterator = c

        content {
          action = c.value.action
          name   = c.value.name
          value  = c.value.value
        }
      }

      dynamic "modify_response_header_action" {
        for_each = delivery_rule.value.modify_response_header_actions
        iterator = c

        content {
          action = c.value.action
          name   = c.value.name
          value  = c.value.value
        }
      }

      dynamic "url_redirect_action" {
        for_each = delivery_rule.value.url_redirect_actions
        iterator = c

        content {
          redirect_type = c.value.redirect_type
          protocol      = c.value.protocol
          hostname      = c.value.hostname
          path          = c.value.path
          fragment      = c.value.fragment
          query_string  = c.value.query_string
        }
      }

      dynamic "url_rewrite_action" {
        for_each = delivery_rule.value.url_rewrite_actions
        iterator = c

        content {
          source_pattern          = c.value.source_pattern
          destination             = c.value.destination
          preserve_unmatched_path = c.value.preserve_unmatched_path
        }
      }
      // end actions

    }
  }

  tags = var.tags
}

/*
* Custom Domain
*/
resource "null_resource" "apex_custom_hostname" {
  count = var.dns_zone_name == var.hostname ? 1 : 0

  depends_on = [
    azurerm_dns_a_record.apex_hostname[0],
    azurerm_dns_cname_record.apex_cdnverify[0],
    azurerm_cdn_endpoint.this,
  ]

  triggers = {
    resource_group_name = var.resource_group_name
    endpoint_name       = azurerm_cdn_endpoint.this.name
    profile_name        = azurerm_cdn_profile.this.name
    name                = var.hostname
    hostname            = var.hostname

    keyvault_resource_group_name = var.keyvault_resource_group_name
    keyvault_subscription_id     = var.keyvault_subscription_id
    keyvault_vault_name          = var.keyvault_vault_name
  }

  # https://docs.microsoft.com/it-it/cli/azure/cdn/custom-domain?view=azure-cli-latest
  provisioner "local-exec" {
    command = <<EOT
      az cdn custom-domain create \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} \
        --hostname ${self.triggers.hostname} && \
      az cdn custom-domain enable-https \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} \
        --min-tls-version "1.2" \
        --user-cert-protocol-type sni \
        --user-cert-group-name ${self.triggers.keyvault_resource_group_name} \
        --user-cert-vault-name ${self.triggers.keyvault_vault_name} \
        --user-cert-secret-name ${replace(self.triggers.name, ".", "-")} \
        --user-cert-subscription-id  ${self.triggers.keyvault_subscription_id}
    EOT
  }
  # https://docs.microsoft.com/it-it/cli/azure/cdn/custom-domain?view=azure-cli-latest
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az cdn custom-domain disable-https \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} && \
      az cdn custom-domain delete \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")}
    EOT
  }
}

resource "null_resource" "custom_hostname" {
  count = var.dns_zone_name != var.hostname && !var.custom_hostname_kv_enabled ? 1 : 0

  depends_on = [
    azurerm_dns_cname_record.hostname[0],
    azurerm_cdn_endpoint.this,
  ]

  triggers = {
    resource_group_name = var.resource_group_name
    endpoint_name       = azurerm_cdn_endpoint.this.name
    profile_name        = azurerm_cdn_profile.this.name
    name                = var.hostname
    hostname            = var.hostname
  }

  # https://docs.microsoft.com/it-it/cli/azure/cdn/custom-domain?view=azure-cli-latest
  provisioner "local-exec" {
    command = <<EOT
      az cdn custom-domain create \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} \
        --hostname ${self.triggers.hostname} && \
      az cdn custom-domain enable-https \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} \
        --min-tls-version "1.2"
    EOT
  }
  # https://docs.microsoft.com/it-it/cli/azure/cdn/custom-domain?view=azure-cli-latest
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az cdn custom-domain disable-https \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} && \
      az cdn custom-domain delete \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")}
    EOT
  }
}

resource "null_resource" "custom_hostname_kv_certificate" {
  count = var.dns_zone_name != var.hostname && var.custom_hostname_kv_enabled ? 1 : 0

  depends_on = [
    azurerm_dns_cname_record.hostname[0],
    azurerm_cdn_endpoint.this,
  ]

  triggers = {
    resource_group_name = var.resource_group_name
    endpoint_name       = azurerm_cdn_endpoint.this.name
    profile_name        = azurerm_cdn_profile.this.name
    name                = var.hostname
    hostname            = var.hostname

    keyvault_resource_group_name = var.keyvault_resource_group_name
    keyvault_subscription_id     = var.keyvault_subscription_id
    keyvault_vault_name          = var.keyvault_vault_name
  }

  # https://docs.microsoft.com/it-it/cli/azure/cdn/custom-domain?view=azure-cli-latest
  provisioner "local-exec" {
    command = <<EOT
      az cdn custom-domain create \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} \
        --hostname ${self.triggers.hostname} && \
      az cdn custom-domain enable-https \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} \
        --min-tls-version "1.2" \
        --user-cert-protocol-type sni \
        --user-cert-group-name ${self.triggers.keyvault_resource_group_name} \
        --user-cert-vault-name ${self.triggers.keyvault_vault_name} \
        --user-cert-secret-name ${replace(self.triggers.name, ".", "-")} \
        --user-cert-subscription-id  ${self.triggers.keyvault_subscription_id}
    EOT
  }
  # https://docs.microsoft.com/it-it/cli/azure/cdn/custom-domain?view=azure-cli-latest
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az cdn custom-domain disable-https \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")} && \
      az cdn custom-domain delete \
        --resource-group ${self.triggers.resource_group_name} \
        --endpoint-name ${self.triggers.endpoint_name} \
        --profile-name ${self.triggers.profile_name} \
        --name ${replace(self.triggers.name, ".", "-")}
    EOT
  }
}

# record APEX https://docs.microsoft.com/it-it/azure/dns/dns-zones-records#record-names
resource "azurerm_dns_a_record" "apex_hostname" {
  # create this iff DNS zone name equal to HOST NAME azurerm_cdn_endpoint.this.fqdn
  count = var.dns_zone_name == var.hostname ? 1 : 0

  name                = "@"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.this.id

  tags = var.tags
}

# https://docs.microsoft.com/en-us/azure/dns/dns-custom-domain#azure-cdn
resource "azurerm_dns_cname_record" "apex_cdnverify" {
  count = var.dns_zone_name == var.hostname ? 1 : 0

  name                = "cdnverify"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 3600
  record              = "cdnverify.${azurerm_cdn_endpoint.this.fqdn}"

  tags = var.tags
}

resource "azurerm_dns_cname_record" "hostname" {
  count = var.dns_zone_name != var.hostname ? 1 : 0

  name                = trimsuffix(replace(var.hostname, var.dns_zone_name, ""), ".")
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 3600
  record              = azurerm_cdn_endpoint.this.fqdn

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings_cdn_profile" {
  name                       = "${var.prefix}-${var.name}-cdn-profile-diagnostic-settings"
  target_resource_id         = azurerm_cdn_profile.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_key_vault_access_policy" "azure_cdn_frontdoor_policy" {
  count = var.custom_hostname_kv_enabled ? 1 : 0

  key_vault_id = var.keyvault_id
  tenant_id    = var.tenant_id
  object_id    = var.azuread_service_principal_azure_cdn_frontdoor_id

  secret_permissions = [
    "Get",
  ]

  certificate_permissions = [
    "Get",
  ]
}
