# kubernetes velero backup

Module that allows the scheduling of velero backups for specific namespaces
Note that this module selects the correct cluster to work on using the command `kubectl config use-context "<cluster_name>"`, so you should have that context available in your `.kube` folder.
This is achievable using the utility script `k8setup.sh` included in the aks-setup folder of your IaC project

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
| [null_resource.schedule_backup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | (Required) Name of the aks cluster on which Velero will be installed | `string` | n/a | yes |
| <a name="input_backup_name"></a> [backup\_name](#input\_backup\_name) | (Required) Name assigned to the backup, used as prefix for the namespace name | `string` | n/a | yes |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | (Required) List of namespace names to backup. Use 'ALL' for an all-namespaces backup | `list(string)` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | (Optional) Cron expression for the scheduled velero backup, in UTC timezone. ref: https://velero.io/docs/v1.9/backup-reference/ | `string` | `"0 3 * * *"` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional) TTL for velero backup, expressed using '<number>h<number>m<number>s' format | `string` | `"360h0m0s"` | no |
| <a name="input_volume_snapshot"></a> [volume\_snapshot](#input\_volume\_snapshot) | (Optional) Whether or not to execute the persistence volume snapshot. Disabled by default | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
