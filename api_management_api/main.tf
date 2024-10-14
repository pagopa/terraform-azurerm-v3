resource "azurerm_api_management_api" "this" {
  name                 = var.api_version != null ? join("-", [var.name, var.api_version]) : var.name
  resource_group_name  = var.resource_group_name
  api_management_name  = var.api_management_name
  revision             = var.revision
  revision_description = var.revision_description
  display_name         = var.display_name
  description          = var.description
  api_type             = var.api_type

  dynamic "oauth2_authorization" {
    for_each = var.oauth2_authorization.authorization_server_name != null ? ["dummy"] : []
    content {
      authorization_server_name = var.oauth2_authorization.authorization_server_name
    }
  }

  path                  = var.path
  protocols             = var.protocols
  service_url           = var.service_url
  subscription_required = var.subscription_required
  version               = var.api_version
  version_set_id        = var.version_set_id

  import {
    content_format = var.content_format
    content_value  = var.content_value
  }

  dynamic "subscription_key_parameter_names" {
    for_each = var.subscription_key_names == null ? [] : ["dummy"]
    content {
      header = var.subscription_key_names.header
      query  = var.subscription_key_names.query
    }
  }
}

resource "azurerm_api_management_api_policy" "this" {
  count               = var.xml_content == null ? 0 : 1
  api_name            = azurerm_api_management_api.this.name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name

  xml_content = var.xml_content
}

resource "azurerm_api_management_product_api" "this" {
  for_each = toset(var.product_ids)

  product_id          = each.value
  api_name            = azurerm_api_management_api.this.name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_api_management_api_operation_policy" "api_operation_policy" {
  for_each = { for p in var.api_operation_policies : format("%s%s", p.operation_id, var.api_version == null ? "" : var.api_version) => p }

  api_name            = azurerm_api_management_api.this.name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
  operation_id        = each.value.operation_id

  xml_content = each.value.xml_content
}
