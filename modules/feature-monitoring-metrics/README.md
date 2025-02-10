<!-- BEGIN_TF_DOCS -->
# terraform-feature-monitoring-metrics

This module deploys the Prometheus Operator Helm chart into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_monitoring_create_namespace_if_not_exists"></a> [cluster\_monitoring\_create\_namespace\_if\_not\_exists](#input\_cluster\_monitoring\_create\_namespace\_if\_not\_exists) | Whether to create the namespace if it does not exist | `bool` | `true` | no |
| <a name="input_cluster_monitoring_default_values_dot_yaml"></a> [cluster\_monitoring\_default\_values\_dot\_yaml](#input\_cluster\_monitoring\_default\_values\_dot\_yaml) | The default values to use for the cluster monitoring | `string` | `null` | no |
| <a name="input_cluster_monitoring_helm_chart_name"></a> [cluster\_monitoring\_helm\_chart\_name](#input\_cluster\_monitoring\_helm\_chart\_name) | The name of the chart to use for the cluster monitoring | `string` | `"kube-prometheus-operator"` | no |
| <a name="input_cluster_monitoring_helm_chart_repository"></a> [cluster\_monitoring\_helm\_chart\_repository](#input\_cluster\_monitoring\_helm\_chart\_repository) | The URL of the chart to use for the cluster monitoring | `string` | `"oci://public.registry.jetbrains.space/p/helm/library"` | no |
| <a name="input_cluster_monitoring_helm_chart_repository_config"></a> [cluster\_monitoring\_helm\_chart\_repository\_config](#input\_cluster\_monitoring\_helm\_chart\_repository\_config) | The configuration for the helm chart repository | <pre>object({<br/>    repository_key_file  = optional(string)<br/>    repository_cert_file = optional(string)<br/>    repository_ca_file   = optional(string)<br/>    repository_username  = optional(string)<br/>    repository_password  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_cluster_monitoring_helm_chart_version"></a> [cluster\_monitoring\_helm\_chart\_version](#input\_cluster\_monitoring\_helm\_chart\_version) | The version of the chart to use for the cluster monitoring | `string` | `"56.21.1"` | no |
| <a name="input_cluster_monitoring_namespace"></a> [cluster\_monitoring\_namespace](#input\_cluster\_monitoring\_namespace) | The namespace to install the cluster monitoring into | `string` | `"kube-monitoring"` | no |
| <a name="input_cluster_monitoring_params"></a> [cluster\_monitoring\_params](#input\_cluster\_monitoring\_params) | The parameters to use for the cluster monitoring | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_monitoring_secrets"></a> [cluster\_monitoring\_secrets](#input\_cluster\_monitoring\_secrets) | The secrets to use for the cluster monitoring | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | Cluster monitoring outputs |
<!-- END_TF_DOCS -->