locals {
  sa_prefix = replace(replace(var.prefix, "-", ""), "_", "")
}

module "velero_storage_account" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//storage_account?ref=v7.2.0"

  name                            = "${local.sa_prefix}velerosa"
  account_kind                    = "BlobStorage"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  blob_versioning_enabled         = true
  resource_group_name             = var.resource_group_name
  location                        = var.location
  allow_nested_items_to_be_public = false
  advanced_threat_protection      = true
  enable_low_availability_alert   = false
  public_network_access_enabled   = false
  tags                            = var.tags
}

resource "azurerm_private_endpoint" "velero_storage_private_endpoint" {
  count = 1

  name                = "${var.prefix}-velerosa-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "${var.prefix}-velerosa-private-dns-zone-group"
    private_dns_zone_ids = [var.storage_account_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.prefix}-velerosa-private-service-connection"
    private_connection_resource_id = module.velero_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "velero_backup_container" {
  name                  = "${var.prefix}-velero-backup"
  storage_account_name  = module.velero_storage_account.name
  container_access_type = "private"

  depends_on = [
    azurerm_private_endpoint.velero_storage_private_endpoint
  ]
}

data "azuread_client_config" "current" {}


resource "azuread_application" "velero_application" {
  display_name = "${var.prefix}-velero-application"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "velero_application_password" {
  application_object_id = azuread_application.velero_application.object_id
}

resource "azuread_service_principal" "velero_sp" {
  application_id = azuread_application.velero_application.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "velero_principal_password" {
  service_principal_id = azuread_service_principal.velero_sp.object_id
}

resource "azurerm_role_assignment" "velero_sp_aks_role" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_service_principal.velero_sp.object_id
}

resource "azurerm_role_assignment" "velero_sp_storage_role" {
  scope                = module.velero_storage_account.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_service_principal.velero_sp.object_id
}

resource "local_file" "credentials" {

  content = templatefile("./velero-credentials.tpl", {
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    client_id       = azuread_application.velero_application.application_id
    client_secret   = azuread_application_password.velero_application_password.value
    backup_rg       = var.resource_group_name
  })
  filename = "${path.module}/credentials-velero.txt"

  lifecycle {
    replace_triggered_by = [
      azurerm_storage_container.velero_backup_container,
      azuread_application.velero_application,
      azuread_service_principal.velero_sp,
      azuread_application_password.velero_application_password
    ]
  }
}

resource "null_resource" "install_velero" {
  depends_on = [local_file.credentials]

  triggers = {
    bucket          = azurerm_storage_container.velero_backup_container.name
    storage_account = module.velero_storage_account.id
    rg              = var.resource_group_name
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    client_id       = azuread_application.velero_application.application_id
    client_secret   = azuread_application_password.velero_application_password.value
    resource_group  = var.resource_group_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    velero uninstall --force
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
    velero install --provider azure --plugins velero/velero-plugin-for-microsoft-azure:${var.plugin_version} \
    --bucket ${azurerm_storage_container.velero_backup_container.name} \
    --secret-file ${local_file.credentials.filename} \
    --backup-location-config resourceGroup=${var.resource_group_name},storageAccount=${module.velero_storage_account.name},subscriptionId=${var.subscription_id} \
    EOT
  }

  lifecycle {
    replace_triggered_by = [
      local_file.credentials,
      azurerm_storage_container.velero_backup_container,
      azuread_service_principal.velero_sp,
      azuread_application.velero_application,
      azuread_application_password.velero_application_password
    ]
  }
}




