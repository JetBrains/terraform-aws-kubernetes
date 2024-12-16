module "kube_node_rebooter" {
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts = [
    {
      namespace         = var.cluster_node_rebooter_namespace
      repository        = var.cluster_node_rebooter_helm_chart_repository
      repository_config = var.cluster_node_rebooter_helm_chart_repository_config
      app = {
        name             = var.cluster_node_rebooter_helm_chart_name
        chart            = var.cluster_node_rebooter_helm_chart_name
        version          = var.cluster_node_rebooter_helm_chart_version
        create_namespace = var.cluster_node_rebooter_create_namespace_if_not_exists
      }
      values  = var.cluster_node_rebooter_default_values_dot_yaml
      params  = var.cluster_node_rebooter_params
      secrets = var.cluster_node_rebooter_secrets
    }
  ]
}