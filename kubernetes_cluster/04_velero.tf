data "azurerm_storage_account" "velero_storage_account" {
  name = var.velero_backup_storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_container" "velero_backup_container" {
  count = var.velero_enabled ? 1 : 0
  name                  = var.velero_backup_storage_container_name
  storage_account_name  = data.azurerm_storage_account.velero_storage_account.name
  container_access_type = "private"

}

data "azuread_client_config" "current" {}

resource "azuread_application" "velero_applicaiton" {
  count = var.velero_enabled ? 1 : 0
  display_name     = "velero-application"
  owners           = [data.azuread_client_config.current.object_id]

}

resource "azuread_application_password" "velero_application_password" {
  count = var.velero_enabled ? 1 : 0
  application_object_id = azuread_application.velero_applicaiton[0].object_id
}

resource "azuread_service_principal" "velero_sp" {
  count = var.velero_enabled ? 1 : 0
  application_id    = azuread_application.velero_applicaiton[0].application_id
  owners            = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "velero_principal_password" {
  count = var.velero_enabled ? 1 : 0
  service_principal_id = azuread_service_principal.velero_sp[0].object_id
}


resource "azurerm_role_assignment" "velero_sp_role" {
  count = var.velero_enabled ? 1 : 0
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.velero_sp[0].object_id
}


resource "local_file" "credentials" {
  count = var.velero_enabled ? 1 : 0
  content  = templatefile("./velero-credentials.tpl", {
    subscription_id = var.subscription_id
    tenant_id = var.tenant_id
    client_id = azuread_application.velero_applicaiton[0].application_id
    client_secret = azuread_application_password.velero_application_password[0].value
    backup_rg = var.resource_group_name
  })
  filename = "${path.module}/credentials-velero.txt"
}


resource "null_resource" "install_velero" {
  count = var.velero_enabled ? 1 : 0
  depends_on = [local_file.credentials]

  triggers = {
    bucket = azurerm_storage_container.velero_backup_container[0].name
    storage_account = data.azurerm_storage_account.velero_storage_account.id
    rg = var.resource_group_name
    subscription_id = var.subscription_id
    credentials = filemd5(local_file.credentials[0].filename)
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    velero uninstall --force
    EOT
  }

  provisioner "local-exec" {
    command     = <<EOT
    velero install --provider azure --plugins velero/velero-plugin-for-microsoft-azure:v1.5.0 \
    --bucket ${azurerm_storage_container.velero_backup_container[0].name} \
    --secret-file ${local_file.credentials[0].filename} \
    --backup-location-config resourceGroup=${var.resource_group_name},storageAccount=${data.azurerm_storage_account.velero_storage_account.name},subscriptionId=${var.subscription_id} \
    EOT
  }
}



locals {
  all_namespace_backup_name = "all-ns-backup"
}

resource "null_resource" "schedule_backup" {
  count = var.velero_enabled && var.velero_backup_enabled? 1 : 0
  depends_on = [null_resource.install_velero]

  triggers = {
    cron = var.velero_backup_schedule
    name = local.all_namespace_backup_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    velero schedule delete ${self.triggers.name} --confirm
    EOT
  }


  provisioner "local-exec" {
    command     = <<EOT
    velero create schedule ${local.all_namespace_backup_name} --schedule="${var.velero_backup_schedule}" --ttl ${var.velero_backup_ttl}
    EOT
  }
}


