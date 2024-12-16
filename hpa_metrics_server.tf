module "kube_metrics_server" {
  count                                                 = var.cluster_metrics_server_create ? 1 : 0
  source                                                = "./modules/feature-metrics-server"
  cluster_metrics_server_helm_chart_repository          = try(coalesce(var.cluster_metrics_server.helm_chart_repository, "oci://public.registry.jetbrains.space/p/helm/library"), "oci://public.registry.jetbrains.space/p/helm/library")
  cluster_metrics_server_helm_chart_repository_config   = try(coalesce(var.cluster_metrics_server.helm_chart_repository_config, null), null)
  cluster_metrics_server_helm_chart_version             = try(coalesce(var.cluster_metrics_server.helm_chart_version, "3.12.0"), "3.12.0")
  cluster_metrics_server_helm_chart_name                = try(coalesce(var.cluster_metrics_server.helm_chart_name, "kube-metrics-server"), "kube-metrics-server")
  cluster_metrics_server_namespace                      = try(coalesce(var.cluster_metrics_server.helm_chart_namespace, "kube-monitoring"), "kube-monitoring")
  cluster_metrics_server_create_namespace_if_not_exists = try(coalesce(var.cluster_metrics_server.create_namespace_if_not_exists, true), true)
  cluster_metrics_server_default_values_dot_yaml        = try(coalesce(var.cluster_metrics_server.helm_chart_values, null), null)
  cluster_metrics_server_params                         = try(coalesce(var.cluster_metrics_server.helm_chart_params, []), [])
  cluster_metrics_server_secrets                        = try(coalesce(var.cluster_metrics_server.helm_chart_secrets, []), [])
  depends_on = [
    module.cluster_monitoring
  ]
}