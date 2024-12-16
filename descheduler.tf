module "kube_descheduler" {
  count                                    = var.cluster_descheduler_create ? 1 : 0
  source                                   = "../../../JetBrains/Terraform/terraform-aws-kubernetes/modules/feature-descheduler"
  descheduler_helm_chart_repository        = try(coalesce(var.cluster_descheduler.helm_chart_repository, "oci://public.registry.jetbrains.space/p/helm/library"), "oci://public.registry.jetbrains.space/p/helm/library")
  descheduler_helm_chart_repository_config = try(coalesce(var.cluster_descheduler.helm_chart_repository_config, null), null)
  descheduler_helm_chart_version           = try(coalesce(var.cluster_descheduler.helm_chart_version, "0.29.0"), "0.29.0")
  descheduler_helm_chart_name              = try(coalesce(var.cluster_descheduler.helm_chart_name, "kube-descheduler"), "kube-descheduler")
  descheduler_default_values_dot_yaml      = try(coalesce(var.cluster_descheduler.helm_chart_values, null), null)
  descheduler_params                       = try(coalesce(var.cluster_descheduler.helm_chart_params, []), [])
  descheduler_secrets                      = try(coalesce(var.cluster_descheduler.helm_chart_secrets, []), [])
  depends_on                               = [module.cluster_monitoring]
}