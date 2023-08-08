#############
# Install CRDs and Operator
# https://www.elastic.co/guide/en/cloud-on-k8s/2.1/k8s-deploy-eck.html
# version 2.6.1
#############
locals {
  orig_crd_yaml     = file("${path.module}/yaml/crds.yaml")
  crd_yaml_del_time = replace(local.orig_crd_yaml, "\n  creationTimestamp: null", "")
  crd_yaml          = local.crd_yaml_del_time

  orig_operator_yaml          = file("${path.module}/yaml/operator.yaml")
  operator_yaml_set_namespace = replace(local.orig_operator_yaml, "namespace: elastic-system", "namespace: ${var.namespace}") #usato il replace per essere più comodi in un futuro cambio versione
  operator_yaml               = local.operator_yaml_set_namespace

  elastic_yaml = templatefile("${path.module}/yaml/elastic.yaml", {
    namespace            = var.namespace
    nodeset_config       = var.nodeset_config
    snapshot_secret_name = var.snapshot_secret_name
  })

  elastic_ingress_yaml = yamldecode(templatefile("${path.module}/yaml/ingress_elastic.yaml", {
    namespace                = var.namespace
    kibana_internal_hostname = var.kibana_internal_hostname
    secret_name              = var.secret_name
  }))

  kibana_secret_provider_yaml = yamldecode(templatefile("${path.module}/yaml/SecretProvider.yaml", {
    namespace     = var.namespace
    secret_name   = var.secret_name
    keyvault_name = var.keyvault_name
  }))

  kibana_mounter_yaml = yamldecode(templatefile("${path.module}/yaml/mounter.yaml", {
    namespace   = var.namespace
    secret_name = var.secret_name
  }))

  kibana_yaml = templatefile("${path.module}/yaml/kibana.yaml", {
    namespace       = var.namespace
    external_domain = var.kibana_external_domain
  })

  kibana_ingress_yaml = yamldecode(templatefile("${path.module}/yaml/ingress_kibana.yaml", {
    namespace                = var.namespace
    kibana_internal_hostname = var.kibana_internal_hostname
    secret_name              = var.secret_name
  }))

  apm_yaml = templatefile("${path.module}/yaml/apm.yaml", {
    namespace = var.namespace
  })

  apm_ingress_yaml = yamldecode(templatefile("${path.module}/yaml/ingress_apm.yaml", {
    namespace                = var.namespace
    kibana_internal_hostname = var.kibana_internal_hostname
    secret_name              = var.secret_name
  }))

  logs_general_to_exclude_paths = distinct(flatten([
    for instance_name in var.dedicated_log_instance_name : "'/var/log/containers/${instance_name}-*.log'"
  ]))


  agent_yaml = templatefile("${path.module}/yaml/agent.yaml", {
    namespace                     = var.namespace
    dedicated_log_instance_name   = var.dedicated_log_instance_name
    logs_general_to_exclude_paths = local.logs_general_to_exclude_paths

    system_name     = "system-1"
    system_id       = "id_system_1"
    system_revision = 1

    kubernetes_name     = "kubernetes-1"
    kubernetes_id       = "id_kubernetes_1"
    kubernetes_revision = 1

    apm_name     = "apm-1"
    apm_id       = "id_apm_1"
    apm_revision = 1
  })

}

resource "kubernetes_manifest" "crd" {
  # Create a map { "kind--name" => yaml_doc } from the multi-document yaml text.
  # Each element is a separate kubernetes resource.
  # Must use \n---\n to avoid splitting on strings and comments containing "---".
  # YAML allows "---" to be the first and last line of a file, so make sure
  # raw yaml begins and ends with a newline.
  # The "---" can be followed by spaces, so need to remove those too.
  # Skip blocks that are empty or comments-only in case yaml began with a comment before "---".
  for_each = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${replace(local.crd_yaml, "/(?m)^---[[:blank:]]*(#.*)?$/", "---")}\n"
      ) :
      yamldecode(replace(yaml, "/(?s:\nstatus:.*)$/", ""))
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest = each.value
  field_manager {
    force_conflicts = true
  }
  computed_fields = [
    "metadata.labels", "metadata.annotations",
    "metadata.creationTimestamp",
  ]
}

resource "kubernetes_manifest" "operator" {
  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl get namespaces --no-headers -o custom-columns=:metadata.name | xargs -n1 kubectl delete elastic --all -n"
    interpreter = ["/bin/bash", "-c"]
  }

  # Create a map { "kind--name" => yaml_doc } from the multi-document yaml text.
  # Each element is a separate kubernetes resource.
  # Must use \n---\n to avoid splitting on strings and comments containing "---".
  # YAML allows "---" to be the first and last line of a file, so make sure
  # raw yaml begins and ends with a newline.
  # The "---" can be followed by spaces, so need to remove those too.
  # Skip blocks that are empty or comments-only in case yaml began with a comment before "---".
  for_each = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${replace(local.operator_yaml, "/(?m)^---[[:blank:]]*(#.*)?$/", "---")}\n"
      ) :
      yamldecode(replace(yaml, "/(?s:\nstatus:.*)$/", ""))
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
  manifest = each.value
  field_manager {
    force_conflicts = true
  }
  computed_fields = [
    "metadata.labels", "metadata.annotations",
    "metadata.creationTimestamp", "webhooks",
  ]
  depends_on = [
    kubernetes_manifest.crd
  ]
}


#############
# Install Elasticsearch cluster
# https://www.elastic.co/guide/en/cloud-on-k8s/2.1/k8s-deploy-elasticsearch.html
# version 8.6.2
#############
####################
## USE trick for crd https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
####################
resource "kubectl_manifest" "elasticsearch_cluster" {
  depends_on = [
    kubernetes_manifest.operator
  ]
  force_conflicts = true
  yaml_body       = local.elastic_yaml
}

resource "kubernetes_manifest" "ingress_elastic_manifest" {
  manifest = local.elastic_ingress_yaml
  depends_on = [
    kubectl_manifest.elasticsearch_cluster
  ]
}

resource "null_resource" "wait_elasticsearch_cluster" {
  depends_on = [
    kubernetes_manifest.ingress_elastic_manifest
  ]

  provisioner "local-exec" {
    command     = "while [ true ]; do STATUS=`kubectl -n ${var.namespace} get Elasticsearch -ojsonpath='{range .items[*]}{.status.health}'`; if [ \"$STATUS\" = \"green\" ]; then echo \"ELASTIC SUCCEEDED\" ; break ; else echo \"ELASTIC INPROGRESS\"; sleep 3; fi ; done"
    interpreter = ["/bin/bash", "-c"]
  }
}

data "kubernetes_secret" "get_elastic_credential" {
  depends_on = [
    null_resource.wait_elasticsearch_cluster
  ]

  metadata {
    name      = "quickstart-es-elastic-user"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "eck_license" {
  metadata {
    name = "eck-license"
    labels = {
      "license.k8s.elastic.co/scope" = "operator"
    }
    namespace = var.namespace
  }

  data = {
    license = var.eck_license
  }

}

#############
# Create cert mounter for certs
#############
# create secret-provider for mounter
resource "kubernetes_manifest" "secret_manifest" {
  depends_on = [
    null_resource.wait_elasticsearch_cluster
  ]
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest        = local.kibana_secret_provider_yaml
}

# create fake mounter for load certs
resource "kubernetes_manifest" "mounter_manifest" {
  depends_on = [
    kubernetes_manifest.secret_manifest
  ]
  field_manager {
    force_conflicts = true
  }
  computed_fields = ["metadata.labels", "metadata.annotations", "spec", "status"]
  manifest        = local.kibana_mounter_yaml
}


#############
# Install Kibana
# https://www.elastic.co/guide/en/cloud-on-k8s/2.1/k8s-deploy-kibana.html
# version 8.6.2
#############
####################
## USE trick for crd https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
####################
resource "kubectl_manifest" "kibana_manifest" {
  depends_on = [
    kubernetes_manifest.mounter_manifest
  ]
  force_conflicts = true
  yaml_body       = local.kibana_yaml
}

## Create ingress for kibana
resource "kubernetes_manifest" "ingress_kibana_manifest" {
  manifest = local.kibana_ingress_yaml
  depends_on = [
    kubectl_manifest.kibana_manifest
  ]
}

resource "null_resource" "wait_kibana" {
  depends_on = [
    kubernetes_manifest.ingress_kibana_manifest
  ]

  provisioner "local-exec" {
    command     = "while [ true ]; do STATUS=`kubectl -n ${var.namespace} get Kibana -ojsonpath='{range .items[*]}{.status.health}'`; if [ \"$STATUS\" = \"green\" ]; then echo \"KIBANA SUCCEEDED\" ; break ; else echo \"KIBANA INPROGRESS\"; sleep 3; fi ; done"
    interpreter = ["/bin/bash", "-c"]
  }
}



#############
# Install APM Server
# https://www.elastic.co/guide/en/cloud-on-k8s/2.1/k8s-apm-eck-managed-es.html
# version 8.6.2
#############
####################
## USE trick for crd https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
####################
resource "kubectl_manifest" "apm_manifest" {
  depends_on = [
    null_resource.wait_kibana
  ]
  force_conflicts = true
  yaml_body       = local.apm_yaml
}
resource "kubernetes_manifest" "ingress_apm_manifest" {
  manifest = local.apm_ingress_yaml
  depends_on = [
    kubectl_manifest.apm_manifest
  ]
}
resource "null_resource" "wait_apm" {
  depends_on = [
    kubernetes_manifest.ingress_apm_manifest
  ]

  provisioner "local-exec" {
    command     = "while [ true ]; do STATUS=`kubectl -n ${var.namespace} get ApmServer -ojsonpath='{range .items[*]}{.status.health}'`; if [ \"$STATUS\" = \"green\" ]; then echo \"APM SUCCEEDED\" ; break ; else echo \"APM INPROGRESS\"; sleep 3; fi ; done"
    interpreter = ["/bin/bash", "-c"]
  }
}

#############
# Install Elastic Agent
#############
#data "kubectl_file_documents" "elastic_agent" {
#  content = local.agent_yaml
#}
locals {
  elastic_agent_defaultMode_converted = {
    for value in [
      for yaml in split(
        "\n---\n",
        "\n${replace(local.agent_yaml, "/(?m)^---[[:blank:]]*(#.*)?$/", "---")}\n"
      ) :
      yamldecode(replace(replace(yaml, "/(?s:\nstatus:.*)$/", ""), "0640", "416")) #transform 'defaultMode' octal value (0640) to decimal value (416)
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${value["kind"]}--${value["metadata"]["name"]}" => value
  }
}
# output "test" {
#   value = local.elastic_agent_defaultMode_converted
# }

resource "kubernetes_manifest" "elastic_agent" {
  depends_on = [
    null_resource.wait_elasticsearch_cluster
  ]
  for_each = local.elastic_agent_defaultMode_converted

  manifest = each.value

  field_manager {
    force_conflicts = true
  }
  computed_fields = ["spec.template.spec.containers[0].resources"]
}
