locals {
  aws_ebs_csi_controller = {
    values_as_string = <<VALUES
customLabels:
  cluster_service: "true"
  public: "false"
controller:
  defaultFsType: ext4
  extraCreateMetadata: true
  enableMetrics: true
  replicaCount: 2
  serviceAccount:
    create: false
node:
  serviceAccount:
    create: true
storageClasses:
  - name: "standard"
    annotations:
      "storageclass.kubernetes.io/is-default-class": "true"
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Retain
    allowVolumeExpansion: true
    parameters:
      "csi.storage.k8s.io/fstype": ext3
      encrypted: "true"
      type: gp3
      allowAutoIOPSPerGBIncrease: "true"
  - name: "golden"
    annotations:
      "storageclass.kubernetes.io/is-default-class": "false"
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Retain
    allowVolumeExpansion: true
    parameters:
      "csi.storage.k8s.io/fstype": ext3
      encrypted: "true"
      type: io1
      allowAutoIOPSPerGBIncrease: "true"
  - name: platinum
    annotations:
      "storageclass.kubernetes.io/is-default-class": "false"
    volumeBindingMode: WaitForFirstConsumer
    allowVolumeExpansion: true
    reclaimPolicy: Retain
    parameters:
      "csi.storage.k8s.io/fstype": xfs
      encrypted: "true"
      type: io2
      allowAutoIOPSPerGBIncrease: "true"
VALUES
  }
  snapshot_controller = {
    values_as_string = <<VALUES
replicaCount: 2
args:
  leaderElection: true
  leaderElectionNamespace: "$(NAMESPACE)"
  httpEndpoint: ":8080"
image:
  repository: registry.k8s.io/sig-storage/snapshot-controller
  pullPolicy: IfNotPresent
  tag: ""
imagePullSecrets: []
podAnnotations: {}
podSecurityContext: {}
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
resources: {}
nodeSelector: {}
tolerations: []
affinity: {}
rbac:
  create: true
serviceAccount:
  create: true
  name: "snapshot-controller"
volumeSnapshotClasses: []
VALUES
  }
  snapshot_validation_webhook = {
    values_as_string = <<VALUES
replicaCount: 2
args:
  tlsPrivateKeyFile: /etc/snapshot-validation/tls.key
  tlsCertFile: /etc/snapshot-validation/tls.crt
  port: 8443
image:
  repository: registry.k8s.io/sig-storage/snapshot-validation-webhook
  pullPolicy: IfNotPresent
  tag: ""
webhook:
  timeoutSeconds: 2
  failurePolicy: Fail
tls:
  certificateSecret: ""
  autogenerate: true
  renew: false
  certManagerIssuerRef: {}
imagePullSecrets: []
podAnnotations: {}
networkPolicy:
  enabled: false
podSecurityContext: {}
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
resources: {}
nodeSelector: {}
tolerations: []
affinity: {}
serviceAccount:
  create: true
rbac:
  create: true
VALUES
  }
  karpenter_controller = {
    values_as_settings = [
      {
        name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = module.iam_assumable_role_karpenter.iam_role_arn
      },
      {
        name  = "settings.aws.clusterName"
        value = local.karpenter_cluster_name
      },
      {
        name  = "settings.aws.clusterEndpoint",
        value = local.karpenter_kubernetes_api_url
      },
      {
        name  = "settings.aws.defaultInstanceProfile"
        value = aws_iam_instance_profile.karpenter_node.name
      }
    ]
  }
  // cluster_internal_services represents a list of deployment objects expressed as Helm charts. This list
  // outlines the services that are internal to the Kubernetes cluster at run time. Notice that Prometheus Operator
  // is included here because on it depends the rest of cluster and application services because of its CRDs.
  cluster_internal_services = [
    {
      namespace  = "kube-system"
      repository = "https://piraeus.io/helm-charts/"
      app = {
        name    = "snapshot-validation-webhook"
        chart   = "snapshot-validation-webhook"
        version = "1.6.0"
      }
      values = tostring(local.snapshot_validation_webhook.values_as_string)
    },
    {
      namespace  = "kube-system"
      repository = "https://piraeus.io/helm-charts/"
      app = {
        name    = "snapshot-controller"
        chart   = "snapshot-controller"
        version = "1.6.0"
      }
      values = tostring(local.snapshot_controller.values_as_string)
    },
    {
      namespace  = "kube-system"
      repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
      app = {
        name    = "aws-ebs-csi-driver"
        chart   = "aws-ebs-csi-driver"
        version = "2.13.0"
      }
      values = tostring(local.aws_ebs_csi_controller.values_as_string)
    },
    {
      namespace  = local.karpenter_namespace
      repository = "oci://public.ecr.aws/karpenter"
      app = {
        name             = "karpenter"
        chart            = "karpenter"
        version          = local.karpenter_version
        create_namespace = true
      }
      params = local.karpenter_controller.values_as_settings
    },
    {
      namespace  = local.karpenter_namespace
      repository = "https://kubernetes-sigs.github.io/descheduler/"
      app = {
        name             = "descheduler"
        chart            = "descheduler"
        version          = "0.26.0"
        create_namespace = true
      }
    }
  ]

  tags = merge(var.tags, {
    scope = "EKSExtensions"
  })
}