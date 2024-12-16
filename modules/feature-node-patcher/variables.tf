variable "cluster_node_rebooter_helm_chart_repository" {
  description = "The URL of the chart to use for the cluster monitoring"
  type        = string
  default     = "oci://public.registry.jetbrains.space/p/helm/library"
}

variable "cluster_node_rebooter_helm_chart_repository_config" {
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

variable "cluster_node_rebooter_helm_chart_version" {
  description = "The version of the chart to use for the cluster monitoring"
  type        = string
  default     = "5.4.3"
}

variable "cluster_node_rebooter_helm_chart_name" {
  description = "The name of the chart to use for the cluster monitoring"
  type        = string
  default     = "kube-node-reboot"
}

variable "cluster_node_rebooter_namespace" {
  description = "The namespace to install the cluster monitoring into"
  type        = string
  default     = "kube-node-rebooter"
}

variable "cluster_node_rebooter_create_namespace_if_not_exists" {
  description = "Whether to create the namespace if it does not exist"
  type        = bool
  default     = true
}

variable "cluster_node_rebooter_default_values_dot_yaml" {
  description = "The default values to use for the cluster monitoring"
  type        = string
  default     = null
}


variable "cluster_node_rebooter_params" {
  description = "The parameters to use for the cluster monitoring"
  type = list(object({
    name  = string
    value = any
  }))
  default = null
}

variable "cluster_node_rebooter_secrets" {
  description = "The secrets to use for the cluster monitoring"
  type = list(object({
    name  = string
    value = any
  }))
  default = null
}
