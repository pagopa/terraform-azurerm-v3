
module "internal_storage_account" {
  source = "github.com/pagopa/terraform-azurerm-v3.git//storage_account?ref=v7.76.0"

  name                                       = "${replace(var.name, "-", "")}dist"
  account_kind                               = var.internal_storage.account_kind
  account_tier                               = var.internal_storage.account_tier
  account_replication_type                   = var.internal_storage.account_replication_type
  access_tier                                = var.internal_storage.access_tier
  resource_group_name                        = azurerm_resource_group.this.name
  location                                   = var.location
  enable_resource_advanced_threat_protection = false
  advanced_threat_protection                 = false
  public_network_access_enabled              = false

  tags = var.tags
}

resource "azurerm_private_endpoint" "blob" {
  name                = format("%s-blob-endpoint", module.internal_storage_account.name)
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.internal_storage.private_endpoint_subnet_id

  private_service_connection {
    name                           = format("%s-blob", module.internal_storage_account.name)
    private_connection_resource_id = module.internal_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = var.internal_storage.private_dns_zone_blob_ids
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "queue" {
  name                = format("%s-queue-endpoint", module.internal_storage_account.name)
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.internal_storage.private_endpoint_subnet_id

  private_service_connection {
    name                           = format("%s-queue", module.internal_storage_account.name)
    private_connection_resource_id = module.internal_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = var.internal_storage.private_dns_zone_queue_ids
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "table" {
  name                = format("%s-table-endpoint", module.internal_storage_account.name)
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = var.internal_storage.private_endpoint_subnet_id

  private_service_connection {
    name                           = format("%s-table", module.internal_storage_account.name)
    private_connection_resource_id = module.internal_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = var.internal_storage.private_dns_zone_table_ids
  }

  tags = var.tags
}
