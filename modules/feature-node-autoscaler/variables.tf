variable "helm_chart_repository" {
  type        = string
  description = "The Helm chart repository."
  default     = "oci://public.registry.jetbrains.space/p/helm/library"
}

variable "helm_chart_name" {
  type        = string
  description = "The Helm chart application name."
  default     = "kube-karpenter"
}

variable "helm_chart_version" {
  type        = string
  description = "The Helm chart version."
  default     = "0.35.1"
}

variable "helm_chart_namespace" {
  type        = string
  description = "The namespace to install the Helm chart."
  default     = "kube-node-autoscaler"
}

variable "helm_chart_create_namespace" {
  type        = bool
  description = "Create the namespace if it does not exist."
  default     = true
}

variable "helm_chart_repository_config" {
  type = object({
    repository_key_file  = optional(string)
    repository_cert_file = optional(string)
    repository_ca_file   = optional(string)
    repository_username  = optional(string)
    repository_password  = optional(string)
  })
  description = "The Helm chart repository configuration."
  default     = null
}

variable "helm_chart_values" {
  type        = any
  description = "The Helm chart values."
  default     = null
}

variable "helm_chart_params" {
  type = list(object({
    name  = string
    value = any
  }))
  description = "The Helm chart parameters."
  default     = []
}

variable "helm_chart_secrets" {
  type = list(object({
    name  = string
    value = any
  }))
  description = "The Helm chart secrets."
  default     = []
}

variable "kubernetes_cluster_name" {
  type        = string
  description = "The Kubernetes cluster name."
  default     = ""
}

variable "kubernetes_cluster_endpoint" {
  type        = string
  description = "The Kubernetes cluster endpoint."
  default     = ""
}

variable "kubernetes_cluster_ca_bundle" {
  type        = string
  description = "The Kubernetes cluster CA bundle."
  default     = ""
}

variable "aws_iam_role_arn" {
  type        = string
  description = "The IAM role ARN."
  default     = ""
}

variable "aws_interruption_queue" {
  type        = string
  description = "The AWS interruption queue."
  default     = ""
}