/*
* This Terraform call is blocking.
* It waits until Prometheus Operator is ready for getting a full description of the Prometheus Operator installer.
*/
#data "kubernetes_resource" "kube_monitoring_prometheus_operator_discovery_label" {
#  api_version = "monitoring.coreos.com/v1"
#  kind        = "Prometheus"
#
#  metadata {
#    name      = "kube-prometheus-stack-prometheus"
#    namespace = "kube-monitoring"
#  }
#  depends_on = [
#    module.k8s_internal_services
#  ]
#}