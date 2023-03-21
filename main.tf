/**
* This file details how to create an EKS cluster, that can be maintained by Space Teams, and also specifies what services
* are configured as part of its initial configuration.
*/
// This module always must execute first.
module "eks" {
  source                                   = "./modules/eks-cluster"
  region                                   = local.region
  name                                     = local.name
  environment                              = local.environment
  vpc_cidr                                 = local.cidr
  vpc_nat_gateway_type                     = local.vpc_nat_gateway_type
  kubernetes_api_version                   = local.kubernetes_api_version
  kubernetes_api_allow_network_access_from = local.kubernetes_api_allow_network_access_from
  kubernetes_api_logs                      = local.kubernetes_api_logs
  kubernetes_cluster_admin_iam_roles       = local.kubernetes_cluster_admin_iam_roles
  kubernetes_cluster_worker_pools          = local.kubernetes_cluster_worker_pools
  tags                                     = local.tags
}

// This resource waits some time such that to allow all the Kubernetes nodes to be ready
resource "time_sleep" "wait_5_min_and_allow_kubernetes_cluster_to_initialise" {
  depends_on = [module.eks]

  create_duration = "300s"
}

// This module creates, updates and removes only items that are strictly related to EKS.
module "eks_extensions" {
  source                     = "./modules/eks-extensions"
  kubernetes_oidc_issuer_url = replace(module.eks.eks_cluster.oidc_issuer_provider, "https://", "")
  kubernetes_api_url         = module.eks.kubernetes_api.url
  eks_cluster_name           = local.name
  tags                       = local.tags
  depends_on = [
    time_sleep.wait_5_min_and_allow_kubernetes_cluster_to_initialise
  ]
}

// This module creates, updates and removes the tools for the centralised monitoring.
module "eks_monitoring" {
  source = "./modules/k8s-helm-packages"
  charts = local.cluster_services_monitoring
  depends_on = [
    module.eks_extensions
  ]
}

// This module creates, updates and removes the tools for the centralised logging.
module "eks_logging" {
  source = "./modules/k8s-helm-packages"
  charts = local.cluster_services_logging
  depends_on = [
    module.eks_monitoring
  ]
}

// This module creates, updates and removes the remaining set of central cluster services to support the applications.
// Example: node-reboot, ingress-controllers and etc.
// Notice that because these cluster services depends on resources exposed by the monitoring and logging services, they
// require separate deployment.
module "k8s_cluster_services" {
  source = "./modules/k8s-helm-packages"
  charts = local.cluster_services_helm_charts
  depends_on = [
    module.eks_logging
  ]
}

/*
TODO: Focus on the below issues.
Note: the issues below are detected by SNYK

https://snyk.io/security-rules/SNYK-CC-TF-107
Fixed: https://snyk.io/security-rules/SNYK-CC-TF-131
https://snyk.io/security-rules/SNYK-CC-TF-56
https://snyk.io/security-rules/SNYK-CC-TF-73
https://snyk.io/security-rules/SNYK-CC-AWS-423
https://snyk.io/security-rules/SNYK-CC-AWS-427
https://snyk.io/security-rules/SNYK-CC-TF-134
https://snyk.io/security-rules/SNYK-CC-AWS-415
https://snyk.io/security-rules/SNYK-CC-TF-11
https://snyk.io/security-rules/SNYK-CC-TF-12
*/


module "k8s_apps" {
  count  = var.kubernetes_packages_as_helm_charts != null ? 1 : 0
  source = "./modules/k8s-helm-packages"
  charts = local.kubernetes_packages_as_helm_charts
  depends_on = [
    module.k8s_cluster_services
  ]
}