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
    cluster_enabled_log_types              = ["audit", "api"]
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
      min_size       = 3
      max_size       = 6
      desired_size   = 3
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

variable "tags" {
  type        = map(any)
  default     = {}
  description = <<-EOF
    Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module.
  EOF
}
