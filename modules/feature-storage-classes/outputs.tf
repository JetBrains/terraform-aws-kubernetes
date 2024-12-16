output "cluster_storage_classes" {
  description = "Cluster storage classes of the Kubernetes cluster"
  value = {
    default    = try(coalesce(kubernetes_storage_class_v1.default.*, null), null)
    additional = try(coalesce(kubernetes_storage_class_v1.custom.*, null), null)
  }
}