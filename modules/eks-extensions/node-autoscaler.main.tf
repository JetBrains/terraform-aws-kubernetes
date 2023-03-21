locals {
  karpenter_cluster_name            = var.eks_cluster_name
  karpenter_k8s_oidc_issuer_url     = var.kubernetes_oidc_issuer_url
  karpenter_kubernetes_api_url      = var.kubernetes_api_url
  karpenter_namespace               = "kube-node-autoscaler"
  karpenter_version                 = "v0.24.0"
  karpenter_managed_node_group_name = "ng-managed-by-karpenter"
  karpenter_manifests_name          = "default"
}

# BEGIN: IAM for Karpenter
# Role for ServiceAccount to use
module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${local.karpenter_cluster_name}"
  provider_url                  = local.karpenter_k8s_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.karpenter_namespace}:karpenter"]
}

# Based on https://karpenter.sh/docs/getting-started/cloudformation.yaml
resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter-policy-${local.karpenter_cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "pricing:GetProducts",
          "ssm:GetParameter",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node.arn
      }
    ]
  })
}

resource "aws_iam_role" "karpenter_node" {
  name = "karpenter-node-${local.karpenter_cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

## Instance profile for nodes to pull images, networking, SSM, etc
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "karpenter-node-${local.karpenter_cluster_name}"
  role = aws_iam_role.karpenter_node.name
}
# END

resource "kubectl_manifest" "karpenter_default_node_template" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: "${local.karpenter_manifests_name}"
spec:
  subnetSelector:
    karpenter.sh/discovery: "${local.karpenter_cluster_name}"
  securityGroupSelector:
    karpenter.sh/discovery: "${local.karpenter_cluster_name}"
YAML
  depends_on = [
    module.k8s_internal_services
  ]
}

resource "kubectl_manifest" "karpenter_default_provisioner" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: "${local.karpenter_manifests_name}"
spec:
  requirements:
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["spot", "on-demand"]
  - key: kubernetes.io/arch
    operator: In
    values: ["amd64", "arm64"]
  limits:
    resources:
      cpu: 1000
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 30
YAML
  depends_on = [
    module.k8s_internal_services
  ]
}



