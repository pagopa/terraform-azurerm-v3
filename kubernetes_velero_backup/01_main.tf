resource "null_resource" "schedule_backup" {

  triggers = {
    scheduling = var.backup_scheduling

  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    velero schedule delete ${self.triggers.scheduling.backup_name} --confirm
    EOT
  }


  provisioner "local-exec" {
    command     = <<EOT
    velero create schedule ${var.backup_scheduling.backup_name} --schedule="${var.backup_scheduling.schedule}" --ttl ${var.backup_scheduling.ttl} --include-namespaces ${join(", ", var.backup_scheduling.namespaces)}
    EOT
  }
}
