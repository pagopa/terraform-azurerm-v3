locals {
  env_short = substr(var.env, 0, 1)
  location  = data.azurerm_kubernetes_cluster.aks.location
}

resource "azurerm_role_definition" "open_cost_role" {
  name        = "${var.project}-${local.env_short}-${local.location}-OpenCostRole"
  scope       = data.azurerm_subscription.current.id
  description = "Rate Card query role"
  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/vmSizes/read",
      "Microsoft.Resources/subscriptions/locations/read",
      "Microsoft.Resources/providers/read",
      "Microsoft.ContainerService/containerServices/read",
      "Microsoft.Commerce/RateCard/read"
    ]
    not_actions = []
  }
  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

# Create an Azure User-Assigned Managed Identity (UAMI)
resource "azurerm_user_assigned_identity" "opencost_identity" {
  name                = "${var.project}-${local.env_short}-${local.location}-opencost-managed-identity"
  location            = local.location
  resource_group_name = data.azurerm_kubernetes_cluster.aks.resource_group_name
}

# Assign role to UAMI
resource "azurerm_role_assignment" "opencost_identity_role" {
  principal_id         = azurerm_user_assigned_identity.opencost_identity.principal_id
  role_definition_name = azurerm_role_definition.open_cost_role.name
  scope                = data.azurerm_subscription.current.id
}

# Identity Details
output "managed_identity_details" {
  description = "Dettagli dell'identità gestita User-Assigned per OpenCost"
  value = jsonencode({
    identity_id  = azurerm_user_assigned_identity.opencost_identity.id
    principal_id = azurerm_user_assigned_identity.opencost_identity.principal_id
    client_id    = azurerm_user_assigned_identity.opencost_identity.client_id
    subscription = data.azurerm_subscription.current.id
    tenant       = data.azurerm_client_config.current.tenant_id
  })
}

# Kubernetes Secret configs and identity
resource "kubernetes_secret" "azure_managed_identity_refs" {
  metadata {
    name      = "azure-managed-identity"
    namespace = data.kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "client-id"    = azurerm_user_assigned_identity.opencost_identity.client_id
    "principal-id" = azurerm_user_assigned_identity.opencost_identity.principal_id
    "identity-id"  = azurerm_user_assigned_identity.opencost_identity.id
    "tenant-id"    = data.azurerm_client_config.current.tenant_id
  }

  type = "Opaque"
}

# # Helm deployment for "prometheus-opencost-exporter"
resource "helm_release" "prometheus_opencost_exporter" {
  name       = "prometheus-opencost-exporter"
  namespace  = data.kubernetes_namespace.monitoring.metadata[0].name
  chart      = "prometheus-opencost-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "0.1.1" # Adjust the version as needed

  # Set additional values for the Helm chart if required
  set {
    name  = "extraVolumes[0].name"
    value = "azure-managed-identity-secret"
  }

  set {
    name  = "extraVolumes[0].secret.secretName"
    value = kubernetes_secret.azure_managed_identity_refs.metadata[0].name
  }

  set {
    name  = "opencost.exporter.extraVolumeMounts[0].mountPath"
    value = "/var/secrets"
  }

  set {
    name  = "opencost.exporter.extraVolumeMounts[0].name"
    value = "azure-managed-identity-secret"
  }

  set {
    name  = "opencost.prometheus.external.url"
    value = var.prometheus_config.external_url
  }

  set {
    name  = "opencost.prometheus.internal.namespaceName"
    value = var.prometheus_config.namespace
  }
  set {
    name  = "opencost.prometheus.internal.port"
    value = var.prometheus_config.service_port
  }
  set {
    name  = "opencost.prometheus.internal.serviceName"
    value = var.prometheus_config.service_name
  }

  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }
}

# Service Monitor
resource "kubernetes_manifest" "opencost_service_monitor" {
  manifest = {
    "apiVersion" : "monitoring.coreos.com/v1"
    "kind" : "ServiceMonitor"
    "metadata" : {
      "name" : "prometheus-opencosts"
      "namespace" : data.kubernetes_namespace.monitoring.metadata[0].name
    }
    "spec" : {
      "selector" : {
        "matchLabels" : {
          "app.kubernetes.io/instance" : "prometheus-opencost-exporter"
          "app.kubernetes.io/name" : "prometheus-opencost-exporter"
        }
      }
      "endpoints" : [
        {
          "port" : "http"
          "interval" : "30s"
          "path" : "/metrics"
        }
      ]
      jobLabel : "opencost"
    }
  }
}

