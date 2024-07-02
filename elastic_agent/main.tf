locals {

  #
  # Other
  #
  logs_general_to_exclude_paths = distinct(flatten([
    for instance_name in var.dedicated_log_instance_name : "'/var/log/containers/${instance_name}-*.log'"
  ]))

  #https://raw.githubusercontent.com/elastic/elastic-agent/8.9/deploy/kubernetes/elastic-agent-standalone-kubernetes.yaml
  agent_yaml = templatefile("${path.module}/yaml/${var.eck_version}/agent.yaml", {
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

  for_each = local.elastic_agent_defaultMode_converted

  manifest = each.value

  field_manager {
    force_conflicts = true
  }
  computed_fields = ["spec.template.spec.containers[0].resources"]
}
