locals {
  sa_prefix = replace(replace(var.prefix, "-", ""), "_", "")
}

module "velero_storage_account" {
  source = "../storage_account"

  name                            = "${local.sa_prefix}velerosa"
  account_kind                    = var.storage_account_kind
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  blob_versioning_enabled         = true
  resource_group_name             = var.storage_account_resource_group_name
  location                        = var.location
  allow_nested_items_to_be_public = false
  advanced_threat_protection      = var.advanced_threat_protection
  enable_low_availability_alert   = var.enable_low_availability_alert
  public_network_access_enabled   = var.use_storage_private_endpoint ? false : true
  tags                            = var.tags

  # it needs to be higher than the other retention policies
  blob_delete_retention_days           = var.sa_backup_retention_days + 1
  blob_change_feed_enabled             = var.enable_sa_backup
  blob_change_feed_retention_in_days   = var.enable_sa_backup ? var.sa_backup_retention_days + 1 : null
  blob_container_delete_retention_days = var.sa_backup_retention_days
  blob_storage_policy = {
    enable_immutability_policy = false
    blob_restore_policy_days   = var.sa_backup_retention_days
  }

}

resource "azurerm_private_endpoint" "velero_storage_private_endpoint" {
  count = var.use_storage_private_endpoint ? 1 : 0

  name                = "${var.prefix}-velerosa-private-endpoint"
  location            = var.location
  resource_group_name = var.storage_account_resource_group_name
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

  depends_on = [azurerm_private_endpoint.velero_storage_private_endpoint]
}

data "azuread_client_config" "current" {}

module "velero_workload_identity" {
  source = "../kubernetes_workload_identity_configuration"

  aks_name                              = var.aks_cluster_name
  aks_resource_group_name               = var.aks_cluster_rg
  namespace                             = "velero"
  workload_identity_name                = var.workload_identity_name
  workload_identity_name_prefix         = null
  workload_identity_resource_group_name = var.workload_identity_resource_group_name

  key_vault_certificate_permissions = ["Get"]
  key_vault_key_permissions         = ["Get"]
  key_vault_secret_permissions      = ["Get"]
  key_vault_id                      = var.key_vault_id
}

resource "kubernetes_cluster_role_binding" "velero_binding" {
  metadata {
    name = "velero-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    namespace = "velero"
    kind      = "ServiceAccount"
    name      = var.workload_identity_name
  }
}

resource "local_file" "credentials" {

  content = templatefile("${path.module}/velero-credentials.tpl", {
    subscription_id = var.subscription_id
    backup_rg       = var.storage_account_resource_group_name
  })
  filename = "${path.module}/credentials-velero.txt"

  lifecycle {
    replace_triggered_by = [
      azurerm_storage_container.velero_backup_container
    ]
  }
}

resource "null_resource" "install_velero" {
  depends_on = [local_file.credentials]

  triggers = {
    bucket                = azurerm_storage_container.velero_backup_container.name
    storage_account       = module.velero_storage_account.name
    subscription_id       = var.subscription_id
    resource_group        = var.storage_account_resource_group_name
    plugin_version        = var.plugin_version
    cluster_name          = var.aks_cluster_name
    credentials_file_name = local_file.credentials.filename
    storage_account_uri   = module.velero_storage_account.primary_blob_endpoint
    service_account_name  = var.workload_identity_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      kubectl config use-context "${self.triggers.cluster_name}" && \
      velero uninstall --force
      EOT
  }

  provisioner "local-exec" {
    command = <<EOT
    kubectl config use-context "${self.triggers.cluster_name}" && \
    velero install \
        --provider azure \
        --service-account-name ${self.triggers.service_account_name} \
        --pod-labels azure.workload.identity/use=true \
        --plugins velero/velero-plugin-for-microsoft-azure:${self.triggers.plugin_version} \
        --bucket ${self.triggers.bucket} \
        --secret-file ${self.triggers.credentials_file_name} \
        --backup-location-config storageAccountURI=${self.triggers.storage_account_uri},useAAD="true",resourceGroup=${self.triggers.resource_group},storageAccount=${self.triggers.storage_account},subscriptionId=${self.triggers.subscription_id}
    EOT
  }

  lifecycle {
    replace_triggered_by = [
      local_file.credentials,
      azurerm_storage_container.velero_backup_container,
    ]
  }
}
