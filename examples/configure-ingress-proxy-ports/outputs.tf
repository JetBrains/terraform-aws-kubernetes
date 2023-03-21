output "values" {
  value = {
    kubernetes_cluster_services = module.eks_minimal.kubernetes_cluster_services
  }
}