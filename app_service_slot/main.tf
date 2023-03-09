resource "azurerm_linux_web_app_slot" "this" {
  name = var.name

  app_service_id             = var.app_service_id
  https_only                 = var.https_only
  client_affinity_enabled    = var.client_affinity_enabled
  client_certificate_enabled = var.client_certificate_enabled

  app_settings = var.app_settings

  site_config {
    always_on         = var.always_on
    use_32_bit_worker = var.use_32_bit_worker_process
    application_stack {
      docker_image     = var.docker_image
      docker_image_tag = var.docker_image_tag

      dotnet_version      = var.dotnet_version
      python_version      = var.python_version
      go_version          = var.go_version
      java_server         = var.java_server
      java_server_version = var.java_server_version
      java_version        = var.java_version
      node_version        = var.node_version
      php_version         = var.php_version
      ruby_version        = var.ruby_version
    }
    app_command_line       = var.app_command_line
    minimum_tls_version    = "1.2"
    ftps_state             = var.ftps_state
    vnet_route_all_enabled = var.subnet_id == null ? false : true

    health_check_path = var.health_check_path != null ? var.health_check_path : null

    http2_enabled = true

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

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"]
    ]
  }
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "app_service_virtual_network_swift_connection" {
  count = var.vnet_integration ? 1 : 0

  slot_name      = azurerm_linux_web_app_slot.this.name
  app_service_id = var.app_service_id
  subnet_id      = var.subnet_id
}
