<!-- BEGIN_TF_DOCS -->
# k8s-helm-packages

This repository contains a Terraform Module that implements a procedure to handle repeatable releases of Helm Charts
in a Kubernetes cluster.

This Module is an utility adapter on top of the `helm_release` resource.

## Compatibility

Use this module with the Terraform 1.3.0+ version and EKS on AWS Cloud.

## Requirements

This Module requires that AWS CLI is available along the Terraform binary. It is necessary because
the Module configures the Helm provider to overcome the short time to live of the session tokens for the
interaction with the Kubernetes API server.

## Features

* Allows installing a list of Helm Charts;

* Allows injecting custom values.yaml configurations that will override the default chart's configurations;

* Allows injecting only a few parameters that will override the default chart's configuration;

* Allows injecting secrets in a secure manner;

## Core concepts

* [What is EKS?](https://docs.aws.amazon.com/eks/index.html);

* [What is Kubernetes?](https://kubernetes.io/docs/home/);

* [What is the Helm Provider for Kubernetes](https://registry.terraform.io/providers/hashicorp/helm/latest/docs);

* [How is configured the Helm Provider in this Module](https://registry.terraform.io/providers/hashicorp/helm/latest/docs#exec-plugins).

## Example usage

```
module "k8s_cluster_services" {
source = "${SPECIFY_HERE_THE_LOCATION_WHERE_THE_MODULE_IS_HOSTED}"
kubernetes_cluster = {
url                                      = module.eks.cluster_endpoint
name                                     = module.eks.cluster_id
certificate_authority_base64encoded_data = module.eks.cluster_certificate_authority_data
}
charts = [
{
namespace  = "kube-monitoring"
repository = "https://prometheus-community.github.io/helm-charts"
app = {
name             = "kube-prometheus-stack"
chart            = "kube-prometheus-stack"
version          = "41.7.3"
force_update     = true
create_namespace = true
}
}
]
```

In the example above, we assume:

* The EKS cluster is created by a module in the same context as the code block;

* The developer outlines the details of the Kubernetes API with the `kubernetes_cluster` input object;

* The developer wants to deploy the Prometheus Operator chart with the default configurations.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.33.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.7.0 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | = 2.7.0 |
## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/2.7.0/docs/resources/release) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_charts"></a> [charts](#input\_charts) | List of Helm Charts to deploy in the Kubernetes cluster. | <pre>list(object({<br>    namespace  = string<br>    repository = string<br>    repository_config = optional(object({<br>      repository_key_file  = optional(string)<br>      repository_cert_file = optional(string)<br>      repository_ca_file   = optional(string)<br>      repository_username  = optional(string)<br>      repository_password  = optional(string)<br>    }))<br>    app = object({<br>      name                       = string<br>      chart                      = string<br>      version                    = string<br>      force_update               = optional(bool)<br>      wait                       = optional(bool)<br>      recreate_pods              = optional(bool)<br>      max_history                = optional(number)<br>      lint                       = optional(bool)<br>      cleanup_on_fail            = optional(bool)<br>      create_namespace           = optional(bool)<br>      disable_webhooks           = optional(bool)<br>      verify                     = optional(bool)<br>      reuse_values               = optional(bool)<br>      reset_values               = optional(bool)<br>      atomic                     = optional(bool)<br>      skip_crds                  = optional(bool)<br>      render_subchart_notes      = optional(bool)<br>      disable_openapi_validation = optional(bool)<br>      wait_for_jobs              = optional(bool)<br>      dependency_update          = optional(bool)<br>      replace                    = optional(bool)<br>    })<br>    values = optional(any)<br>    params = optional(list(object({<br>      name  = string<br>      value = any<br>    })))<br>    secrets = optional(list(object({<br>      name  = string<br>      value = any<br>    })))<br>  }))</pre> | `null` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_charts_info"></a> [charts\_info](#output\_charts\_info) | List of charts and configurations that are deployed in the cluster. |
<!-- END_TF_DOCS -->