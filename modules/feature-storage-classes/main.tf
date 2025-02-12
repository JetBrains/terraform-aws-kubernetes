resource "kubernetes_storage_class_v1" "default" {
  for_each = var.cluster_default_storage_storage_classes
  metadata {
    name        = try(coalesce(each.value.name, "default"), "default")
    annotations = try(coalesce(each.value.annotations, {}), {})
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = try(coalesce(each.value.reclaim_policy, "Retain"), "Retain")
  volume_binding_mode    = try(coalesce(each.value.volume_binding_mode, "WaitForFirstConsumer"), "WaitForFirstConsumer")
  allow_volume_expansion = try(coalesce(each.value.allow_volume_expansion, true), true)
  parameters             = try(coalesce(each.value.parameters, {}), {})
}