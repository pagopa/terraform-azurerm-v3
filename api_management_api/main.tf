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
    dynamic "wsdl_selector" {
      for_each = contains(["wsdl", "wsdl-link"], var.content_format) ? ["item"] : []
      content {
        endpoint_name = var.wsdl_selector.endpoint_name
        service_name  = var.wsdl_selector.service_name
      }
    }
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

locals {
  is_soap = var.api_type == "soap" || var.content_format == "wsdl" || var.content_format == "wsdl-link"
}

data "external" "soap_action" {
  count = local.is_soap ? 1 : 0

  program = [
    "python3", "${path.module}/soap_api_operation_data_source.py"
  ]

  query = {
    resource_group     = var.resource_group_name
    service_name     = var.api_management_name
    api_id          = azurerm_api_management_api.this.name
  }
}



resource "azurerm_api_management_api_operation_policy" "api_operation_policy" {
  for_each = { for p in var.api_operation_policies : format("%s%s", p.operation_id, var.api_version == null ? "" : var.api_version) => p }

  api_name            = azurerm_api_management_api.this.name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
  # if soap, the operation id has to be retrieved from the external data source because it is generated and does not match with the soap action
  operation_id        = local.is_soap ? data.external.soap_action.result[each.value.operation_id] : each.value.operation_id

  xml_content = each.value.xml_content
}
