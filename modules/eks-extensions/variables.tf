variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "kubernetes_oidc_issuer_url" {
  type        = string
  description = <<-EOF
    Specify the Open ID Connect URL of the Kubernetes cluster for which the EBS CSI controller must be configured.
  EOF
  validation {
    condition     = !can(regex("^http:", var.kubernetes_oidc_issuer_url))
    error_message = "Error: the URL must not include the protocol name"
  }
}

variable "kubernetes_api_url" {
  type        = string
  description = <<-EOF
    Specify the URL of the Kubernetes API
  EOF
  validation {
    condition     = !can(regex("^http://", var.kubernetes_api_url))
    error_message = "Error: the HTTP protocol is not allowed. It must be HTTPS."
  }
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = <<-EOF
    Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module.
  EOF
}