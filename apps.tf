module "additional_apps" {
  count  = var.cluster_additional_apps_create ? 1 : 0
  source = "../../../JetBrains/Terraform/terraform-aws-kubernetes/modules/feature-additional-apps"
  apps   = var.cluster_additional_apps
}