module "kube_grafana_loki" {
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts = [
    {
      namespace         = var.cluster_logging_namespace
      repository        = var.cluster_logging_helm_chart_repository
      repository_config = var.cluster_logging_helm_chart_repository_config
      app = {
        name             = var.cluster_logging_helm_chart_name
        chart            = var.cluster_logging_helm_chart_name
        version          = var.cluster_logging_helm_chart_version
        create_namespace = var.cluster_logging_create_namespace_if_not_exists
      }
      values  = var.cluster_logging_default_values_dot_yaml
      params  = var.cluster_logging_params
      secrets = var.cluster_logging_secrets
    }
  ]
}