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

  value = module.network.vpc_id
}

output "vpc_arn" {
  description = <<EOF
      ARN of the VPC. 
    EOF

  value = module.network.vpc_arn
}

output "subnet_cidr_blocks_per_type" {
  description = <<EOF
    Allocated network prefixes grouped per purpose.
  EOF

  value = module.network.subnet_cidr_blocks_per_type
}

output "subnet_ids_per_type" {
  description = <<EOF
    List of subnet ids per type.
  EOF
  value       = module.network.subnet_ids_per_type
}
#######################################################
#   KUBERNETES API DETAILS
#######################################################
output "kubernetes_api" {
  description = <<EOF
    URL, Version of the Kubernetes API and Kubernetes cluster name.
  EOF
  value = {
    "url"     = module.eks.cluster_endpoint
    "version" = module.eks.cluster_version
    "id"      = module.eks.cluster_id
    "name"    = module.eks.cluster_name
    "logs" = {
      "cloudwatch_group_name" = module.eks.cloudwatch_log_group_name
      "cloudwatch_group_arn"  = module.eks.cloudwatch_log_group_arn
    }
  }
}

output "kubernetes_api_certificate_authority_data" {
  description = <<EOF
    Base64 encoded certificate data required to communicate with the cluster.
  EOF
  sensitive   = true
  value       = module.eks.cluster_certificate_authority_data
}

output "kubernetes_secrets_managed_encryption_key" {
  description = <<EOF
    The cluster comes with enabled by default Kubernetes secrets. This object
    contains the attributes related with the encryption key used by AWS.
  EOF
  sensitive   = true
  value = {
    "id"         = module.eks.kms_key_id
    "arn"        = module.eks.kms_key_arn
    "iam_policy" = module.eks.kms_key_policy
  }
}

#######################################################
#   EKS DETAILS
#######################################################
output "eks_cluster" {
  description = <<EOF
    Elastic Kubernetes Service (EKS) cluster attributes.
  EOF
  value = {
    "arn"                  = module.eks.cluster_arn
    "oidc_issuer_provider" = module.eks.cluster_oidc_issuer_url
    "platform_version"     = module.eks.cluster_platform_version
    "security_groups" = {
      "service" = module.eks.cluster_primary_security_group_id
      "cluster" = {
        "id"  = module.eks.cluster_security_group_id
        "arn" = module.eks.cluster_security_group_arn
      }
      "nodes" = {
        "id"  = module.eks.node_security_group_arn
        "arn" = module.eks.node_security_group_id
      }
    }
    "iam_role" = {
      "name" = module.eks.cluster_iam_role_name
      "arn"  = module.eks.cluster_iam_role_arn
      "id"   = module.eks.cluster_iam_role_unique_id
    }
    "irsa" = {
      "oidc_provider"                            = module.eks.oidc_provider
      "oidc_provider_arn"                        = module.eks.oidc_provider_arn
      "cluster_tls_certificate_sha1_fingerprint" = module.eks.cluster_tls_certificate_sha1_fingerprint
    }
    "addons" = module.eks.cluster_addons
    "ec2_instances" = {
      "aws_managed" = {
        "node_groups"             = try(module.eks.eks_managed_node_groups, null)
        "autoscaling_group_names" = try(module.eks.eks_managed_node_groups_autoscaling_group_names, null)
      }
    }
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
