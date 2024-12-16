output "values" {
  description = "Helm charts outputs"
  value       = module.karpenter_helm_chart.*
}