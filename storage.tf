module "cluster_storage_classes" {
  count                                   = var.cluster_storage_classes_create ? 1 : 0
  source                                  = "./modules/feature-storage-classes"
  cluster_default_storage_storage_classes = var.cluster_default_storage_storage_classes
  cluster_custom_storage_classes          = var.cluster_custom_storage_classes
  depends_on = [
    aws_eks_addon.ebs_csi_driver,
    aws_eks_addon.efs_csi_driver
  ]
}