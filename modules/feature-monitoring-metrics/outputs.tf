output "values" {
  description = "Cluster monitoring outputs"
  value       = module.kube_prometheus_operator.*
}