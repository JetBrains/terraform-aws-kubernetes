
locals {
  default_cluster_security_group_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  default_node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

module "kubernetes" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  create = try(coalesce(var.cluster_enabled, true), true)
  tags = try(merge(coalesce(var.tags, {}), {
    "karpenter.sh/discovery" = var.prefix
  }), {})
  prefix_separator                      = "-"
  cluster_name                          = var.prefix
  cluster_version                       = try(coalesce(var.cluster_version, "1.29"), "1.29")
  cluster_enabled_log_types             = try(coalesce(var.cluster_cloudwatch_logging.log_types, ["audit", "api", "authenticator"]), ["audit", "api", "authenticator"])
  authentication_mode                   = try(coalesce(var.cluster_authentication_mode, "API_AND_CONFIG_MAP"), "API_AND_CONFIG_MAP")
  cluster_additional_security_group_ids = try(coalesce(var.cluster_vpc_config.additional_security_group_ids, []), [])
  vpc_id                                = try(coalesce(var.cluster_network_external_vpc_id, module.internal_network.vpc_id, null), null)
  control_plane_subnet_ids              = try(coalesce(var.cluster_network_external_control_plane_subnet_ids, null), module.internal_network.intra_subnets, [])
  subnet_ids                            = try(coalesce(var.cluster_network_external_node_subnet_ids, null), module.internal_network.private_subnets, [])
  cluster_endpoint_private_access       = try(coalesce(var.cluster_vpc_config.expose_api_access_on_intranet, true), true)
  cluster_endpoint_public_access        = try(coalesce(var.cluster_vpc_config.expose_api_access_on_internet, true), true)
  cluster_endpoint_public_access_cidrs  = try(coalesce(var.cluster_vpc_config.accept_api_requests_from_cidr_blocks, ["0.0.0.0/0"]), ["0.0.0.0/0"])
  cluster_ip_family                     = try(coalesce(var.cluster_service_network_config.ip_family, "ipv4"), "ipv4")
  cluster_service_ipv4_cidr             = try(coalesce(var.cluster_service_network_config.service_ipv4_cidr, null), null)
  cluster_service_ipv6_cidr             = try(coalesce(var.cluster_service_network_config.service_ipv6_cidr, null), null)
  outpost_config                        = {}
  cluster_encryption_config = try(coalesce(var.cluster_database_encryption_config, {
    provider_key_arn = null
    resources        = ["secrets"]
    }), {
    provider_key_arn = null
    resources        = ["secrets"]
  })
  attach_cluster_encryption_policy           = try(coalesce(var.cluster_encryption_policy.attach_default, true), true)
  cluster_tags                               = try(coalesce(var.cluster_tags, {}), {})
  create_cluster_primary_security_group_tags = try(coalesce(var.cluster_security_group.create_primary_security_group_tags, true), true)
  cluster_timeouts                           = try(coalesce(var.cluster_timeouts, {}), {})
  access_entries = try(coalesce(var.cluster_access_management.list, {
    # The below code block is a default access management configuration that relies fully on the new API for access entries and access policies.
    # It is necessary for deploying Kubernetes resources with the Kubernetes and Helm provider.
    aws_account_admins = {
      principal_arn = data.aws_iam_role.current.arn
      policy_associations = {
        cluster_admins = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }
  }))
  enable_cluster_creator_admin_permissions     = try(coalesce(var.cluster_access_management.enable_cluster_creator_admin_permissions, false), false)
  create_kms_key                               = try(coalesce(var.cluster_kms.enabled, true), true)
  kms_key_description                          = try(coalesce(var.cluster_kms.key_description, null), null)
  kms_key_deletion_window_in_days              = try(coalesce(var.cluster_kms.key_deletion_window_in_days, 30), 30)
  enable_kms_key_rotation                      = try(coalesce(var.cluster_kms.enable_key_rotation, true), true)
  kms_key_enable_default_policy                = try(coalesce(var.cluster_kms.key_enable_default_policy, true), true)
  kms_key_owners                               = try(coalesce(var.cluster_kms.key_owners, []), [])
  kms_key_administrators                       = try(coalesce(var.cluster_kms.key_administrators, []), [])
  kms_key_users                                = try(coalesce(var.cluster_kms.key_users, []), [])
  kms_key_service_users                        = try(coalesce(var.cluster_kms.key_service_users, []), [])
  kms_key_source_policy_documents              = try(coalesce(var.cluster_kms.key_source_policy_documents, []), [])
  kms_key_override_policy_documents            = try(coalesce(var.cluster_kms.key_override_policy_documents, []), [])
  kms_key_aliases                              = try(coalesce(var.cluster_kms.key_aliases, []), [])
  create_cloudwatch_log_group                  = try(coalesce(var.cluster_cloudwatch_logging.enabled, true), true)
  cloudwatch_log_group_retention_in_days       = try(coalesce(var.cluster_cloudwatch_logging.log_group_retention_in_days, 14), 14)
  cloudwatch_log_group_kms_key_id              = try(coalesce(var.cluster_cloudwatch_logging.log_group_kms_key_id, null), null)
  cloudwatch_log_group_class                   = try(coalesce(var.cluster_cloudwatch_logging.log_group_class, null), null)
  cloudwatch_log_group_tags                    = try(coalesce(var.cluster_cloudwatch_logging.log_group_tags, {}), {})
  create_cluster_security_group                = try(coalesce(var.cluster_security_group.create_default, true), true)
  cluster_security_group_id                    = try(coalesce(var.cluster_security_group.id, null), null)
  cluster_security_group_name                  = try(coalesce(var.cluster_security_group.name, null), null)
  cluster_security_group_use_name_prefix       = try(coalesce(var.cluster_security_group.use_name_prefix, true), true)
  cluster_security_group_description           = try(coalesce(var.cluster_security_group.description, "EKS cluster shared security group"), "EKS cluster shared security group")
  cluster_security_group_additional_rules      = try(merge(coalesce(var.cluster_security_group.additional_rules, {}), local.default_cluster_security_group_rules), {})
  cluster_security_group_tags                  = try(coalesce(var.cluster_security_group.tags, {}), {})
  create_cni_ipv6_iam_policy                   = try(coalesce(var.cluster_node_security_group.create_cni_ipv6_iam_policy, false), false)
  create_node_security_group                   = try(coalesce(var.cluster_node_security_group.create_default, true), true)
  node_security_group_id                       = try(coalesce(var.cluster_node_security_group.id, ""), "")
  node_security_group_name                     = try(coalesce(var.cluster_node_security_group.name, null), null)
  node_security_group_use_name_prefix          = try(coalesce(var.cluster_node_security_group.use_name_prefix, true), true)
  node_security_group_description              = try(coalesce(var.cluster_node_security_group.description, "EKS node security group"), "EKS node security group")
  node_security_group_additional_rules         = try(merge(coalesce(var.cluster_node_security_group.additional_rules, {}), local.default_node_security_group_additional_rules), {})
  node_security_group_enable_recommended_rules = try(coalesce(var.cluster_node_security_group.enable_recommended_rules, true), true)
  node_security_group_tags = try(merge(coalesce(var.cluster_node_security_group.tags, {}), {
    "karpenter.sh/discovery" = var.prefix
  }), {})
  enable_efa_support                        = try(coalesce(var.cluster_node_security_group.enable_efa_support, false), false)
  enable_irsa                               = try(coalesce(var.cluster_iam_role_for_service_account.enabled, true), true)
  openid_connect_audiences                  = try(coalesce(var.cluster_iam_role_for_service_account.openid_connect_audiences, []), [])
  include_oidc_root_ca_thumbprint           = try(coalesce(var.cluster_iam_role_for_service_account.include_oidc_root_ca_thumbprint, true), true)
  custom_oidc_thumbprints                   = try(coalesce(var.cluster_iam_role_for_service_account.custom_oidc_thumbprints, []), [])
  create_iam_role                           = try(coalesce(var.cluster_iam.create_default_role, true), true)
  iam_role_arn                              = try(coalesce(var.cluster_iam.role_arn, null), null)
  iam_role_name                             = try(coalesce(var.cluster_iam.role_name, null), null)
  iam_role_use_name_prefix                  = try(coalesce(var.cluster_iam.role_use_name_prefix, true), true)
  iam_role_path                             = try(coalesce(var.cluster_iam.role_path, null), null)
  iam_role_description                      = try(coalesce(var.cluster_iam.role_description, null), null)
  iam_role_permissions_boundary             = try(coalesce(var.cluster_iam.role_permissions_boundary, null), null)
  iam_role_additional_policies              = try(coalesce(var.cluster_iam.role_additional_policies, {}), {})
  iam_role_tags                             = try(coalesce(var.cluster_iam.role_tags, {}), {})
  cluster_encryption_policy_use_name_prefix = try(coalesce(var.cluster_encryption_policy.use_name_prefix, true), true)
  cluster_encryption_policy_name            = try(coalesce(var.cluster_encryption_policy.name, null), null)
  cluster_encryption_policy_description     = try(coalesce(var.cluster_encryption_policy.description, null), null)
  cluster_encryption_policy_path            = try(coalesce(var.cluster_encryption_policy.path, null), null)
  cluster_encryption_policy_tags            = try(coalesce(var.cluster_encryption_policy.tags, {}), {})
  dataplane_wait_duration                   = "30s"
  cluster_addons                            = try(merge(var.cluster_addons_default, coalesce(var.cluster_addons_additional, null)), {})
  cluster_addons_timeouts                   = try(coalesce(var.cluster_addons_timeouts, {}), {})
  cluster_identity_providers                = try(coalesce(var.cluster_additional_identity_providers, {}), {})
  fargate_profiles                          = try(coalesce(var.cluster_compute_pool_fargate.groups, {}), {})
  fargate_profile_defaults                  = try(coalesce(var.cluster_compute_pool_fargate.defaults, {}), {})
  self_managed_node_groups                  = try(coalesce(var.cluster_compute_pool_self_managed.defaults, {}), {})
  self_managed_node_group_defaults          = try(coalesce(var.cluster_compute_pool_self_managed.groups, {}), {})
  eks_managed_node_groups                   = try(coalesce(var.cluster_compute_pool_aws_managed.groups, {}), {})
  eks_managed_node_group_defaults           = try(coalesce(var.cluster_compute_pool_aws_managed.defaults, {}), {})
}

