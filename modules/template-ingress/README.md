<!-- BEGIN_TF_DOCS -->
# terraform-template-ingress

This module deploys an Nginx Ingress Controller Helm chart into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ingress_create_namespace_if_not_exists"></a> [ingress\_create\_namespace\_if\_not\_exists](#input\_ingress\_create\_namespace\_if\_not\_exists) | Whether to create the namespace if it does not exist | `bool` | `true` | no |
| <a name="input_ingress_default_values_dot_yaml"></a> [ingress\_default\_values\_dot\_yaml](#input\_ingress\_default\_values\_dot\_yaml) | The default values to use for ingress controller | `string` | `null` | no |
| <a name="input_ingress_helm_chart_name"></a> [ingress\_helm\_chart\_name](#input\_ingress\_helm\_chart\_name) | The name of the chart to use for ingress controller | `string` | `"kube-ingress-nginx"` | no |
| <a name="input_ingress_helm_chart_repository"></a> [ingress\_helm\_chart\_repository](#input\_ingress\_helm\_chart\_repository) | The URL of the chart to use for ingress controller | `string` | `"oci://public.registry.jetbrains.space/p/helm/library"` | no |
| <a name="input_ingress_helm_chart_repository_config"></a> [ingress\_helm\_chart\_repository\_config](#input\_ingress\_helm\_chart\_repository\_config) | The configuration for the helm chart repository | <pre>object({<br/>    repository_key_file  = optional(string)<br/>    repository_cert_file = optional(string)<br/>    repository_ca_file   = optional(string)<br/>    repository_username  = optional(string)<br/>    repository_password  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_ingress_helm_chart_version"></a> [ingress\_helm\_chart\_version](#input\_ingress\_helm\_chart\_version) | The version of the chart to use for ingress controller | `string` | `"4.10.0"` | no |
| <a name="input_ingress_namespace"></a> [ingress\_namespace](#input\_ingress\_namespace) | The namespace to install ingress controller into | `string` | `"kube-ingress"` | no |
| <a name="input_ingress_params"></a> [ingress\_params](#input\_ingress\_params) | The parameters to use for ingress controller | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
| <a name="input_ingress_secrets"></a> [ingress\_secrets](#input\_ingress\_secrets) | The secrets to use for ingress controller | <pre>list(object({<br/>    name  = string<br/>    value = any<br/>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | Ingress controller outputs |
<!-- END_TF_DOCS -->