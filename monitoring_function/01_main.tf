locals {
  sa_prefix = replace(replace(var.prefix, "-", ""), "_", "")
}

data "azurerm_resource_group" "parent_rg" {
  name = var.resource_group_name
}


module "synthetic_monitoring_storage_account" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//storage_account?ref=v7.39.0"

  name                            = "${local.sa_prefix}synthmon"
  account_kind                    = var.storage_account_kind
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  blob_versioning_enabled         = true
  resource_group_name             = var.resource_group_name
  location                        = var.location
  allow_nested_items_to_be_public = false
  advanced_threat_protection      = true
  enable_low_availability_alert   = false
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


resource "azurerm_storage_table" "table_storage" {
  name                 = "monitoringconfiguration"
  storage_account_name = module.synthetic_monitoring_storage_account.name
}


resource "azurerm_storage_table_entity" "monitoring_configuration" {
  storage_account_name = module.synthetic_monitoring_storage_account.name
  table_name           = azurerm_storage_table.table_storage.name

  partition_key = "microservice"
  row_key       = "aks_ingress"
  entity = {
        "url"  =  "https://dev01.blueprint.internal.devopslab.pagopa.it/blueprint/v5-java-helm-complete-test/",
        "type" = "private",
        "checkCertificate" = true,
        "method" = "GET",
        "expectedCodes" = jsonencode(["200-299", "303"]),
        "tags" = jsonencode({
            "description": "AKS ingress tested from internal network"
        })
  }
}

resource "azurerm_private_endpoint" "synthetic_monitoring_storage_private_endpoint" {
  count = var.use_storage_private_endpoint ? 1 : 0

  name                = "${var.prefix}-syntheticmonitoringsa-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "${var.prefix}-synthetic-monitoring-private-dns-zone-group"
    private_dns_zone_ids = [var.storage_account_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.prefix}-synthetic-monitoring-private-service-connection"
    private_connection_resource_id = module.synthetic_monitoring_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = var.tags
}


resource "azapi_resource" "monitoring_app_job" {
  type      = "Microsoft.App/jobs@2022-11-01-preview"
  name      = "${var.prefix}-monitoring-app-job"
  location  = var.location
  parent_id = data.azurerm_resource_group.parent_rg.id
  tags      = var.tags
  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {
      configuration = {
        registries        = []
        replicaRetryLimit = 1
        replicaTimeout    = var.execution_timeout_seconds
        scheduleTriggerConfig = {
          cronExpression         = var.cron_scheduling
          parallelism            = 1
          replicaCompletionCount = 1
        }
        secrets     = []
        triggerType = "Schedule"
      }
      environmentId = var.container_app_environment_id
      template = {
        containers = [
          {
            args    = []
            command = []
            env = [
              {
                name  = "APP_INSIGHT_CONNECTION_STRING"
                value = var.app_insight_connection_string
              }
            ]
            image = "${var.registry_url}/${var.monitoring_image_name}:${var.monitoring_image_tag}"
            name  = "synthetic-monitoring"
            probes = [
            ]
            resources = {
              cpu    = var.cpu_requirement
              memory = var.memory_requirement
            }
            volumeMounts = []
          }
        ]
        initContainers = []
        volumes        = []
      }
    }
  })
}


