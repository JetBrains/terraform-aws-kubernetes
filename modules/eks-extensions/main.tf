/*
* This files defines deployment configuration of EKS extensions
*
* References:
*
* To get more information about Prometheus Operator refer this URL
*   ref: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
*
* Necessary annotations for public Network Load Balancer.
*   ref: https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
*
* Necessary details fot the EBS CSI driver
*   ref: https://github.com/kubernetes-sigs/aws-ebs-csi-driver
*/

module "k8s_internal_services" {
  source = "../k8s-helm-packages"
  charts = local.cluster_internal_services
  # Exception:
  # This resource does not support tags.
}