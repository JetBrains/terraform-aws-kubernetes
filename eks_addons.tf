
module "kubernetes_ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "6.2.3"
  role_name             = "${var.prefix}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = module.kubernetes.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "kubernetes_efs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "6.2.3"
  role_name             = "${var.prefix}-efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = module.kubernetes.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = module.kubernetes.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = module.kubernetes_ebs_csi_irsa_role.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = local.tags
  tags_all                    = local.tags
  depends_on = [
    module.kubernetes.fargate_profiles,
    module.kubernetes.eks_managed_node_groups,
    module.kubernetes.self_managed_node_groups
  ]
}

resource "aws_eks_addon" "efs_csi_driver" {
  cluster_name                = module.kubernetes.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  service_account_role_arn    = module.kubernetes_efs_csi_irsa_role.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = local.tags
  tags_all                    = local.tags
  depends_on = [
    module.kubernetes.fargate_profiles,
    module.kubernetes.eks_managed_node_groups,
    module.kubernetes.self_managed_node_groups
  ]
}

/*
FUTURE IMPROVEMENTS TO EXPLORE:

Terraform does not like dynamic values when passing to an input that manipulates values with
the for_each construct. Example of error log:
│ Error: Invalid for_each argument
│
│ on .terraform/modules/kubernetes/main.tf line 485, in data "aws_eks_addon_version" "this":
│ 485: for_each = { for k, v in var.cluster_addons : k => v if local.create && !local.create_outposts_local_cluster }
│ ├────────────────
│ │ local.create is true
│ │ local.create_outposts_local_cluster is false
│ │ var.cluster_addons will be known only after apply
│
│ The "for_each" map includes keys derived from resource attributes that cannot be determined until apply, and so Terraform cannot determine the full set of keys that will identify the instances of this resource.
│
│ When working with unknown values in for_each, it's better to define the map keys statically in your configuration and place apply-time results only in the map values.
│
│ Alternatively, you could use the -target planning option to first apply only the resources that the for_each value depends on, and then apply a second time to fully converge.


In case of addons, it is not possible anyhow to transform an input and pass it down to the module.kubernetes to create and configure the necessary addons.

This motivated to detach the storage drivers as standalone resources. It is necessary to investigate how to fit Terraform expectations, allow dynamic properties and
integrate the storage drivers to follow the same injection principle as the rest of the addons (through the var.cluster_defaults and var.cluster_addons or custom addons variable).
*/


