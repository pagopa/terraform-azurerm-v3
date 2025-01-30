# this resource is only used to trigger the helm release replacement if the storage class name is changed.
# Storage class name changes does not allow the update in place, and the provider does not handle the replacement, so using this resource and the attribute
# 'replace_triggered_by' in helm_release we acheive the desired result
resource "null_resource" "trigger_helm_release" {
  triggers = {
    storage_class_name = var.storage_class_name
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_helm.chart_version
  namespace  = var.prometheus_namespace

  values = [
    templatefile("${path.module}/values.yaml", {
    storage_class_name = var.storage_class_name
  })
  ]

  # Lifecycle policy to handle updates
  lifecycle {
    replace_triggered_by = [
      null_resource.trigger_helm_release
    ]
  }
}

#
# CRDS
#
resource "helm_release" "prometheus_crds" {

  count = var.prometheus_crds_enabled ? 1 : 0

  name       = "prometheus-crds"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-operator-crds"
  version    = var.prometheus_crds_release_version
  namespace  = var.prometheus_namespace

  timeout      = 300
  force_update = true
  wait         = true
}
