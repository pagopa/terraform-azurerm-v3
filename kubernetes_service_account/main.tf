resource "kubernetes_service_account" "azure_devops" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_secret_v1" "azure_devops_service_account_default_secret" {
  metadata {
    name      = local.service_account_default_secret_name
    namespace = kubernetes_namespace.system_domain_namespace.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = var.name
    }
  }

  type = "kubernetes.io/service-account-token"
}

#
# Secrets service account on KV
#
data "kubernetes_secret" "azure_devops_secret" {
  metadata {
    name      = local.service_account_default_secret_name
    namespace = var.namespace
  }
  binary_data = {
    "ca.crt" = ""
    "token"  = ""
  }

  depends_on = [
    kubernetes_secret_v1.azure_devops_service_account_default_secret
  ]
}
