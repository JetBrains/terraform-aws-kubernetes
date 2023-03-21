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

    Use this attribute when and only when this module was already deployed in the targeted AWS account.
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

variable "tags" {
  type        = map(any)
  default     = {}
  description = <<-EOF
    Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module.
  EOF
}
