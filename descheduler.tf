locals {
  cluster_descheduler_default_values = <<VALUES
spec:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: kube-prometheus-stack
VALUES
}

module "kube_descheduler" {
  count                                    = var.cluster_descheduler_create ? 1 : 0
  source                                   = "./modules/feature-descheduler"
  descheduler_helm_chart_repository        = try(coalesce(var.cluster_descheduler.helm_chart_repository, "oci://registry.jetbrains.team/p/helm/library"), "oci://registry.jetbrains.team/p/helm/library")
  descheduler_helm_chart_repository_config = try(coalesce(var.cluster_descheduler.helm_chart_repository_config, null), null)
  descheduler_helm_chart_version           = try(coalesce(var.cluster_descheduler.helm_chart_version, "0.31.0"), "0.31.0")
  descheduler_helm_chart_name              = try(coalesce(var.cluster_descheduler.helm_chart_name, "kube-descheduler"), "kube-descheduler")
  descheduler_default_values_dot_yaml      = try(coalesce(var.cluster_descheduler.helm_chart_values, local.cluster_descheduler_default_values), local.cluster_descheduler_default_values)
  descheduler_params                       = try(coalesce(var.cluster_descheduler.helm_chart_params, []), [])
  descheduler_secrets                      = try(coalesce(var.cluster_descheduler.helm_chart_secrets, []), [])
  depends_on                               = [module.cluster_monitoring]
}
