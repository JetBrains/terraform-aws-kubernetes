<!-- BEGIN_TF_DOCS -->
# terraform-aws-eks

This module creates an EKS cluster in an AWS account.

## Compatibility

Use this module with Terraform 1.3.0+ version.

## Requirements

* The CloudWatch Log Group must be unique.

## Features

* AWS-managed nodes;

* Embedded VPC and defined networking architecture;

* IAM-enabled Kubernetes service accounts;

* Encrypted Kubernetes secrets.

## Known points of improvement

* Handle programmatic deletion of the CloudWatch Log Group if desired its removal.

## Core concepts

* [What is EKS?](https://docs.aws.amazon.com/eks/index.html);

* [What is Kubernetes?](https://kubernetes.io/docs/home/);

* [What is a Networking Spoke?](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology);

* [What are the IAM Roles for Service Accounts, as known as IRSA?](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html);

* [How to choose the best EC2 instance type for Kubernetes workers in EKS?](https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html).

## Requirements

No requirements.
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.this_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Specify the environment name.<br><br>Use this attribute to give meaning to the EKS cluster and its related resources. | `string` | `"try-out"` | no |
| <a name="input_kubernetes_api_allow_network_access_from"></a> [kubernetes\_api\_allow\_network\_access\_from](#input\_kubernetes\_api\_allow\_network\_access\_from) | Specify a list of source IPv4 addresses that can initiate<br>a network authentication with the Kubernetes API.<br><br>Important | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_kubernetes_api_logs"></a> [kubernetes\_api\_logs](#input\_kubernetes\_api\_logs) | Specify if it is desirable to persist the logs of the Kubernetes API<br>in a CloudWatch Log Group. Define for how long to persist the logs and also<br>specify what logs to persist. | <pre>object({<br>    create_cloudwatch_log_group            = bool<br>    cloudwatch_log_group_retention_in_days = number<br>    cluster_enabled_log_types              = list(string)<br>  })</pre> | <pre>{<br>  "cloudwatch_log_group_retention_in_days": 14,<br>  "cluster_enabled_log_types": [<br>    "audit",<br>    "api"<br>  ],<br>  "create_cloudwatch_log_group": true<br>}</pre> | no |
| <a name="input_kubernetes_api_version"></a> [kubernetes\_api\_version](#input\_kubernetes\_api\_version) | Specify the version of the Kubernetes API. | `string` | `"1.23"` | no |
| <a name="input_kubernetes_cluster_admin_iam_roles"></a> [kubernetes\_cluster\_admin\_iam\_roles](#input\_kubernetes\_cluster\_admin\_iam\_roles) | Specify a list of IAM roles that will administer the cluster across all Kubernetes namespaces.<br><br>By default allow every engineer in the AWS account to have administrative access to the cluster. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_kubernetes_cluster_worker_pools"></a> [kubernetes\_cluster\_worker\_pools](#input\_kubernetes\_cluster\_worker\_pools) | Specify the configuration for the worker pools. By default there is one pool, named blue.<br>It uses Linux EC2 instances. The capacity is `spot`.<br><br>It is possible to overwrite the default pool as well. | `any` | <pre>{<br>  "blue": {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_size": 3,<br>    "instance_types": [<br>      "t3a.2xlarge"<br>    ],<br>    "labels": {<br>      "pool-color": "blue"<br>    },<br>    "max_size": 6,<br>    "min_size": 3,<br>    "update_config": {<br>      "max_unavailable_percentage": 50<br>    }<br>  }<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Overwrite the prefix name that is used internally to name the resources.<br><br>Use this attribute when and only when this module was already delployed in the desired AWS account. | `string` | `"kube"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specify the name of the location where the resources of this module will be created.<br><br>This name must be a valid AWS region name. | `string` | `"eu-west-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module. | `map(any)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Specify the networking set of addresses for Kubernetes. Use the prefix notation.<br><br>Ref: https://www.rfc-editor.org/rfc/rfc4632#section-3.1 | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_nat_gateway_type"></a> [vpc\_nat\_gateway\_type](#input\_vpc\_nat\_gateway\_type) | Specify the type of the NAT Gateway.<br><br>Ref: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html | `string` | `"one_nat_gateway_per_az"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster"></a> [eks\_cluster](#output\_eks\_cluster) | Elastic Kubernetes Service (EKS) cluster attributes. |
| <a name="output_kubernetes_api"></a> [kubernetes\_api](#output\_kubernetes\_api) | URL, Version of the Kubernetes API and Kubernetes cluster name. |
| <a name="output_kubernetes_api_certificate_authority_data"></a> [kubernetes\_api\_certificate\_authority\_data](#output\_kubernetes\_api\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster. |
| <a name="output_kubernetes_secrets_managed_encryption_key"></a> [kubernetes\_secrets\_managed\_encryption\_key](#output\_kubernetes\_secrets\_managed\_encryption\_key) | The cluster comes with enabled by default Kubernetes secrets. This object<br>    contains the attributes related with the encryption key used by AWS. |
| <a name="output_region"></a> [region](#output\_region) | Region name of the deployment |
| <a name="output_subnet_cidr_blocks_per_type"></a> [subnet\_cidr\_blocks\_per\_type](#output\_subnet\_cidr\_blocks\_per\_type) | Allocated network prefixes grouped per purpose. |
| <a name="output_subnet_ids_per_type"></a> [subnet\_ids\_per\_type](#output\_subnet\_ids\_per\_type) | List of subnet ids per type. |
| <a name="output_tags"></a> [tags](#output\_tags) | List of tags that are applied to internal resources. |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | Id of the VPC. |
<!-- END_TF_DOCS -->