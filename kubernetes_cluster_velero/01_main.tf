data "azurerm_storage_account" "velero_storage_account" {
  name                = var.backup_storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_container" "velero_backup_container" {
  name                  = var.backup_storage_container_name
  storage_account_name  = data.azurerm_storage_account.velero_storage_account.name
  container_access_type = "private"

}

data "azuread_client_config" "current" {}

locals {
  application_base_name  = "velero-application"
  final_application_name = var.application_prefix == null ? local.application_base_name : "${var.application_prefix}-${local.application_base_name}"
}

resource "azuread_application" "velero_application" {
  display_name = "velero-application"
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

resource "azurerm_role_assignment" "velero_sp_role" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
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
    storage_account = data.azurerm_storage_account.velero_storage_account.id
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
    --backup-location-config resourceGroup=${var.resource_group_name},storageAccount=${data.azurerm_storage_account.velero_storage_account.name},subscriptionId=${var.subscription_id} \
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

locals {
  all_namespace_backup_name = "all-ns-backup"
}

resource "null_resource" "schedule_backup" {
  count      = var.backup_enabled ? 1 : 0
  depends_on = [null_resource.install_velero]

  triggers = {
    cron = var.backup_schedule
    name = local.all_namespace_backup_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    velero schedule delete ${self.triggers.name} --confirm
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
    velero create schedule ${local.all_namespace_backup_name} --schedule="${var.backup_schedule}" --ttl ${var.backup_ttl} --snapshot-volumes=${var.volume_snapshot}
    EOT
  }
}

