resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_@%"
  upper            = true
  lower            = true
  numeric          = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "postgres_dbs" {
  name     = "${local.project}-postgres-dbs-rg"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "test_vnet" {
  name                = "${local.project}-vnet"
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.postgres_dbs.name
  location            = azurerm_resource_group.postgres_dbs.location

  tags = var.tags
}

resource "azurerm_subnet" "test_subnet" {
  name                 = "${local.project}-subnet"
  resource_group_name  = azurerm_resource_group.postgres_dbs.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = var.function_app_subnet_cidr

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# DNS private single server
resource "azurerm_private_dns_zone" "privatelink_postgres_database_azure_com" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.postgres_dbs.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_postgres_database_azure_com_vnet" {

  name                  = "${local.project}-pg-flex-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.name

  resource_group_name = azurerm_resource_group.postgres_dbs.name
  virtual_network_id  = azurerm_virtual_network.test_vnet.id

  registration_enabled = false

  tags = var.tags
}

# https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compare-single-server-flexible-server
module "postgres_flexible_server_private" {

  source = "../"

  name                = "${local.project}-private-pgflex"
  location            = azurerm_resource_group.postgres_dbs.location
  resource_group_name = azurerm_resource_group.postgres_dbs.name

  ### Network
  private_endpoint_enabled = false
  private_dns_zone_id      = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.id
  delegated_subnet_id      = azurerm_subnet.test_subnet.id

  ### Admin
  administrator_login    = azurerm_key_vault_secret.pgres_flex_admin_login.value
  administrator_password = azurerm_key_vault_secret.pgres_flex_admin_pwd.value

  sku_name   = "B_Standard_B1ms"
  db_version = "13"
  # Possible values are 32768, 65536, 131072, 262144, 524288, 1048576,
  # 2097152, 4194304, 8388608, 16777216, and 33554432.
  storage_mb = 32768

  ### zones & HA
  zone                      = 2
  high_availability_enabled = false
  standby_availability_zone = 3

  # customer_managed_key
  customer_managed_key_enabled   = true
  customer_managed_key_kv_key_id = azurerm_key_vault_key.generated.id

  maintenance_window_config = {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 0
  }

  databases = {
    pgsqlservername1 = { collation = "en_US.utf8" }
  }
  ### backup
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  pgbouncer_enabled = false

  tags = var.tags

  diagnostic_settings_enabled               = true
  log_analytics_workspace_id                = azurerm_log_analytics_workspace.test.id
  diagnostic_setting_destination_storage_id = module.storage_account.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.privatelink_postgres_database_azure_com_vnet]

}


# KV secrets flex server
resource "azurerm_key_vault_secret" "pgres_flex_admin_login" {
  name         = "${local.project}-pgres-flex-admin-login"
  value        = var.pgres_flex_admin_login
  key_vault_id = module.key_vault_test.id

}

resource "azurerm_key_vault_secret" "pgres_flex_admin_pwd" {
  name         = "${local.project}-pgres-flex-admin-pwd"
  value        = random_password.password.result
  key_vault_id = module.key_vault_test.id
}


module "key_vault_test" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//key_vault?ref=v6.9.0"

  name                       = "${local.project}-kv"
  location                   = azurerm_resource_group.postgres_dbs.location
  resource_group_name        = azurerm_resource_group.postgres_dbs.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 90
  sku_name                   = "premium"

  lock_enable = true

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id = module.key_vault_test.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
  "Rotate", "GetRotationPolicy", "SetRotationPolicy", ]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Backup", "Recover", "Restore", ]
  storage_permissions     = []
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Restore", "Purge", "Recover", ]
}

resource "azurerm_key_vault_key" "generated" {
  name         = "generated-certificate"
  key_vault_id = module.key_vault_test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "${local.project}-log-analytics-workspace"
  location            = azurerm_resource_group.postgres_dbs.location
  resource_group_name = azurerm_resource_group.postgres_dbs.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "storage_account" {
  source = "../../storage_account"

  name                            = replace("${local.project}st", "-", "")
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  access_tier                     = "Hot"
  account_replication_type        = "GRS"
  resource_group_name             = azurerm_resource_group.postgres_dbs.name
  location                        = azurerm_resource_group.postgres_dbs.location
  advanced_threat_protection      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  blob_versioning_enabled              = true
  blob_container_delete_retention_days = 7
  blob_delete_retention_days           = 7
  blob_change_feed_enabled             = true
  blob_change_feed_retention_in_days   = 10
  blob_restore_policy_days             = 6

  tags = var.tags
}