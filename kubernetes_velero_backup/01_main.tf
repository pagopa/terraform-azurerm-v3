resource "null_resource" "schedule_backup" {
  for_each = toset(var.namespaces)

  triggers = {
    backup_name     = var.backup_name
    schedule        = var.schedule
    volume_snapshot = var.volume_snapshot
    ttl             = var.ttl
    namespace       = each.value
    cluster_name    = var.aks_cluster_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    kubectl config use-context "${self.triggers.cluster_name}" && \
    velero schedule delete ${self.triggers.backup_name}-${self.triggers.namespace} --confirm
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
    kubectl config use-context "${self.triggers.cluster_name}" && \
    velero schedule create ${lower(self.triggers.backup_name)}-${lower(self.triggers.namespace)} --schedule="${var.schedule}" --ttl ${var.ttl} %{if each.value != "ALL"} --include-namespaces ${each.value} %{endif} --snapshot-volumes=${var.volume_snapshot}
    EOT
  }
}
