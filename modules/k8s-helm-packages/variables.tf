/*
* This file define the public input interface of this Module.
*/

variable "charts" {
  type = list(object({
    namespace  = string
    repository = string
    repository_config = optional(object({
      repository_key_file  = optional(string)
      repository_cert_file = optional(string)
      repository_ca_file   = optional(string)
      repository_username  = optional(string)
      repository_password  = optional(string)
    }))
    app = object({
      name                       = string
      chart                      = string
      version                    = string
      force_update               = optional(bool)
      wait                       = optional(bool)
      recreate_pods              = optional(bool)
      max_history                = optional(number)
      lint                       = optional(bool)
      cleanup_on_fail            = optional(bool)
      create_namespace           = optional(bool)
      disable_webhooks           = optional(bool)
      verify                     = optional(bool)
      reuse_values               = optional(bool)
      reset_values               = optional(bool)
      atomic                     = optional(bool)
      skip_crds                  = optional(bool)
      render_subchart_notes      = optional(bool)
      disable_openapi_validation = optional(bool)
      wait_for_jobs              = optional(bool)
      dependency_update          = optional(bool)
      replace                    = optional(bool)
    })
    values = optional(any)
    params = optional(list(object({
      name  = string
      value = any
    })))
    secrets = optional(list(object({
      name  = string
      value = any
    })))
  }))
  description = <<-EOF
    List of Helm Charts to deploy in the Kubernetes cluster.
  EOF
  default     = null
}


