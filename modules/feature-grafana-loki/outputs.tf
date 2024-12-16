output "values" {
  description = "Cluster logging service outputs"
  value       = module.kube_grafana_loki.*
}