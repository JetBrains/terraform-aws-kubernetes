output "values" {
  value = {
    kubernetes_cluster_services = module.kubernetes_cluster.kubernetes_cluster_services
  }
}