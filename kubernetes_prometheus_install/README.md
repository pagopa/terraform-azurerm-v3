# kubernetes prometheus installation

This installs Prometheus and relatives CRDs into your AKS cluster, using the given namespace.

## 📌 For production use

Change the `storage_class_name` varaible in order to use a Zone Redundant storage class (see `kubernetes_storage_class` module)

## How to use it

```hcl
module "aks_prometheus_install" {
  source = "git::https://github.com/pagopa/terraform-azurerm-v3.git//kubernetes_prometheus_install?ref=<your version>"

  prometheus_namespace = kubernetes_namespace.monitoring.metadata[0].name
  storage_class_name   = "default-zrs"
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
| <a name="input_prometheus_affinity"></a> [prometheus\_affinity](#input\_prometheus\_affinity) | Global affinity rules for all Prometheus components | <pre>object({<br/>    nodeAffinity = object({<br/>      requiredDuringSchedulingIgnoredDuringExecution = object({<br/>        nodeSelectorTerms = list(object({<br/>          matchExpressions = list(object({<br/>            key      = string<br/>            operator = string<br/>            values   = list(string)<br/>          }))<br/>        }))<br/>      })<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_prometheus_crds_enabled"></a> [prometheus\_crds\_enabled](#input\_prometheus\_crds\_enabled) | Setup CRDS for prometheus | `bool` | `true` | no |
| <a name="input_prometheus_crds_release_version"></a> [prometheus\_crds\_release\_version](#input\_prometheus\_crds\_release\_version) | Prometheus CRDS helm release version. https://github.com/prometheus-community/helm-charts/pkgs/container/charts%2Fprometheus-operator-crds | `string` | `"17.0.2"` | no |
| <a name="input_prometheus_helm"></a> [prometheus\_helm](#input\_prometheus\_helm) | Prometheus helm chart configuration | <pre>object({<br/>    chart_version             = optional(string, "27.1.0")<br/>    server_storage_size       = optional(string, "128Gi")<br/>    alertmanager_storage_size = optional(string, "32Gi")<br/>    replicas                  = optional(number, 1)<br/>  })</pre> | <pre>{<br/>  "alertmanager_storage_size": "32Gi",<br/>  "chart_version": "27.1.0",<br/>  "replicas": 1,<br/>  "server_storage_size": "128Gi"<br/>}</pre> | no |
| <a name="input_prometheus_namespace"></a> [prometheus\_namespace](#input\_prometheus\_namespace) | (Required) Name of the monitoring namespace, used to install prometheus resources | `string` | n/a | yes |
| <a name="input_prometheus_node_selector"></a> [prometheus\_node\_selector](#input\_prometheus\_node\_selector) | Global node selector for all Prometheus components | `map(string)` | `{}` | no |
| <a name="input_prometheus_tolerations"></a> [prometheus\_tolerations](#input\_prometheus\_tolerations) | Global tolerations for all Prometheus components | <pre>list(object({<br/>    key      = string<br/>    operator = string<br/>    value    = string<br/>    effect   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name) | (Optional) Storage class name used for prometheus server and alertmanager | `string` | `"default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
