resource "azurerm_app_service_plan" "this" {
  count               = var.plan_type == "internal" ? 1 : 0
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  kind = var.plan_kind

  sku {
    tier = var.plan_sku_tier
    size = var.plan_sku_size
  }

  maximum_elastic_worker_count = var.plan_maximum_elastic_worker_count
  reserved                     = var.plan_reserved
  per_site_scaling             = var.plan_per_site_scaling

  tags = var.tags
}

resource "azurerm_app_service" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  app_service_plan_id = var.plan_type == "internal" ? azurerm_app_service_plan.this[0].id : var.plan_id
  https_only          = var.https_only
  #tfsec:ignore:azure-appservice-require-client-cert
  client_cert_enabled     = var.client_cert_enabled
  client_affinity_enabled = var.client_affinity_enabled

  app_settings = var.app_settings

  site_config {
    always_on              = var.always_on
    linux_fx_version       = var.linux_fx_version
    app_command_line       = var.app_command_line
    min_tls_version        = "1.2"
    ftps_state             = var.ftps_state
    vnet_route_all_enabled = var.subnet_id == null ? false : true

    health_check_path = var.health_check_path != null ? var.health_check_path : null

    php_version    = "7.4"
    python_version = "3.4"
    http2_enabled  = true

    dynamic "ip_restriction" {
      for_each = var.allowed_subnets
      iterator = subnet

      content {
        ip_address                = null
        virtual_network_subnet_id = subnet.value
        name                      = "rule"
      }
    }

    dynamic "ip_restriction" {
      for_each = var.allowed_ips
      iterator = ip

      content {
        ip_address                = ip.value
        virtual_network_subnet_id = null
        name                      = "rule"
      }
    }

  }

  #tfsec:ignore:azure-appservice-authentication-enabled
  auth_settings {
    enabled = false
  }

  # Managed identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      site_config.0.scm_type,
      site_config.0.linux_fx_version, # deployments are made outside of Terraform
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"]
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app_service_virtual_network_swift_connection" {
  count = var.vnet_integration ? 1 : 0

  app_service_id = azurerm_app_service.this.id
  subnet_id      = var.subnet_id
}
