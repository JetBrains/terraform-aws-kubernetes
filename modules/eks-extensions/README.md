<!-- BEGIN_TF_DOCS -->
# eks-extensions

Manages the installation and configuration of EKS extensions as self-managed components.

## Compatibility

Use this module with Terraform 1.3.0+ version and EKS on AWS Cloud.

## Requirements

This module depends on an existent EKS cluster and configured providers to interact with it.

## Features

* Configures the Kubernetes storage sub-system;

* Configures the Kubernetes node autoscaler.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.33.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.7.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.14.0 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.33.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.14.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.14.0 |
## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ebs_controller_encryption_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.karpenter_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.karpenter_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [kubectl_manifest.karpenter_default_node_template](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.karpenter_default_provisioner](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.volumesnapshotclasses](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.volumesnapshotcontents](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubectl_manifest.volumesnapshots](https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0/docs/resources/manifest) | resource |
| [kubernetes_service_account_v1.ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_kubernetes_api_url"></a> [kubernetes\_api\_url](#input\_kubernetes\_api\_url) | Specify the URL of the Kubernetes API | `string` | n/a | yes |
| <a name="input_kubernetes_oidc_issuer_url"></a> [kubernetes\_oidc\_issuer\_url](#input\_kubernetes\_oidc\_issuer\_url) | Specify the Open ID Connect URL of the Kubernetes cluster for which the EBS CSI controller must be configured. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Specify a list of tags as key/value pairs. These tags will be applied to all resources created by this module. | `map(any)` | `{}` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_extensions_details"></a> [eks\_extensions\_details](#output\_eks\_extensions\_details) | Object with relevant extensions' configuration details. |
<!-- END_TF_DOCS -->