# kubernetes velero backup

Module that allows the scheduling of velero backups for specific namespaces

## How to use it

This module requires Velero to be installed; check module `kubernetes_cluster` for details on the installation

### Variable definition example

```hcl
module "aks_namespace_backup" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_velero_backup?ref=<version>"

  backup_name = "daily-backup"
  namespaces = ["my-namespace-name"]
  ttl = "100h0m0s"
  schedule = "0 3 * * *" #refers to UTC timezone
  volume_snapshot = false
}

```


<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | <= 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.schedule_backup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_name"></a> [backup\_name](#input\_backup\_name) | (Required) Name assigned to the backup, used as prefix for the namespace name | `string` | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | (Required) List of namespace names to backup | `list(string)` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | (Optional) Cron expression for the scheduled velero backup, in UTC timezone. ref: https://velero.io/docs/v1.9/backup-reference/ | `string` | `"0 3 * * *"` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional) TTL for velero backup, expressed using '<number>h<number>m<number>s' format | `string` | `"360h0m0s"` | no |
| <a name="input_volume_snapshot"></a> [volume\_snapshot](#input\_volume\_snapshot) | (Optional) Whether or not to execute the persistence volume snapshot. Disabled by default | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
