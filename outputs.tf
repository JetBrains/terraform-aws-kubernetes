#######################################################
#   AWS LOCATION DETAILS
#######################################################
output "region" {
  description = "Region name of the deployment"
  value       = local.region
}

#######################################################
#   VIRTUAL PRIVATE CLOUD (VPC) DETAILS
#######################################################
output "vpc_id" {
  description = <<EOF
      Id of the VPC. 
    EOF

  value = module.eks.vpc_id
}

output "vpc_arn" {
  description = <<EOF
      ARN of the VPC. 
    EOF

  value = module.eks.vpc_arn
}

output "subnet_cidr_blocks_per_type" {
  description = <<EOF
    Allocated network prefixes grouped per purpose.
  EOF

  value = module.eks.subnet_cidr_blocks_per_type
}

output "subnet_ids_per_type" {
  description = <<EOF
    List of subnet ids per type.
  EOF
  value       = module.eks.subnet_ids_per_type
}
#######################################################
#   KUBERNETES API DETAILS
#######################################################
output "kubernetes_api" {
  description = <<EOF
    URL, Version of the Kubernetes API and Kubernetes cluster name.
  EOF
  value       = module.eks.kubernetes_api
}

output "kubernetes_api_certificate_authority_data" {
  description = <<EOF
    Base64 encoded certificate data required to communicate with the cluster.
  EOF
  sensitive   = true
  value       = module.eks.kubernetes_api_certificate_authority_data
}

output "kubernetes_secrets_managed_encryption_key" {
  description = <<EOF
    The cluster comes with enabled by default Kubernetes secrets. This object
    contains the attributes related with the encryption key used by AWS.
  EOF
  sensitive   = true
  value       = module.eks.kubernetes_secrets_managed_encryption_key
}

#######################################################
#   EKS DETAILS
#######################################################
output "eks_cluster" {
  description = <<EOF
    Elastic Kubernetes Service (EKS) cluster attributes.
  EOF
  value       = module.eks.eks_cluster
}

#######################################################
#   HELM CHART DEPLOYMENTS FOR CLUSTER SERVICES
#######################################################
output "kubernetes_cluster_services" {
  description = <<EOF
    Details about the cluster services.
  EOF
  value = {
    private_ingress_url          = data.kubernetes_service_v1.kube_private_ingress_svc_url.status.0.load_balancer.0.ingress.0.hostname
    public_ingress_url           = data.kubernetes_service_v1.kube_public_ingress_svc_url.status.0.load_balancer.0.ingress.0.hostname
    prometheus_operator_selector = data.kubernetes_resource.kube_monitoring_prometheus_operator_discovery_label.object.spec.serviceMonitorSelector.matchLabels
  }
}

#######################################################
#   METADATA
#######################################################
output "tags" {
  description = <<EOF
    List of tags that are applied to internal resources.
  EOF
  value       = local.tags
}
