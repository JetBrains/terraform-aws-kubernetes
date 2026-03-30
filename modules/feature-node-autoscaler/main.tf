locals {
  karpenter_default_values_dot_yaml = <<VALUES
spec:
  serviceAccount:
    # -- Specifies if a ServiceAccount should be created.
    create: true
    # -- The name of the ServiceAccount to use.
    # If not set and create is true, a name is generated using the fullname template.
    name: "karpenter"
    # -- Additional annotations for the ServiceAccount.
    annotations:
        eks.amazonaws.com/role-arn: "${var.aws_iam_role_arn}"
  controller:
    env: []
    resources:
      requests:
        cpu: 2
        memory: 2Gi
      limits:
        cpu: 2
        memory: 2Gi
  # -- Global Settings to configure Karpenter
  settings:
    # -- The maximum length of a batch window. The longer this is, the more pods we can consider for provisioning at one
    # time which usually results in fewer but larger nodes.
    batchMaxDuration: 10s
    # -- The maximum amount of time with no new ending pods that if exceeded ends the current batching window. If pods arrive
    # faster than this time, the batching window will be extended up to the maxDuration. If they arrive slower, the pods
    # will be batched separately.
    batchIdleDuration: 1s
    # -- How the Karpenter scheduler should treat preferences. Preferences include preferredDuringSchedulingIgnoreDuringExecution
    # node and pod affinities/anti-affinities and ScheduleAnyways topologySpreadConstraints. Can be one of 'Ignore' and 'Respect'
    preferencePolicy: Respect
    # -- How the Karpenter scheduler treats min values. Options include 'Strict' (fails scheduling when min values can't be met) and 'BestEffort' (relaxes min values when they can't be met).
    minValuesPolicy: Strict
    # -- Cluster CA bundle for TLS configuration of provisioned nodes. If not set, this is taken from the controller's TLS configuration for the API server.
    clusterCABundle: "${var.kubernetes_cluster_ca_bundle}"
    # -- Cluster name.
    clusterName: "${var.kubernetes_cluster_name}"
    # -- Cluster endpoint. If not set, will be discovered during startup (EKS only)
    clusterEndpoint: "${var.kubernetes_cluster_endpoint}"
    # -- If true then assume we can't reach AWS services which don't have a VPC endpoint.
    # This also has the effect of disabling look-ups to the AWS pricing endpoint.
    isolatedVPC: false
    # -- Marking this true means that your cluster is running with an EKS control plane and Karpenter should attempt to discover cluster details from the DescribeCluster API.
    eksControlPlane: false
    # -- The VM memory overhead as a percent that will be subtracted from the total memory for all instance types. The value of `0.075` equals to 7.5%.
    vmMemoryOverheadPercent: 0.075
    # -- Interruption queue is the name of the SQS queue used for processing interruption events from EC2.
    # Maps to the controller --interruption-queue flag. Empty disables interruption handling.
    interruptionQueue: "${var.aws_interruption_queue}"
    # -- Reserved ENIs are not included in the calculations for max-pods or kube-reserved.
    # This is most often used in the VPC CNI custom networking setup https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html.
    reservedENIs: "0"
    # -- Ignore pods' DRA requests during scheduling simulations.
    ignoreDRARequests: true
    # -- Disable cluster state metrics and events.
    disableClusterStateObservability: false
    # -- Disable dry run validation for EC2NodeClasses.
    disableDryRun: false
    # -- Feature Gate configuration values. Feature Gates will follow the same graduation process and requirements as feature gates
    # in Kubernetes. More information here https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/#feature-gates-for-alpha-or-beta-features
    featureGates:
        # -- nodeRepair is ALPHA and is disabled by default.
        # Setting this to true will enable node repair.
        nodeRepair: false
        # -- nodeOverlay is ALPHA and is disabled by default.
        # Setting this will allow the use of node overlay to impact scheduling decisions
        nodeOverlay: false
        # -- reservedCapacity is BETA and is enabled by default.
        # Setting this will enable native on-demand capacity reservation support.
        reservedCapacity: true
        # -- spotToSpotConsolidation is ALPHA and is disabled by default.
        # Setting this to true will enable spot replacement consolidation for both single and multi-node consolidation.
        spotToSpotConsolidation: false
        # -- staticCapacity is ALPHA and is disabled by default.
        # Setting this to true will enable static capacity provisioning.
        staticCapacity: false
VALUES
}

module "karpenter_helm_chart" {
  source  = "JetBrains/helm-charts/kubernetes"
  version = "0.3.0"
  charts = [{
    namespace         = var.helm_chart_namespace
    repository        = var.helm_chart_repository
    repository_config = var.helm_chart_repository_config
    app = {
      name             = var.helm_chart_name
      chart            = var.helm_chart_name
      version          = var.helm_chart_version
      create_namespace = var.helm_chart_create_namespace
    }
    values  = try(coalesce(var.helm_chart_values, local.karpenter_default_values_dot_yaml), local.karpenter_default_values_dot_yaml)
    params  = var.helm_chart_params
    secrets = var.helm_chart_secrets
  }]
}