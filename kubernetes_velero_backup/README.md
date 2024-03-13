# kubernetes velero backup

Module that allows the scheduling of velero backups for specific namespaces
Note that this module selects the correct cluster to work on using the command `kubectl config use-context "<cluster_name>"`, so you should have that context available in your `.kube` folder.
This is achievable using the utility script `k8setup.sh` included in the aks-setup folder of your IaC project
This module creates also an alert rule for each namespace scheduled for backup, based on query execution against the container logs searching for the string signaling the correct execution of the backup

## How to use it

This module requires Velero to be installed; check module `kubernetes_cluster_velero` for details on the installation

### Variable definition example

```hcl
module "aks_namespace_backup" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_velero_backup?ref=<version>"
  
  # required
  aks_cluster_name = module.aks.name
  backup_name = "daily-backup"
  namespaces = ["my-namespace-name"]
  
  # optional
  ttl = "100h0m0s"
  schedule = "0 3 * * *" #refers to UTC timezone
  volume_snapshot = false
  
  alert_enabled = true
  
  cluster_id = module.aks[count.index].id
  location = azurerm_resource_group.rg_aks_backup.location
  rg_name = azurerm_resource_group.rg_aks_backup.name
  
  #optional alert parameters
  alert_frequency = 60
  alert_time_window = 1440
  alert_severity = 1
  alert_threshold = 1
    
  tags = var.tags
}
```

You can declare which namespace to backup, and you can also use the keyword `ALL` to trigger an all-namespaces backup. It can be used alongside the other namespace names

The final backup name will be: `backup_name`-`namespace_name`-`datetime`

<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_scheduled_query_rules_alert.backup_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert) | resource |
| [null_resource.schedule_backup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_ids"></a> [action\_group\_ids](#input\_action\_group\_ids) | (Optional) list of action group ids to trigger when backup alarm fires | `list(string)` | `[]` | no |
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | (Required) Name of the aks cluster on which Velero will be installed | `string` | n/a | yes |
| <a name="input_alert_enabled"></a> [alert\_enabled](#input\_alert\_enabled) | (Optional) If true, creates a scheduled query alert for each backup execution | `bool` | `true` | no |
| <a name="input_alert_frequency"></a> [alert\_frequency](#input\_alert\_frequency) | (Optional) Frequency (in minutes) at which alert rule condition should be evaluated. Values must be between 5 and 1440 (inclusive). | `number` | `60` | no |
| <a name="input_alert_severity"></a> [alert\_severity](#input\_alert\_severity) | (Optional) Severity of the alert. Possible values include: 0, 1, 2, 3, or 4. | `number` | `1` | no |
| <a name="input_alert_threshold"></a> [alert\_threshold](#input\_alert\_threshold) | (Optional) threshold (query result count) under which the alert should be fired | `number` | `1` | no |
| <a name="input_alert_time_window"></a> [alert\_time\_window](#input\_alert\_time\_window) | (Optional) Time window for which data needs to be fetched for query (must be greater than or equal to frequency). Values must be between 5 and 2880 (inclusive). | `number` | `1440` | no |
| <a name="input_backup_name"></a> [backup\_name](#input\_backup\_name) | (Required) Name assigned to the backup, used as prefix for the namespace name | `string` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | (Required) cluster id that must be backed up and monitored | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Location where the backup alarm will be created | `string` | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | (Required) List of namespace names to backup. Use 'ALL' for an all-namespaces backup | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix assigned to the backup alarm | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | (Required) Resource group name where the backup alarm will be created | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | (Optional) Cron expression for the scheduled velero backup, in UTC timezone. ref: https://velero.io/docs/v1.9/backup-reference/ | `string` | `"0 3 * * *"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) set of tags for the backup alarm | `map(any)` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional) TTL for velero backup, expressed using '<number>h<number>m<number>s' format | `string` | `"360h0m0s"` | no |
| <a name="input_volume_snapshot"></a> [volume\_snapshot](#input\_volume\_snapshot) | (Optional) Whether or not to execute the persistence volume snapshot. Disabled by default | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
