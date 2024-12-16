variable "cluster_logging_helm_chart_repository" {
  description = "The URL of the chart to use for the cluster logging service"
  type        = string
  default     = "oci://public.registry.jetbrains.space/p/helm/library"
}

variable "cluster_logging_helm_chart_repository_config" {
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

variable "cluster_logging_helm_chart_version" {
  description = "The version of the chart to use for the cluster logging service"
  type        = string
  default     = "5.43.3"
}

variable "cluster_logging_helm_chart_name" {
  description = "The name of the chart to use for the cluster logging service"
  type        = string
  default     = "kube-grafana-loki"
}

variable "cluster_logging_namespace" {
  description = "The namespace to install the cluster logging service into"
  type        = string
  default     = "kube-monitoring"
}

variable "cluster_logging_create_namespace_if_not_exists" {
  description = "Whether to create the namespace if it does not exist"
  type        = bool
  default     = true
}

variable "cluster_logging_default_values_dot_yaml" {
  description = "The default values to use for the cluster logging service"
  type        = string
  default     = null
}


variable "cluster_logging_params" {
  description = "The parameters to use for the cluster logging service"
  type = list(object({
    name  = string
    value = any
  }))
  default = []
}

variable "cluster_logging_secrets" {
  description = "The secrets to use for the cluster logging service"
  type = list(object({
    name  = string
    value = any
  }))
  default = []
}
