locals {
  sa_prefix = replace(replace(var.prefix, "-", ""), "_", "")
}

data "azurerm_resource_group" "parent_rg" {
  name = var.resource_group_name
}

data "azurerm_application_insights" "app_insight" {
  name                = var.application_insight_name
  resource_group_name = var.application_insight_rg_name
}

module "synthetic_monitoring_storage_account" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//storage_account?ref=v7.64.0"

  name                            = "${local.sa_prefix}synthmon"
  account_kind                    = var.storage_account_settings.kind
  account_tier                    = var.storage_account_settings.tier
  account_replication_type        = var.storage_account_settings.replication_type
  blob_versioning_enabled         = true
  resource_group_name             = var.resource_group_name
  location                        = var.location
  allow_nested_items_to_be_public = false
  advanced_threat_protection      = true
  enable_low_availability_alert   = false
  public_network_access_enabled   = var.storage_account_settings.private_endpoint_enabled ? false : true
  tags                            = var.tags

  # it needs to be higher than the other retention policies
  blob_delete_retention_days           = var.storage_account_settings.backup_retention_days + 1
  blob_change_feed_enabled             = var.storage_account_settings.backup_enabled
  blob_change_feed_retention_in_days   = var.storage_account_settings.backup_enabled ? var.storage_account_settings.backup_retention_days + 1 : null
  blob_container_delete_retention_days = var.storage_account_settings.backup_retention_days
  blob_storage_policy = {
    enable_immutability_policy = false
    blob_restore_policy_days   = var.storage_account_settings.backup_retention_days
  }

}


resource "azurerm_storage_table" "table_storage" {
  name                 = "monitoringconfiguration"
  storage_account_name = module.synthetic_monitoring_storage_account.name
}

locals {
  decoded_configuration = jsondecode(var.monitoring_configuration_encoded)
}

resource "azurerm_storage_table_entity" "monitoring_configuration" {
  count                = length(local.decoded_configuration)
  storage_account_name = module.synthetic_monitoring_storage_account.name
  table_name           = azurerm_storage_table.table_storage.name

  partition_key = "${local.decoded_configuration[count.index].appName}-${local.decoded_configuration[count.index].apiName}"
  row_key       = local.decoded_configuration[count.index].type
  entity = {
    "url"                 = local.decoded_configuration[count.index].url,
    "type"                = local.decoded_configuration[count.index].type,
    "checkCertificate"    = local.decoded_configuration[count.index].checkCertificate,
    "method"              = local.decoded_configuration[count.index].method,
    "expectedCodes"       = jsonencode(local.decoded_configuration[count.index].expectedCodes),
    "durationLimit"       = lookup(local.decoded_configuration[count.index], "durationLimit", null) != null ? local.decoded_configuration[count.index].durationLimit : var.job_settings.default_duration_limit,
    "headers"             = lookup(local.decoded_configuration[count.index], "headers", null) != null ? jsonencode(local.decoded_configuration[count.index].headers) : null,
    "body"                = lookup(local.decoded_configuration[count.index], "body", null) != null ? jsonencode(local.decoded_configuration[count.index].body) : null
    "tags"                = lookup(local.decoded_configuration[count.index], "tags", null) != null ? jsonencode(local.decoded_configuration[count.index].tags) : null
    "bodyCompareStrategy" = lookup(local.decoded_configuration[count.index], "bodyCompareStrategy", null) != null ? local.decoded_configuration[count.index].bodyCompareStrategy : null
    "expectedBody"        = lookup(local.decoded_configuration[count.index], "expectedBody", null) != null ? jsonencode(local.decoded_configuration[count.index].expectedBody) : null

  }
}

resource "azurerm_private_endpoint" "synthetic_monitoring_storage_private_endpoint" {
  count = var.storage_account_settings.private_endpoint_enabled ? 1 : 0

  name                = "${var.prefix}-syntheticmonitoringsa-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "${var.prefix}-synthetic-monitoring-private-dns-zone-group"
    private_dns_zone_ids = [var.storage_account_settings.table_private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.prefix}-synthetic-monitoring-private-service-connection"
    private_connection_resource_id = module.synthetic_monitoring_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["table"]
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
        replicaTimeout    = var.job_settings.execution_timeout_seconds
        scheduleTriggerConfig = {
          cronExpression         = var.job_settings.cron_scheduling
          parallelism            = 1
          replicaCompletionCount = 1
        }
        secrets     = []
        triggerType = "Schedule"
      }
      environmentId = var.job_settings.container_app_environment_id
      template = {
        containers = [
          {
            args    = []
            command = []
            env = [
              {
                name  = "APP_INSIGHT_CONNECTION_STRING"
                value = data.azurerm_application_insights.app_insight.connection_string
              },
              {
                name  = "STORAGE_ACCOUNT_NAME"
                value = module.synthetic_monitoring_storage_account.name
              },
              {
                name  = "STORAGE_ACCOUNT_KEY"
                value = module.synthetic_monitoring_storage_account.primary_access_key
              },
              {
                name  = "STORAGE_ACCOUNT_TABLE_NAME"
                value = azurerm_storage_table.table_storage.name
              },
              {
                name  = "AVAILABILITY_PREFIX"
                value = var.job_settings.availability_prefix
              },
              {
                name  = "HTTP_CLIENT_TIMEOUT"
                value = tostring(var.job_settings.http_client_timeout)
              },
              {
                name  = "LOCATION"
                value = var.location
              },
              {
                name  = "CERT_VALIDITY_RANGE_DAYS"
                value = tostring(var.job_settings.cert_validity_range_days)
              }

            ]
            image = "${var.docker_settings.registry_url}/${var.docker_settings.image_name}:${var.docker_settings.image_tag}"
            name  = "synthetic-monitoring"
            probes = [
            ]
            resources = {
              cpu    = var.job_settings.cpu_requirement
              memory = var.job_settings.memory_requirement
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

locals {
  default_alert_configuration = {
    enabled     = true,
    severity    = 0,
    frequency   = "PT1M"
    threshold   = 100
    operator    = "LessThan"
    aggregation = "Average"
  }
}


resource "azurerm_monitor_metric_alert" "alert" {
  count = length(local.decoded_configuration)

  name                = "availability-${local.decoded_configuration[count.index].appName}-${local.decoded_configuration[count.index].apiName}-${local.decoded_configuration[count.index].type}"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.app_insight.id]
  description         = "Monitors the availability of ${local.decoded_configuration[count.index].appName} ${local.decoded_configuration[count.index].apiName} from ${local.decoded_configuration[count.index].type}"
  severity            = lookup(lookup(local.decoded_configuration[count.index], "alertConfiguration", local.default_alert_configuration), "severity", local.default_alert_configuration.severity)
  frequency           = lookup(lookup(local.decoded_configuration[count.index], "alertConfiguration", local.default_alert_configuration), "frequency", local.default_alert_configuration.frequency)
  auto_mitigate       = true
  enabled             = lookup(lookup(local.decoded_configuration[count.index], "alertConfiguration", local.default_alert_configuration), "enabled", local.default_alert_configuration.enabled)

  criteria {
    aggregation      = lookup(lookup(local.decoded_configuration[count.index], "alertConfiguration", local.default_alert_configuration), "aggregation", local.default_alert_configuration.aggregation)
    metric_name      = "availabilityResults/availabilityPercentage"
    metric_namespace = "microsoft.insights/components"
    operator         = lookup(lookup(local.decoded_configuration[count.index], "alertConfiguration", local.default_alert_configuration), "operator", local.default_alert_configuration.operator)
    threshold        = lookup(lookup(local.decoded_configuration[count.index], "alertConfiguration", local.default_alert_configuration), "threshold", local.default_alert_configuration.threshold)
    dimension {
      name     = "availabilityResult/name"
      operator = "Include"
      values   = ["${var.job_settings.availability_prefix}-${local.decoded_configuration[count.index].appName}-${local.decoded_configuration[count.index].apiName}"]
    }
    dimension {
      name     = "availabilityResult/location"
      operator = "Include"
      values   = [local.decoded_configuration[count.index].type]
    }
  }


  dynamic "action" {
    for_each = var.application_insights_action_group_ids

    content {
      action_group_id = action.value
    }
  }

}



resource "azurerm_monitor_metric_alert" "self_alert" {
  name                = "availability-synthetic-monitoring-function"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.app_insight.id]
  description         = "Monitors the availability of the synthetic monitoring function"
  severity            = var.self_alert_configuration.severity
  frequency           = var.self_alert_configuration.frequency
  auto_mitigate       = true
  enabled             = var.self_alert_configuration.enabled

  criteria {
    aggregation      = var.self_alert_configuration.aggregation
    metric_name      = "availabilityResults/availabilityPercentage"
    metric_namespace = "microsoft.insights/components"
    operator         = var.self_alert_configuration.operator
    threshold        = var.self_alert_configuration.threshold
    dimension {
      name     = "availabilityResult/name"
      operator = "Include"
      values   = ["${var.job_settings.availability_prefix}-monitoring-function"]
    }
    dimension {
      name     = "availabilityResult/location"
      operator = "Include"
      values   = [var.location]
    }
  }


  dynamic "action" {
    for_each = var.application_insights_action_group_ids

    content {
      action_group_id = action.value
    }
  }

}

