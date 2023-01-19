resource "azurerm_data_factory" "this" {
  name                   = var.name
  location               = var.location
  resource_group_name    = var.resource_group_name
  public_network_enabled = !var.private_endpoint.enabled

  github_configuration {
    # (Required) Specifies the GitHub account name
    account_name = var.github_conf.account_name
    # (Required) Specifies the collaboration branch of the repository to get code from.
    # The poublish branch is automatically set to adf_publish
    branch_name = var.github_conf.branch_name
    # (Required) Specifies the GitHub Enterprise host name.
    # For example: https://github.mydomain.com. Use https://github.com for open source repositories
    git_url = var.github_conf.git_url
    # (Required) Specifies the name of the git repository
    repository_name = var.github_conf.repository_name
    # (Required) Specifies the root folder within the repository. Set to / for the top level.
    root_folder = var.github_conf.root_folder
  }

  # Still doesn't work: https://github.com/hashicorp/terraform-provider-azurerm/issues/12949
  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

}

resource "azurerm_private_endpoint" "this" {

  count = var.private_endpoint.enabled ? 1 : 0

  name                = format("%s-private-endpoint", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_dns_zone_group {
    name = format("%s-private-dns-zone-group", var.name)
    # One of the concatenated arrays is empty
    private_dns_zone_ids = [var.private_endpoint.private_dns_zone.id]
  }

  private_service_connection {
    name                           = format("%s-private-service-connection", var.name)
    private_connection_resource_id = azurerm_data_factory.this.id
    is_manual_connection           = false
    subresource_names              = ["datafactory"]
  }

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "this" {

  count = var.custom_domain_enabled == null ? 0 : 1

  name                = var.custom_domain_enabled
  zone_name           = var.private_endpoint.private_dns_zone.name
  resource_group_name = var.private_endpoint.private_dns_zone.rg
  ttl                 = 300
  records             = azurerm_private_endpoint.this[count.index].private_service_connection.*.private_ip_address

  tags = var.tags
}

resource "azurerm_data_factory_managed_private_endpoint" "this" {
  for_each           = var.resources_managed_private_enpoint
  name               = replace(format("%s-%s-mng-private-endpoint", var.name, substr(sha256(each.key), 0, 3)), "-", "_")
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = each.key
  subresource_name   = each.value
}
