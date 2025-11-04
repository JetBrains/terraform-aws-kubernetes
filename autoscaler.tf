module "node_autoscaler_required_aws_resources" {
  source                            = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                           = "20.34.0"
  create                            = var.cluster_autoscaler_create
  access_entry_type                 = "EC2_LINUX"
  ami_id_ssm_parameter_arns         = []
  cluster_ip_family                 = "ipv4"
  cluster_name                      = module.kubernetes.cluster_name
  create_access_entry               = false
  create_iam_role                   = true
  create_instance_profile           = false
  create_node_iam_role              = false
  enable_irsa                       = true
  enable_pod_identity               = true
  enable_spot_termination           = true
  iam_policy_description            = "Karpenter controller IAM policy for ${var.prefix} Kubernetes cluster"
  iam_policy_path                   = "/eks/cluster/${var.prefix}/"
  iam_policy_use_name_prefix        = true
  iam_role_description              = "Karpenter controller IAM role for ${var.prefix} Kubernetes cluster"
  iam_role_max_session_duration     = null
  iam_role_name                     = "EKS${upper(var.prefix)}KarpenterController"
  iam_role_path                     = "/eks/cluster/${var.prefix}/"
  iam_role_permissions_boundary_arn = null
  iam_role_policies                 = {}
  iam_role_tags                     = {}
  iam_role_use_name_prefix          = false
  irsa_assume_role_condition_test   = "StringEquals"
  irsa_namespace_service_accounts   = ["kube-node-autoscaler:karpenter"]
  irsa_oidc_provider_arn            = module.kubernetes.oidc_provider_arn
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  node_iam_role_arn                       = module.kubernetes.eks_managed_node_groups["main"].iam_role_arn
  node_iam_role_attach_cni_policy         = true
  node_iam_role_description               = null
  node_iam_role_max_session_duration      = null
  node_iam_role_path                      = "/eks/cluster/${var.prefix}/"
  node_iam_role_permissions_boundary      = null
  node_iam_role_tags                      = {}
  node_iam_role_use_name_prefix           = true
  queue_kms_data_key_reuse_period_seconds = null
  queue_kms_master_key_id                 = null
  queue_managed_sse_enabled               = true
  queue_name                              = null
  rule_name_prefix                        = "Karpenter"
  tags                                    = var.tags
}

module "kube_node_autoscaler" {
  count                        = var.cluster_autoscaler_create ? 1 : 0
  source                       = "./modules/feature-node-autoscaler"
  helm_chart_repository        = try(coalesce(var.cluster_autoscaler.helm_chart_repository, "oci://public.registry.jetbrains.space/p/helm/library"), "oci://public.registry.jetbrains.space/p/helm/library")
  helm_chart_name              = try(coalesce(var.cluster_autoscaler.helm_chart_name, "kube-karpenter"), "kube-karpenter")
  helm_chart_version           = try(coalesce(var.cluster_autoscaler.helm_chart_version, "0.35.1"), "0.35.1")
  helm_chart_repository_config = try(coalesce(var.cluster_autoscaler.helm_chart_repository_config, null), null)
  helm_chart_values            = try(coalesce(var.cluster_autoscaler.helm_chart_values, null), null)
  helm_chart_params = concat(var.cluster_autoscaler.helm_chart_params, [{
    name  = "spec.serviceMonitor.enabled"
    value = "true"
  }])
  helm_chart_secrets           = var.cluster_autoscaler.helm_chart_secrets
  kubernetes_cluster_name      = module.kubernetes.cluster_name
  kubernetes_cluster_endpoint  = module.kubernetes.cluster_endpoint
  kubernetes_cluster_ca_bundle = module.kubernetes.cluster_certificate_authority_data
  aws_iam_role_arn             = module.node_autoscaler_required_aws_resources.iam_role_arn
  aws_interruption_queue       = module.node_autoscaler_required_aws_resources.queue_name
  depends_on = [
    module.cluster_monitoring,
    module.node_autoscaler_required_aws_resources
  ]
}


resource "kubectl_manifest" "default_ec2_node_class" {
  depends_on = [module.kube_node_autoscaler]
  count      = var.cluster_autoscaler_create ? 1 : 0
  yaml_body  = <<YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
spec:
    amiFamily: AL2
    role: "${module.kubernetes.eks_managed_node_groups["main"].iam_role_name}"
    subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${coalesce(var.cluster_autoscaler_subnet_selector, module.kubernetes.cluster_name)}"
    securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${module.kubernetes.cluster_name}"
    tags:
        Name: "${module.kubernetes.cluster_name}-node"
        karpenter.sh/discovery: "${module.kubernetes.cluster_name}"
    userData:
        #!/bin/bash
        sudo systemctl enable amazon-ssm-agent || true
        sudo systemctl start amazon-ssm-agent || true
    blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 100Gi
        volumeType: gp3
        iops: 10000
YAML
}

resource "kubectl_manifest" "default_node_pool" {
  count      = var.cluster_autoscaler_create ? 1 : 0
  depends_on = [module.kube_node_autoscaler]
  yaml_body  = <<YAML
apiVersion: "karpenter.sh/v1beta1"
kind: NodePool
metadata:
  name: "default"
spec:
    template:
        spec:
          nodeClassRef:
              apiVersion: karpenter.k8s.aws/v1beta1
              kind: EC2NodeClass
              name: default
          requirements:
              - key: instance-storage
                operator: In
                values:
                  - 100Gi
                  - 200Gi
              - key: capacity-type
                operator: In
                values:
                  - spot
                  - on-demand
          kubelet:
              maxPods: 25
    disruption:
        consolidationPolicy: WhenUnderutilized
    limits:
        cpu: "2000"
        memory: "2000Gi"
    weight: 10
YAML
}
