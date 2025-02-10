<!-- BEGIN_TF_DOCS -->
# terraform-feature-node-autoscaler

This module deploys the Karpenter Helm chart into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_role_arn"></a> [aws\_iam\_role\_arn](#input\_aws\_iam\_role\_arn) | The IAM role ARN. | `string` | `""` | no |
| <a name="input_aws_interruption_queue"></a> [aws\_interruption\_queue](#input\_aws\_interruption\_queue) | The AWS interruption queue. | `string` | `""` | no |
| <a name="input_helm_chart_create_namespace"></a> [helm\_chart\_create\_namespace](#input\_helm\_chart\_create\_namespace) | Create the namespace if it does not exist. | `bool` | `true` | no |
| <a name="input_helm_chart_name"></a> [helm\_chart\_name](#input\_helm\_chart\_name) | The Helm chart application name. | `string` | `"kube-karpenter"` | no |
| <a name="input_helm_chart_namespace"></a> [helm\_chart\_namespace](#input\_helm\_chart\_namespace) | The namespace to install the Helm chart. | `string` | `"kube-node-autoscaler"` | no |
| <a name="input_helm_chart_params"></a> [helm\_chart\_params](#input\_helm\_chart\_params) | The Helm chart parameters. | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
| <a name="input_helm_chart_repository"></a> [helm\_chart\_repository](#input\_helm\_chart\_repository) | The Helm chart repository. | `string` | `"oci://public.registry.jetbrains.space/p/helm/library"` | no |
| <a name="input_helm_chart_repository_config"></a> [helm\_chart\_repository\_config](#input\_helm\_chart\_repository\_config) | The Helm chart repository configuration. | <pre>object({<br/>    repository_key_file  = optional(string)<br/>    repository_cert_file = optional(string)<br/>    repository_ca_file   = optional(string)<br/>    repository_username  = optional(string)<br/>    repository_password  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_helm_chart_secrets"></a> [helm\_chart\_secrets](#input\_helm\_chart\_secrets) | The Helm chart secrets. | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
| <a name="input_helm_chart_values"></a> [helm\_chart\_values](#input\_helm\_chart\_values) | The Helm chart values. | `any` | `null` | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | The Helm chart version. | `string` | `"0.35.1"` | no |
| <a name="input_kubernetes_cluster_ca_bundle"></a> [kubernetes\_cluster\_ca\_bundle](#input\_kubernetes\_cluster\_ca\_bundle) | The Kubernetes cluster CA bundle. | `string` | `""` | no |
| <a name="input_kubernetes_cluster_endpoint"></a> [kubernetes\_cluster\_endpoint](#input\_kubernetes\_cluster\_endpoint) | The Kubernetes cluster endpoint. | `string` | `""` | no |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | The Kubernetes cluster name. | `string` | `""` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | Helm charts outputs |
<!-- END_TF_DOCS -->