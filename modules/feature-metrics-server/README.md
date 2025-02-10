<!-- BEGIN_TF_DOCS -->
# terraform-feature-metrics-server

This module deploys the Metrics Server Helm chart into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_metrics_server_create_namespace_if_not_exists"></a> [cluster\_metrics\_server\_create\_namespace\_if\_not\_exists](#input\_cluster\_metrics\_server\_create\_namespace\_if\_not\_exists) | Whether to create the namespace if it does not exist | `bool` | `true` | no |
| <a name="input_cluster_metrics_server_default_values_dot_yaml"></a> [cluster\_metrics\_server\_default\_values\_dot\_yaml](#input\_cluster\_metrics\_server\_default\_values\_dot\_yaml) | The default values to use for the cluster metrics server | `string` | `null` | no |
| <a name="input_cluster_metrics_server_helm_chart_name"></a> [cluster\_metrics\_server\_helm\_chart\_name](#input\_cluster\_metrics\_server\_helm\_chart\_name) | The name of the chart to use for the cluster metrics server | `string` | `"kube-metrics-server"` | no |
| <a name="input_cluster_metrics_server_helm_chart_repository"></a> [cluster\_metrics\_server\_helm\_chart\_repository](#input\_cluster\_metrics\_server\_helm\_chart\_repository) | The URL of the chart to use for the cluster metrics server | `string` | `"oci://public.registry.jetbrains.space/p/helm/library"` | no |
| <a name="input_cluster_metrics_server_helm_chart_repository_config"></a> [cluster\_metrics\_server\_helm\_chart\_repository\_config](#input\_cluster\_metrics\_server\_helm\_chart\_repository\_config) | The configuration for the helm chart repository | <pre>object({<br/>    repository_key_file  = optional(string)<br/>    repository_cert_file = optional(string)<br/>    repository_ca_file   = optional(string)<br/>    repository_username  = optional(string)<br/>    repository_password  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_cluster_metrics_server_helm_chart_version"></a> [cluster\_metrics\_server\_helm\_chart\_version](#input\_cluster\_metrics\_server\_helm\_chart\_version) | The version of the chart to use for the cluster metrics server | `string` | `"3.12.0"` | no |
| <a name="input_cluster_metrics_server_namespace"></a> [cluster\_metrics\_server\_namespace](#input\_cluster\_metrics\_server\_namespace) | The namespace to install the cluster metrics server into | `string` | `"kube-monitoring"` | no |
| <a name="input_cluster_metrics_server_params"></a> [cluster\_metrics\_server\_params](#input\_cluster\_metrics\_server\_params) | The parameters to use for the cluster metrics server | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
| <a name="input_cluster_metrics_server_secrets"></a> [cluster\_metrics\_server\_secrets](#input\_cluster\_metrics\_server\_secrets) | The secrets to use for the cluster metrics server | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | Cluster metrics server outputs |
<!-- END_TF_DOCS -->