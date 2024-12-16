module "kube_prometheus_operator" {
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts = [
    {
      namespace         = var.cluster_monitoring_namespace
      repository        = var.cluster_monitoring_helm_chart_repository
      repository_config = var.cluster_monitoring_helm_chart_repository_config
      app = {
        name             = var.cluster_monitoring_helm_chart_name
        chart            = var.cluster_monitoring_helm_chart_name
        version          = var.cluster_monitoring_helm_chart_version
        create_namespace = var.cluster_monitoring_create_namespace_if_not_exists
      }
      values  = var.cluster_monitoring_default_values_dot_yaml
      params  = var.cluster_monitoring_params
      secrets = var.cluster_monitoring_secrets
    }
  ]
}