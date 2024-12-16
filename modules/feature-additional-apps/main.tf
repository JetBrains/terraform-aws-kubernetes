module "apps" {
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts  = var.apps
}