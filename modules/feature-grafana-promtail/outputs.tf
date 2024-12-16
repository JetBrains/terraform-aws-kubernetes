output "values" {
  description = "Cluster logging collecting service outputs"
  value       = module.kube_grafana_promtail.*
}