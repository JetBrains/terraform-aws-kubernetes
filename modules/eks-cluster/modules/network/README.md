<!-- BEGIN_TF_DOCS -->
# terraform-aws-kubernetes

This repository contains a Terraform Module that implements an architectural blueprint for Kubernetes in AWS.
The fundamental component of this module is Elastic Kubernetes Service.

## Compatibility

Use this module with Terraform 1.3.0+ version.

## Requirements

The VPC shall allow flexible operations of the network and its resources.

The user deploying this Module shall have Full Administrator permissions in the targeted AWS account.

## Features

* The Module creates and configures a Virtual Private Cloud (VPC) IPv4 network;

* The Module offers the following:

* AWS managed Kubernetes nodes;

* Private and Public ingresses;

* IAM Roles for Service Accounts (IRSA);

* Secret encryption with AWS managed KMS key;

* Built-in security groups to protect the intra-cluster communication.

* The following Kubernetes namespaces have a clear concern:

* *kube-public-ingress*: namespace contains the Ingress Controller that watches for
Ingress objects that have the ingressClass set to public-ingress;

* *kube-private-ingress*: namespace contains the Ingress Controller that watches for
Ingress objects that have the ingressClass set to private-ingress;

* *kube-monitoring*: namespace contains the Prometheus Operator that watches for
ServiceMonitor, PodMonitor, PrometheusRule objects that have set `release:
kube-prometheus-stack` annotation.

* *kube-system*: namespace contains Kubernetes system services and additional self-managed
extensions for EKS.

## Known points of improvement

* Harden the solution for security guidelines;

* Decouple the Helm Provider and Kubernetes provider from EKS authentication and authorization details;

* Harden and improve the reliability of all internal cluster services;

* Enable end-users of this Module to customize the settings for all cluster service.

## Core concepts

* [What is EKS?](https://docs.aws.amazon.com/eks/index.html);

* [What is Kubernetes?](https://kubernetes.io/docs/home/);

* [What is a Networking Spoke?](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology);

* [What are the IAM Roles for Service Accounts, as known as IRSA?](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html);

* [How to choose the best EC2 instance type for Kubernetes workers in EKS?](https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html).

## Repository organization

* [examples](./examples): this folder contains ready to use examples that show how to use this Module;

* [tests](./test): this folder contains a list of automated tests for this Module and examples;

* [lib](./lib): this folder contains a list of local utilities, mostly Makefiles, to support the
contributor's maintenance effort of this Module;

* [modules](./modules): this folder contains a list of local Terraform modules that the Root Module uses;

* [.github](./.github): this folder contains a list of GitHub workflows to support contributions
during change requests and releases of this Module.

## Architecture

### Network organization

This section describes how the networking resources, that are created by this module, are organized at run time.

<img src="./docs/diagrams/eks-spoke.png" align="middle" alt="EKS Networking Spoke" width="80%"/>

The Module expects that the given `vpc_cidr` is generous in size to allow the creation of 4 subnet groups. Per subnet group the purpose of
each follows:

* *Public Ingress Subnet Group*: this is an Internet accessible network that will be used by Kubernetes to create ingress
objects that need to be published over the Internet;

* *Private Ingress Subnet Group*: this is a private network that will be used by Kubernetes to create ingress
objects that need to be used over the Intranet;

* *Private Nodes Subnet Group*: this is a private network that will be used by EKS service to deploy the EC2 instances.
This network does not allow direct access from the Internet. The EKS nodes can reach other services over the Internet.
It is required by the AWS managed nodes.

* *Private Isolated Subnet Group*: this is a private network. It does not allow direct access from the Internet and it does
not allow access to the Internet. This network is recommended for local, isolated and self-contained resources.

Notice that upfront planning for the available pool of networking IPs is undeniably mandatory. Avoid constrained networking scalability.
Plan for evolutionary spoke upfront and review how the EKS spoke will look like in 3 years.

### Elastic Kubernetes Service distribution model

This section describes general assumptions when this Module is used to create an EKS-like Kubernetes cluster.

<img src="./docs/diagrams/eks.png" align="middle" alt="EKS Cluster" width="80%"/>

EKS is not a global service. It must be created and hosted in a valid AWS region. Within this region,
this Module manages the network with high-availability considerations in mind.

This module employs three availability zones. The EC2 instances that are part of the Kubernetes nodes pool will be
distributed across them. Any Load Balancer created from within the Kubernetes cluster will be zone redundant as well;
this implies that this type of resource will be identified inside each availability zone by an IPv4 address.

The Kubernetes cluster is designed to include as much as feasible production-like features. This Module enables by default:

* IAM Roles for Service Accounts;

* AWS-managed encryption of the Kubernetes secrets in Etcd;

* Kubernetes API logs.

## Known issues

### Log Group is not cleaned up when the Terraform destroy operation finishes

It is a resource leak that happens in the Terraform AWS Provider during the destroy operation. This happens because
the owner of the Log Group is the EKS cluster that is destroyed before the Log Group can be removed. Ideally it should
be removed while the EKS cluster is still live but because of implicit IAM policy references this is not possible.

### KMS key for secrets encryption becomes inaccessible

Notice that in case of manual deployments and users using multiple roles within an AWS account can induce to
wrong ownership of the KMS key that is used to encrypt the Kubernetes secrets in EKS. Make sure that the deployment
user consistently uses the same role such that to avoid access denied situation on the KMS key.

### The aws_auth config map does not exist

From time to time, during the initial deployment of this module it can happen that the `aws_auth` ConfigMap object is
not created in time and the deployment fails mentioning that the ConfigMap does not exist. At the moment, this issue
is under investigation. To fix, just re-run the deployment.

## Usage guides

Refer to this [page](./docs/GUIDES.md) for details in regard to cluster services usage instructions.

## Contribution guides

Refer to this [page](./CONTRIBUTING.md) for details in regard to contribution instructions.

## Requirements

No requirements.
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_route_table_association.ingress_subnet_rt_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.ingress_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Specify the environment name.<br><br>Use this attribute to give meaning to the EKS cluster and its related resources. | `string` | `"try-out"` | no |
| <a name="input_name"></a> [name](#input\_name) | Overwrite the prefix name that is used internally to name the resources.<br><br>Use this attribute when and only when this module was already deployed in the targeted AWS account. | `string` | `"kube"` | no |
| <a name="input_region"></a> [region](#input\_region) | Specify the name of the location where the resources of this module will be created.<br><br>This name must be a valid AWS region name. | `string` | `"eu-west-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module. | `map(any)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Specify the networking set of addresses for Kubernetes. Use the prefix notation.<br><br>Ref: https://www.rfc-editor.org/rfc/rfc4632#section-3.1 | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_nat_gateway_type"></a> [vpc\_nat\_gateway\_type](#input\_vpc\_nat\_gateway\_type) | Specify the type of the NAT Gateway.<br><br>Ref: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html | `string` | `"one_nat_gateway_per_az"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_region"></a> [region](#output\_region) | Region name of the deployment |
| <a name="output_subnet_cidr_blocks_per_type"></a> [subnet\_cidr\_blocks\_per\_type](#output\_subnet\_cidr\_blocks\_per\_type) | Allocated network prefixes grouped per purpose. |
| <a name="output_subnet_ids_per_type"></a> [subnet\_ids\_per\_type](#output\_subnet\_ids\_per\_type) | List of subnet ids per type. |
| <a name="output_tags"></a> [tags](#output\_tags) | List of tags that are applied to internal resources. |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | Id of the VPC. |
<!-- END_TF_DOCS -->