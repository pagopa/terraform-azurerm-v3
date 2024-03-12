resource "null_resource" "aks_with_iac_aad_plus_namespace_ci" {
  for_each = {for auth in var.authorizations: "${auth.service_principal_id}+${auth.namespace}" => auth}

  triggers = {
    aks_id               = auth.aks_id
    service_principal_id = auth.service_principal_id
    namespace            = auth.namespace
    role = auth.role
  }

  provisioner "local-exec" {
    command = <<EOT
      az role assignment create --role ${self.triggers.role} \
      --assignee ${self.triggers.service_principal_id} \
      --scope ${self.triggers.aks_id}/namespaces/${self.triggers.namespace}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      az role assignment delete --role ${self.triggers.role} \
      --assignee ${self.triggers.service_principal_id} \
      --scope ${self.triggers.aks_id}/namespaces/${self.triggers.namespace}
    EOT
  }
}
