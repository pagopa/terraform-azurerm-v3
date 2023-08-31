resource "null_resource" "schedule_backup" {
  for_each = toset(var.namespaces)

  triggers = {
    backup_name     = var.backup_name
    schedule        = var.schedule
    volume_snapshot = var.volume_snapshot
    ttl             = var.ttl
    namespace       = each.value
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    velero schedule delete ${self.triggers.backup_name}-${self.triggers.namespace} --confirm
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
    velero schedule create ${self.triggers.backup_name}-${self.triggers.namespace} --schedule="${var.schedule}" --ttl ${var.ttl} --include-namespaces ${each.value} --snapshot-volumes=${var.volume_snapshot}
    EOT
  }
}
