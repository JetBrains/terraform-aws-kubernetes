/**
* This file provides details about the configuration of the EKS cluster.
*/
locals {
  # Keep in mind that in the below merge, the values of the `local.custom_eks_params` object
  # overwrite the attributes/values of the `local.default_eks_params` object.
  eks_params = merge(local.default_eks_params, local.custom_eks_params)
}

module "network" {
  source = "./modules/network"

  region               = local.region
  name                 = local.name
  environment          = local.environment
  vpc_cidr             = local.vpc_cidr
  vpc_nat_gateway_type = local.vpc_nat_gateway_type

  tags = local.tags
}

// The below datas ources refer to a workaround with an issue with the default KMS key without resource-based policy:
// associated with it. Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  # "This data source provides information on the IAM source role of an STS assumed role. For non-role ARNs, this data source simply passes the ARN through in issuer_arn."
  arn = data.aws_caller_identity.current.arn
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.1.0"

  cluster_name     = local.eks_params.cluster_name
  cluster_version  = local.eks_params.cluster_version
  cluster_timeouts = local.eks_params.cluster_timeouts
  # CLUSTER ACCESS
  cluster_endpoint_private_access      = local.eks_params.cluster_endpoint_private_access
  cluster_endpoint_public_access       = local.eks_params.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = local.eks_params.cluster_endpoint_public_access_cidrs

  # ADD-ONs
  cluster_addons = local.eks_params.cluster_addons

  # LOGGING
  create_cloudwatch_log_group            = local.eks_params.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = local.eks_params.cloudwatch_log_group_retention_in_days
  cluster_enabled_log_types              = local.eks_params.cluster_enabled_log_types

  # ENCRYPTION KEY
  create_kms_key                  = local.eks_params.kms_config.create_kms_key
  kms_key_administrators          = [data.aws_iam_session_context.current.issuer_arn]
  cluster_encryption_config       = local.eks_params.kms_config.cluster_encryption_config
  kms_key_deletion_window_in_days = local.eks_params.kms_config.kms_key_deletion_window_in_days
  enable_kms_key_rotation         = local.eks_params.kms_config.enable_kms_key_rotation

  # NETWORK
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.subnet_ids_per_type.private_nodes
  control_plane_subnet_ids = module.network.subnet_ids_per_type.isolated_resources

  # IAM ROLE FOR SERVICE ACCOUNTS.
  # Ref: https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html
  enable_irsa = local.eks_params.enable_irsa

  # EXTEND CLUSTER SECURITY GROUP RULES
  cluster_security_group_additional_rules = local.eks_params.cluster_security_group_rules

  # EXTEND NODE-TO-NODE SECURITY GROUP RULES
  node_security_group_additional_rules = local.eks_params.node_security_group_additional_rules

  # EKS MANAGED NODE GROUP(S)
  eks_managed_node_groups = local.eks_params.eks_managed_node_group

  # OIDC IDENTITY PROVIDER
  cluster_identity_providers = local.eks_params.cluster_identity_providers

  # AWS AUTHENTICATION
  #create_aws_auth_configmap = local.eks_params.manage_aws_auth_configmap
  manage_aws_auth_configmap = local.eks_params.manage_aws_auth_configmap
  aws_auth_roles = concat([for r in local.eks_params.eks_cluster_admin_iam_roles : { rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${r}", username = "${r}", groups = ["system:masters"] }],
    [{
      rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/karpenter-node-${local.eks_params.cluster_name}", username = "system:node:{{EC2PrivateDNSName}}", groups = ["system:nodes", "system:bootstrappers", "system:node-bootstrapper"]
    }]
  )
  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id
  ]
  node_security_group_tags = {
    "karpenter.sh/discovery" = "${local.eks_params.cluster_name}"
  }
  cluster_security_group_tags = {
    "karpenter.sh/discovery" = "${local.eks_params.cluster_name}"
  }
  tags = local.tags
}

