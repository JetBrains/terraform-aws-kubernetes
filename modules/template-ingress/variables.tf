variable "ingress_helm_chart_repository" {
  description = "The URL of the chart to use for ingress controller"
  type        = string
  default     = "oci://public.registry.jetbrains.space/p/helm/library"
}

variable "ingress_helm_chart_repository_config" {
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

variable "ingress_helm_chart_version" {
  description = "The version of the chart to use for ingress controller"
  type        = string
  default     = "4.10.0"
}

variable "ingress_helm_chart_name" {
  description = "The name of the chart to use for ingress controller"
  type        = string
  default     = "kube-ingress-nginx"
}

variable "ingress_namespace" {
  description = "The namespace to install ingress controller into"
  type        = string
  default     = "kube-ingress"
}

variable "ingress_create_namespace_if_not_exists" {
  description = "Whether to create the namespace if it does not exist"
  type        = bool
  default     = true
}

variable "ingress_default_values_dot_yaml" {
  description = "The default values to use for ingress controller"
  type        = string
  default     = null
}


variable "ingress_params" {
  description = "The parameters to use for ingress controller"
  type = list(object({
    name  = string
    value = any
  }))
  default = []
}

variable "ingress_secrets" {
  description = "The secrets to use for ingress controller"
  type = list(object({
    name  = string
    value = any
  }))
  default = []
}
