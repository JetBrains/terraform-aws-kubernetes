locals {
  name = var.name

  region = var.region

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  vpc_nat_gateway_type = var.vpc_nat_gateway_type

  default_eks_params = {
    cluster_name                         = "${local.name}"
    cluster_endpoint_private_access      = true
    cluster_endpoint_public_access       = true
    cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
    cluster_version                      = "1.23"
    enable_irsa                          = true
    eks_cluster_admin_iam_roles          = []
    manage_aws_auth_configmap            = true
    cluster_identity_providers = {
      sts = {
        client_id = "sts.amazonaws.com"
      }
    }

    cluster_addons = {
      coredns = {
        resolve_conflicts = "OVERWRITE"
      }
      vpc-cni = {
        resolve_conflicts = "OVERWRITE"
      }
      kube-proxy = {}
    }
    cluster_timeouts = {
      "create" = "45m"
      "update" = "60m"
      "delete" = "30m"
    }
    kms_config = {
      create_kms_key = true
      cluster_encryption_config = {
        resources = ["secrets"]
      }
      kms_key_deletion_window_in_days = 7
      enable_kms_key_rotation         = true
    }

    cluster_security_group_rules = {
      egress_nodes_ephemeral_ports_tcp = {
        description                = "To node 1025-65535"
        protocol                   = "tcp"
        from_port                  = 1025
        to_port                    = 65535
        type                       = "egress"
        source_node_security_group = true
      }
    }

    node_security_group_additional_rules = {
      ingress_cluster_metricserver = {
        description                   = "Cluster to node 4443 (Metrics Server)"
        protocol                      = "tcp"
        from_port                     = 4443
        to_port                       = 4443
        type                          = "ingress"
        source_cluster_security_group = true
      }
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

    eks_managed_node_group = {
      blue = {
        min_size       = 3
        max_size       = 6
        desired_size   = 3
        instance_types = ["t3a.2xlarge"]
        capacity_type  = "ON_DEMAND"
        labels = {
          pool-color = "blue"
        }
        update_config = {
          max_unavailable_percentage = 50
        }
      }
    }

    create_cloudwatch_log_group            = false
    cloudwatch_log_group_retention_in_days = 14
    cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  }

  custom_eks_params = {
    cluster_endpoint_public_access_cidrs = var.kubernetes_api_allow_network_access_from
    cluster_version                      = var.kubernetes_api_version
    // DO NOT REMOVE THE KARPENTER LIST FROM THE BELOW LOCAL VARIABLE.
    // IT IS A WORKAROUND FOR ITS USER TO BE ABLE TO CONNECT AUTO SCALED NODES TO THE KUBERNETES CLUSTER.
    eks_cluster_admin_iam_roles            = var.kubernetes_cluster_admin_iam_roles
    eks_managed_node_group                 = var.kubernetes_cluster_worker_pools
    create_cloudwatch_log_group            = var.kubernetes_api_logs.create_cloudwatch_log_group
    cloudwatch_log_group_retention_in_days = var.kubernetes_api_logs.cloudwatch_log_group_retention_in_days
    cluster_enabled_log_types              = var.kubernetes_api_logs.cluster_enabled_log_types
  }

  tags = merge(var.tags, {
    environment    = local.environment
    product        = "JetbrainsSpace"
    cloud_platform = "AmazonWebServices"
  })
}