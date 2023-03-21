variable "region" {
  type        = string
  default     = "eu-west-1"
  description = <<-EOF
    Specify the name of the location where the resources of this module will be created.

    This name must be a valid AWS region name.
  EOF
}

variable "name" {
  type        = string
  default     = "kube"
  description = <<-EOF
    Overwrite the prefix name that is used internally to name the resources.

    Use this attribute when and only when this module was already delployed in the desired AWS account.
  EOF
}

variable "environment" {
  type        = string
  default     = "try-out"
  description = <<-EOF
    Specify the environment name.

    Use this attribute to give meaning to the EKS cluster and its related resources.
  EOF
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = <<-EOF
    Specify the networking set of addresses for Kubernetes. Use the prefix notation.

    Ref: https://www.rfc-editor.org/rfc/rfc4632#section-3.1
  EOF
}

variable "vpc_nat_gateway_type" {
  type        = string
  default     = "one_nat_gateway_per_az"
  description = <<-EOF
    Specify the type of the NAT Gateway.

    Ref: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
  EOF
  validation {
    condition = anytrue([
      var.vpc_nat_gateway_type == "single_nat_gateway",
      var.vpc_nat_gateway_type == "one_nat_gateway_per_subnet",
      var.vpc_nat_gateway_type == "one_nat_gateway_per_az",
    ])
    error_message = "Must be one of the following options: single_nat_gateway, one_nat_gateway_per_subnet, one_nat_gateway_per_az"
  }
}

variable "kubernetes_api_version" {
  type        = string
  default     = "1.23"
  description = <<-EOF
    Specify the version of the Kubernetes API.
  EOF
}

variable "kubernetes_api_allow_network_access_from" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = <<-EOF
    Specify a list of source IPv4 addresses that can initiate
    a network authentication with the Kubernetes API.

    Important
  EOF
}

variable "kubernetes_api_logs" {
  type = object({
    create_cloudwatch_log_group            = bool
    cloudwatch_log_group_retention_in_days = number
    cluster_enabled_log_types              = list(string)
  })
  default = {
    create_cloudwatch_log_group            = true
    cloudwatch_log_group_retention_in_days = 14
    cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }
  description = <<-EOF
    Specify if it is desirable to persist the logs of the Kubernetes API
    in a CloudWatch Log Group. Define for how long to persist the logs and also
    specify what logs to persist.
  EOF
}

variable "kubernetes_cluster_admin_iam_roles" {
  type        = list(string)
  default     = ["*"]
  description = <<-EOF
    Specify a list of IAM roles that will administer the cluster across all Kubernetes namespaces.

    By default allow every engineer in the AWS account to have administrative access to the cluster.
  EOF
}

variable "kubernetes_cluster_worker_pools" {
  type = any
  default = {
    blue = {
      min_size       = 5
      max_size       = 5
      desired_size   = 5
      instance_types = ["t3a.2xlarge"]
      capacity_type  = "ON_DEMAND"
      labels = {
        pool-color = "blue"
      }
      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }
  description = <<-EOF
    Specify the configuration for the worker pools. By default there is one pool, named blue.
    It uses Linux EC2 instances. The capacity is `spot`.

    It is possible to overwrite the default pool as well.
  EOF
}

variable "kubernetes_cluster_services_configs" {
  type = object({
    kube_private_ingress_set_values = optional(list(any))
    kube_public_ingress_set_values  = optional(list(any))
  })
  default = {
    kube_private_ingress_set_values = []
    kube_public_ingress_set_values  = []
  }
  description = <<-EOF
    Specify that details that allow to adjust the configuration of the cluster services.
    Notice that at the moment, the public and private ingress controller does not support
    mixed protocols at the LoadBalancer level.

    Example:
      {
        kube_private_ingress_set_values = [
          {
              name  = "tcp.8080"
              value = "default/svc:8080"
          },
          {
              name  = "tcp.8081"
              value = "kube-system/not-existent:8888"
          }
        ]
        kube_public_ingress_set_values = ...
      }
  EOF
}

variable "kubernetes_packages_as_helm_charts" {
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
  default     = null
  description = <<-EOF
    Specify a list of packages to install in the Kubernetes cluster as soon as it is ready.
EOF
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = <<-EOF
    Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module.
  EOF
}
