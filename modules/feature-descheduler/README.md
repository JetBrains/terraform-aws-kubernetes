<!-- BEGIN_TF_DOCS -->
# terraform-feature-descheduler

This module deploys the Descheduler Helm chart into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_descheduler_default_values_dot_yaml"></a> [descheduler\_default\_values\_dot\_yaml](#input\_descheduler\_default\_values\_dot\_yaml) | The default values to use for descheduler controller | `string` | `null` | no |
| <a name="input_descheduler_helm_chart_name"></a> [descheduler\_helm\_chart\_name](#input\_descheduler\_helm\_chart\_name) | The name of the chart to use for descheduler controller | `string` | `"kube-descheduler"` | no |
| <a name="input_descheduler_helm_chart_repository"></a> [descheduler\_helm\_chart\_repository](#input\_descheduler\_helm\_chart\_repository) | The URL of the chart to use for descheduler controller | `string` | `"oci://public.registry.jetbrains.space/p/helm/library"` | no |
| <a name="input_descheduler_helm_chart_repository_config"></a> [descheduler\_helm\_chart\_repository\_config](#input\_descheduler\_helm\_chart\_repository\_config) | The configuration for the helm chart repository | <pre>object({<br>    repository_key_file  = optional(string)<br>    repository_cert_file = optional(string)<br>    repository_ca_file   = optional(string)<br>    repository_username  = optional(string)<br>    repository_password  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_descheduler_helm_chart_version"></a> [descheduler\_helm\_chart\_version](#input\_descheduler\_helm\_chart\_version) | The version of the chart to use for descheduler controller | `string` | `"0.29.0"` | no |
| <a name="input_descheduler_params"></a> [descheduler\_params](#input\_descheduler\_params) | The parameters to use for descheduler controller | <pre>list(object({<br>    name  = string<br>    value = any<br>  }))</pre> | `[]` | no |
| <a name="input_descheduler_secrets"></a> [descheduler\_secrets](#input\_descheduler\_secrets) | The secrets to use for descheduler controller | <pre>list(object({<br>    name  = string<br>    value = any<br>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | Descheduler controller outputs |
<!-- END_TF_DOCS -->