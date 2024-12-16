module "descheduler" {
  // descheduler must be installed in the kube-system namespace
  // such that it can be treated as a system critical component and
  // avoid being evicted by the descheduler itself
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts = [
    {
      namespace         = "kube-system"
      repository        = var.descheduler_helm_chart_repository
      repository_config = var.descheduler_helm_chart_repository_config
      app = {
        name             = var.descheduler_helm_chart_name
        chart            = var.descheduler_helm_chart_name
        version          = var.descheduler_helm_chart_version
        create_namespace = false
      }
      values  = var.descheduler_default_values_dot_yaml
      params  = var.descheduler_params
      secrets = var.descheduler_secrets
    }
  ]
}