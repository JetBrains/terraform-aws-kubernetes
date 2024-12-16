variable "descheduler_helm_chart_repository" {
  description = "The URL of the chart to use for descheduler controller"
  type        = string
  default     = "oci://public.registry.jetbrains.space/p/helm/library"
}

variable "descheduler_helm_chart_repository_config" {
  description = "The configuration for the helm chart repository"
  type = object({
    repository_key_file  = optional(string)
    repository_cert_file = optional(string)
    repository_ca_file   = optional(string)
    repository_username  = optional(string)
    repository_password  = optional(string)
  })
  default = null
}

variable "descheduler_helm_chart_version" {
  description = "The version of the chart to use for descheduler controller"
  type        = string
  default     = "0.29.0"
}

variable "descheduler_helm_chart_name" {
  description = "The name of the chart to use for descheduler controller"
  type        = string
  default     = "kube-descheduler"
}


variable "descheduler_default_values_dot_yaml" {
  description = "The default values to use for descheduler controller"
  type        = string
  default     = null
}


variable "descheduler_params" {
  description = "The parameters to use for descheduler controller"
  type = list(object({
    name  = string
    value = any
  }))
  default = []
}

variable "descheduler_secrets" {
  description = "The secrets to use for descheduler controller"
  type = list(object({
    name  = string
    value = any
  }))
  default = []
}
