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
    templatefile("${path.module}/helm/values.yaml", {
      storage_class_name = var.storage_class_name
      server_storage_size = var.prometheus_helm.server_storage_size
      alertmanager_storage_size = var.prometheus_helm.alertmanager_storage_size

      server_replicas = var.prometheus_helm.replicas
      alertmanager_replicas = var.prometheus_helm.replicas
      pushgateway_replicas = var.prometheus_helm.replicas
      kube_state_metrics_replicas = var.prometheus_helm.replicas

      node_selector = jsonencode(var.prometheus_node_selector)
      tolerations = jsonencode(var.prometheus_tolerations)

      server_affinity = lookup(var.prometheus_affinity, "server", local.default_affinity)
      alertmanager_affinity = lookup(var.prometheus_affinity, "alertmanager", local.default_affinity)
      pushgateway_affinity = lookup(var.prometheus_affinity, "pushgateway", local.default_affinity)
      kube_state_metrics_affinity = lookup(var.prometheus_affinity, "kube_state_metrics", local.default_affinity)
      node_exporter_tolerations = jsonencode(var.prometheus_tolerations)
    })
  ]

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
