locals {
  kube_node_patcher_default_values = <<VALUES
spec:
  metrics:
    create: true
    labels:
      release: kube-prometheus-stack
  service:
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/path: "/metrics"
      prometheus.io/port: "8080"
  configuration:
    startTime: "10:00"
    endTime: "17:00"
    timeZone: "Europe/Amsterdam"
    period: "30m0s"
    rebootDays: [mo,tu,we,th,fr]
    annotateNodes: true
VALUES
}

module "kube_node_patcher" {
  count                                                = var.cluster_node_patcher_create ? 1 : 0
  source                                               = "./modules/feature-node-patcher"
  cluster_node_rebooter_helm_chart_repository          = try(coalesce(var.cluster_node_patcher.helm_chart_repository, "oci://public.registry.jetbrains.space/p/helm/library"), "oci://public.registry.jetbrains.space/p/helm/library")
  cluster_node_rebooter_helm_chart_repository_config   = try(coalesce(var.cluster_node_patcher.helm_chart_repository_config, null), null)
  cluster_node_rebooter_helm_chart_version             = try(coalesce(var.cluster_node_patcher.helm_chart_version, "5.4.3"), "5.4.3")
  cluster_node_rebooter_helm_chart_name                = try(coalesce(var.cluster_node_patcher.helm_chart_name, "kube-node-reboot"), "kube-node-reboot")
  cluster_node_rebooter_namespace                      = try(coalesce(var.cluster_node_patcher.helm_chart_namespace, "kube-node-rebooter"), "kube-node-rebooter")
  cluster_node_rebooter_create_namespace_if_not_exists = try(coalesce(var.cluster_node_patcher.create_namespace_if_not_exists, true), true)
  cluster_node_rebooter_default_values_dot_yaml        = try(coalesce(var.cluster_node_patcher.helm_chart_values, local.kube_node_patcher_default_values), local.kube_node_patcher_default_values)
  cluster_node_rebooter_params                         = try(coalesce(var.cluster_node_patcher.helm_chart_params, []), [])
  cluster_node_rebooter_secrets                        = try(coalesce(var.cluster_node_patcher.helm_chart_secrets, []), [])
  depends_on = [
    module.cluster_monitoring
  ]
}