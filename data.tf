
// data.aws_eks_cluster_auth.this_cluster points to the eks cluster
// that is created in the root module. This construct will block
// until the EKS cluster is ready. It is necessary to block such that
// to avoid any Kubernetes-related provider to fail to reach the Kubernetes API.
data "aws_eks_cluster_auth" "this_cluster" {
  name = module.eks.kubernetes_api.name
  depends_on = [
    time_sleep.wait_5_min_and_allow_kubernetes_cluster_to_initialise
  ]
}

data "kubernetes_service_v1" "kube_public_ingress_svc_url" {
  metadata {
    name      = "public-ingress-nginx-controller"
    namespace = "kube-public-ingress"
  }
  depends_on = [
    module.k8s_cluster_services
  ]
}

data "kubernetes_service_v1" "kube_private_ingress_svc_url" {
  metadata {
    name      = "private-ingress-nginx-controller"
    namespace = "kube-private-ingress"
  }
  depends_on = [
    module.k8s_cluster_services
  ]
}

data "kubernetes_resource" "kube_monitoring_prometheus_operator_discovery_label" {
  api_version = "monitoring.coreos.com/v1"
  kind        = "Prometheus"

  metadata {
    name      = "kube-prometheus-stack-prometheus"
    namespace = "kube-monitoring"
  }
  depends_on = [
    module.eks_monitoring
  ]
}
