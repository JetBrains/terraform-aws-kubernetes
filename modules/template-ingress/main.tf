module "ingress" {
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts = [
    {
      namespace         = var.ingress_namespace
      repository        = var.ingress_helm_chart_repository
      repository_config = var.ingress_helm_chart_repository_config
      app = {
        name             = var.ingress_helm_chart_name
        chart            = var.ingress_helm_chart_name
        version          = var.ingress_helm_chart_version
        create_namespace = var.ingress_create_namespace_if_not_exists
      }
      values  = var.ingress_default_values_dot_yaml
      params  = var.ingress_params
      secrets = var.ingress_secrets
    }
  ]
}