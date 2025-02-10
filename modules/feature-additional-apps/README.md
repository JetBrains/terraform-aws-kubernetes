<!-- BEGIN_TF_DOCS -->
# terraform-additional-apps

This module deploys Helm charts into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

No providers.
## Resources

No resources.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apps"></a> [apps](#input\_apps) | List of Helm Charts to deploy in the Kubernetes cluster. | <pre>list(object({<br/>    namespace  = string<br/>    repository = string<br/>    repository_config = optional(object({<br/>      repository_key_file  = optional(string)<br/>      repository_cert_file = optional(string)<br/>      repository_ca_file   = optional(string)<br/>      repository_username  = optional(string)<br/>      repository_password  = optional(string)<br/>    }))<br/>    app = object({<br/>      name                       = string<br/>      chart                      = string<br/>      version                    = string<br/>      force_update               = optional(bool)<br/>      wait                       = optional(bool)<br/>      recreate_pods              = optional(bool)<br/>      max_history                = optional(number)<br/>      lint                       = optional(bool)<br/>      cleanup_on_fail            = optional(bool)<br/>      create_namespace           = optional(bool)<br/>      disable_webhooks           = optional(bool)<br/>      verify                     = optional(bool)<br/>      reuse_values               = optional(bool)<br/>      reset_values               = optional(bool)<br/>      atomic                     = optional(bool)<br/>      skip_crds                  = optional(bool)<br/>      render_subchart_notes      = optional(bool)<br/>      disable_openapi_validation = optional(bool)<br/>      wait_for_jobs              = optional(bool)<br/>      dependency_update          = optional(bool)<br/>      replace                    = optional(bool)<br/>    })<br/>    values = optional(any)<br/>    params = optional(list(object({<br/>      name  = string<br/>      value = any<br/>    })))<br/>    secrets = optional(list(object({<br/>      name  = string<br/>      value = any<br/>    })))<br/>  }))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | Helm charts outputs |
<!-- END_TF_DOCS -->