locals {
  // AWS-specific location details
  region = var.region

  // Environment details
  name        = var.name != null ? var.name : "kube"
  environment = var.environment != null ? var.environment : "k8s-prd"

  // Networking high level details
  cidr                 = var.vpc_cidr
  vpc_nat_gateway_type = var.vpc_nat_gateway_type
  // Elastic Kubernetes Service details
  kubernetes_api_version                   = var.kubernetes_api_version
  kubernetes_api_allow_network_access_from = var.kubernetes_api_allow_network_access_from
  kubernetes_api_logs                      = var.kubernetes_api_logs
  kubernetes_cluster_admin_iam_roles       = var.kubernetes_cluster_admin_iam_roles
  kubernetes_cluster_worker_pools          = var.kubernetes_cluster_worker_pools
  // Applications configuration and deployment
  kubernetes_packages_as_helm_charts = var.kubernetes_packages_as_helm_charts
  /*
  * Global labels
  * The tags MUST be unique. This is the main need for using the `distinct` built-in Terraform function.
  * Notice that operations over lists are optimized and to benefit from such optimization
  * the data type of the local variable tags gets converted. tolist([tomap(values)]) is a necessary
  * evil.
  */
  #  tags = distinct(
  #    tolist([
  #      tomap(
  #        merge(var.tags, {
  #          product        = "Space On-Premises",
  #          cloud_platform = "AmazonWebServices"
  #        })
  #      )
  #  ]))
  tags = merge(var.tags, {
    product        = "JetbrainsSpace"
    cloud_platform = "AmazonWebServices"
  })
}
