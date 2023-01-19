resource "kubernetes_manifest" "elastic_manifest" {
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest = yamldecode(templatefile("${path.module}/yaml/elastic.yaml", {
    num_node_balancer      = var.balancer_node_number
    num_node_master        = var.master_node_number
    num_node_hot           = var.hot_node_number
    num_node_warm          = var.warm_node_number
    num_node_cold          = var.cold_node_number
    storage_size_balancer  = var.balancer_storage_size
    storage_size_master    = var.master_storage_size
    storage_size_hot       = var.hot_storage_size
    storage_size_warm      = var.warm_storage_size
    storage_size_cold      = var.cold_storage_size
    storage_class_balancer = var.balancer_storage_class
    storage_class_master   = var.master_storage_class
    storage_class_hot      = var.hot_storage_class
    storage_class_warm     = var.warm_storage_class
    storage_class_cold     = var.cold_storage_class
  }))
}

resource "kubernetes_manifest" "kibana_manifest" {
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest = yamldecode(templatefile("${path.module}/yaml/kibana.yaml", {
    external_domain = var.kibana_external_domain

  }))
}

resource "kubernetes_manifest" "ingress_manifest" {
  manifest = yamldecode(templatefile("${path.module}/yaml/ingress.yaml", {
    kibana_internal_hostname = var.kibana_internal_hostname
    secret_name              = var.secret_name
  }))
}

resource "kubernetes_manifest" "apm_manifest" {
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest        = yamldecode(file("${path.module}/yaml/apm.yaml"))
}

resource "kubernetes_manifest" "secret_manifest" {
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest = yamldecode(templatefile("${path.module}/yaml/SecretProvider.yaml", {
    secret_name   = var.secret_name
    keyvault_name = var.keyvault_name
  }))
}

resource "kubernetes_manifest" "mounter_manifest" {
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest = yamldecode(templatefile("${path.module}/yaml/mounter.yaml", {
    secret_name = var.secret_name
  }))
}