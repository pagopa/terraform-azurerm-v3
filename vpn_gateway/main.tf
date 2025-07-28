#
# Gateway
#


resource "random_string" "dns" {
  length  = 6
  special = var.random_special
  upper   = var.random_upper
}

resource "azurerm_public_ip" "gw" {
  count               = var.pip_id == null ? 1 : 0
  name                = "${var.name}-gw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = var.pip_allocation_method
  domain_name_label = "${lower(replace(var.name, "/[[:^alnum:]]/", ""))}gw${random_string.dns.result}"
  sku               = var.pip_sku

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "gw_pip" {
  count                      = var.log_analytics_workspace_id != null && var.pip_id == null ? 1 : 0
  name                       = "gw-pip-log-analytics"
  target_resource_id         = azurerm_public_ip.gw[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DDoSProtectionNotifications"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "DDoSMitigationFlowLogs"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "DDoSMitigationReports"
    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_virtual_network_gateway" "gw" {
  name                = "${var.name}-gw"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = var.active_active
  enable_bgp    = var.enable_bgp
  sku           = var.sku
  generation    = var.generation

  ip_configuration {
    name                          = "${var.name}-gw-config"
    public_ip_address_id          = var.pip_id == null ? azurerm_public_ip.gw[0].id : var.pip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_configuration
    content {
      aad_audience          = vpn_client_configuration.value["aad_audience"]
      aad_issuer            = vpn_client_configuration.value["aad_issuer"]
      aad_tenant            = vpn_client_configuration.value["aad_tenant"]
      address_space         = vpn_client_configuration.value["address_space"]
      radius_server_address = vpn_client_configuration.value["radius_server_address"]
      radius_server_secret  = vpn_client_configuration.value["radius_server_secret"]
      vpn_client_protocols  = vpn_client_configuration.value["vpn_client_protocols"]

      dynamic "revoked_certificate" {
        for_each = vpn_client_configuration.value.revoked_certificate
        content {
          name       = revoked_certificate.value["name"]
          thumbprint = revoked_certificate.value["thumbprint"]
        }
      }

      dynamic "root_certificate" {
        for_each = vpn_client_configuration.value.root_certificate
        content {
          name             = root_certificate.value["name"]
          public_cert_data = root_certificate.value["public_cert_data"]
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "sec_gw_logs" {
  count                      = var.sec_log_analytics_workspace_id != null ? 1 : 0
  name                       = "LogSecurity"
  target_resource_id         = azurerm_virtual_network_gateway.gw.id
  log_analytics_workspace_id = var.sec_log_analytics_workspace_id
  storage_account_id         = var.sec_storage_id

  enabled_log {
    category = "GatewayDiagnosticLog"
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "TunnelDiagnosticLog"
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "RouteDiagnosticLog"
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "IKEDiagnosticLog"
    retention_policy {
      enabled = true
      days    = 365
    }
  }

  enabled_log {
    category = "P2SDiagnosticLog"
    retention_policy {
      enabled = true
      days    = 365
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

resource "azurerm_local_network_gateway" "local" {
  count               = length(var.local_networks)
  name                = "${var.local_networks[count.index].name}-lng"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.local_networks[count.index].gateway_address
  address_space       = var.local_networks[count.index].address_space

  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "local" {
  count               = length(var.local_networks)
  name                = "${var.local_networks[count.index].name}-lngc"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.local[count.index].id

  use_policy_based_traffic_selectors = var.local_networks[count.index].use_policy_based_traffic_selectors

  dynamic "traffic_selector_policy" {
    for_each = var.local_networks[count.index].traffic_selector_policies
    iterator = ts_policy
    content {
      local_address_cidrs  = ts_policy.value.local_address_cidrs
      remote_address_cidrs = ts_policy.value.remote_address_cidrs
    }
  }

  shared_key = var.local_networks[count.index].shared_key

  dynamic "ipsec_policy" {
    for_each = var.local_networks[count.index].ipsec_policy != null ? [true] : []
    content {
      dh_group         = var.local_networks[count.index].ipsec_policy.dh_group
      ike_encryption   = var.local_networks[count.index].ipsec_policy.ike_encryption
      ike_integrity    = var.local_networks[count.index].ipsec_policy.ike_integrity
      ipsec_encryption = var.local_networks[count.index].ipsec_policy.ipsec_encryption
      ipsec_integrity  = var.local_networks[count.index].ipsec_policy.ipsec_integrity
      pfs_group        = var.local_networks[count.index].ipsec_policy.pfs_group
      sa_datasize      = var.local_networks[count.index].ipsec_policy.sa_datasize
      sa_lifetime      = var.local_networks[count.index].ipsec_policy.sa_lifetime
    }
  }

  tags = var.tags
}
