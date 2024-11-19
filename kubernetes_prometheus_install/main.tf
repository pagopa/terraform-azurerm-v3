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

  set {
    name  = "server.global.scrape_interval"
    value = "30s"
  }
  set {
    name  = "alertmanager.image.repository"
    value = var.prometheus_helm.alertmanager.image_name
  }
  set {
    name  = "alertmanager.image.tag"
    value = var.prometheus_helm.alertmanager.image_tag
  }
  set {
    name  = "alertmanager.configmapReload.prometheus.image.repository"
    value = var.prometheus_helm.configmap_reload_prometheus.image_name
  }
  set {
    name  = "alertmanager.configmapReload.prometheus.image.tag"
    value = var.prometheus_helm.configmap_reload_prometheus.image_tag
  }
  set {
    name  = "alertmanager.configmapReload.alertmanager.image.repository"
    value = var.prometheus_helm.configmap_reload_alertmanager.image_name
  }
  set {
    name  = "alertmanager.configmapReload.alertmanager.image.tag"
    value = var.prometheus_helm.configmap_reload_alertmanager.image_tag
  }
  set {
    name  = "alertmanager.nodeExporter.image.repository"
    value = var.prometheus_helm.node_exporter.image_name
  }
  set {
    name  = "alertmanager.nodeExporter.image.tag"
    value = var.prometheus_helm.node_exporter.image_tag
  }
  set {
    name  = "alertmanager.nodeExporter.image.repository"
    value = var.prometheus_helm.node_exporter.image_name
  }
  set {
    name  = "alertmanager.nodeExporter.image.tag"
    value = var.prometheus_helm.node_exporter.image_tag
  }
  set {
    name  = "alertmanager.server.image.repository"
    value = var.prometheus_helm.server.image_name
  }
  set {
    name  = "alertmanager.server.image.tag"
    value = var.prometheus_helm.server.image_tag
  }
  set {
    name  = "alertmanager.pushgateway.image.repository"
    value = var.prometheus_helm.pushgateway.image_name
  }
  set {
    name  = "alertmanager.pushgateway.image.tag"
    value = var.prometheus_helm.pushgateway.image_tag
  }
  set {
    name  = "alertmanager.persistentVolume.storageClass"
    value = var.storage_class_name
  }
  set {
    name  = "server.persistentVolume.storageClass"
    value = var.storage_class_name
  }

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
