resource "helm_release" "cert_mounter" {
  name         = "cert-mounter-blueprint"
  repository   = "https://pagopa.github.io/aks-helm-cert-mounter-blueprint"
  chart        = "cert-mounter-blueprint"
  version      = "1.0.4"
  namespace    = var.namespace
  timeout      = 120
  force_update = true

  values = [
    templatefile("${path.root}/helm/cert-mounter.yaml.tpl", {
      NAMESPACE        = var.namespace,
      CERTIFICATE_NAME = var.certificate_name,
      KEY_VAULT_NAME   = var.kv_name
      TENANT_ID        = var.tenant_id
    })

  ]
}
