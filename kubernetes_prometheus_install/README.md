# kubernetes prometheus installation

This installs Prometheus into your AKS cluster, using the given namespace.

## 📌 For production use

Change the `storage_class_name` varaible in order to use a Zone Redundant storage class (see `kubernetes_storage_class` module)

## How to use it

```hcl
module "aks_prometheus_install" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_prometheus_install?ref=v8.8.0"
  
  prometheus_namespace = "monitoring"
  storage_class_name = "default-zrs" #example of ZRS storage class created by kubernetes_storage_class
  prometheus_crds_enabled = true
}
```

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.12 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.prometheus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.trigger_helm_release](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prometheus_crds_enabled"></a> [prometheus\_crds\_enabled](#input\_prometheus\_crds\_enabled) | Setup CRDS for prometheus | `bool` | `false` | no |
| <a name="input_prometheus_crds_release_version"></a> [prometheus\_crds\_release\_version](#input\_prometheus\_crds\_release\_version) | Prometheus CRDS helm release version. https://github.com/prometheus-community/helm-charts/pkgs/container/charts%2Fprometheus-operator-crds | `string` | `"16.0.0"` | no |
| <a name="input_prometheus_helm"></a> [prometheus\_helm](#input\_prometheus\_helm) | Prometheus helm chart configuration | <pre>object({<br/>    chart_version = optional(string, "25.24.1")<br/>    server = object({<br/>      image_name = optional(string, "quay.io/prometheus/prometheus"),<br/>      image_tag  = optional(string, "v2.53.1"),<br/>    }),<br/>    alertmanager = object({<br/>      image_name = optional(string, "quay.io/prometheus/alertmanager"),<br/>      image_tag  = optional(string, "v0.27.0"),<br/>    }),<br/>    node_exporter = object({<br/>      image_name = optional(string, "quay.io/prometheus/node-exporter"),<br/>      image_tag  = optional(string, "v1.8.2"),<br/>    }),<br/>    configmap_reload_prometheus = object({<br/>      image_name = optional(string, "jimmidyson/configmap-reload"),<br/>      image_tag  = optional(string, "v0.13.1"),<br/>    }),<br/>    configmap_reload_alertmanager = object({<br/>      image_name = optional(string, "jimmidyson/configmap-reload"),<br/>      image_tag  = optional(string, "v0.13.1"),<br/>    }),<br/>    pushgateway = object({<br/>      image_name = optional(string, "prom/pushgateway"),<br/>      image_tag  = optional(string, "v1.9.0"),<br/>    }),<br/>  })</pre> | <pre>{<br/>  "alertmanager": {<br/>    "image_name": "quay.io/prometheus/alertmanager",<br/>    "image_tag": "v0.27.0"<br/>  },<br/>  "chart_version": "25.24.1",<br/>  "configmap_reload_alertmanager": {<br/>    "image_name": "jimmidyson/configmap-reload",<br/>    "image_tag": "v0.13.1"<br/>  },<br/>  "configmap_reload_prometheus": {<br/>    "image_name": "jimmidyson/configmap-reload",<br/>    "image_tag": "v0.13.1"<br/>  },<br/>  "node_exporter": {<br/>    "image_name": "quay.io/prometheus/node-exporter",<br/>    "image_tag": "v1.8.2"<br/>  },<br/>  "pushgateway": {<br/>    "image_name": "prom/pushgateway",<br/>    "image_tag": "v1.9.0"<br/>  },<br/>  "server": {<br/>    "image_name": "quay.io/prometheus/prometheus",<br/>    "image_tag": "v2.53.1"<br/>  }<br/>}</pre> | no |
| <a name="input_prometheus_namespace"></a> [prometheus\_namespace](#input\_prometheus\_namespace) | (Required) Name of the monitoring namespace, used to install prometheus resources | `string` | n/a | yes |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name) | (Optional) Storage class name used for prometheus server and alertmanager | `string` | `"default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
