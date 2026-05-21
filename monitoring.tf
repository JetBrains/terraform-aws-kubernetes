
locals {
  ssm_path_for_grafana_admin_user     = "/eks/cluster/prom_stack/${var.prefix}/grafana_admin_user"
  ssm_path_for_grafana_admin_password = "/eks/cluster/prom_stack/${var.prefix}/grafana_admin_password"
  cluster_monitoring_default_values   = <<VALUES
spec:
  commonLabels:
    cluster_service: "true"
    public: "false"
  additionalPrometheusRulesMap: {}
  alertmanager:
    alertmanagerSpec:
      retention: 36h
      resources:
        requests:
          cpu: 100m
          memory: 256Mi
        limits:
          cpu: 200m
          memory: 512Mi
      storage:
         volumeClaimTemplate:
           spec:
             storageClassName: standard
             accessModes: ["ReadWriteOnce"]
             resources:
               requests:
                 storage: 10Gi
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: kube-prometheus-stack
  grafana:
    defaultDashboardsTimezone: utc
    extraConfigmapMounts: []
    ingress:
      enabled: false
      hosts: []
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: kube-prometheus-stack
    additionalDataSources:
    - name: 'Loki'
      type: loki
      url: 'http://loki-headless:3100'
      editable: false
      jsonData:
        maxLines: 2000
        timeout: 60
        httpHeaderName1: X-Scope-OrgID
      secureJsonData:
        httpHeaderValue1: fake
    dashboardProviders:
      dashboardproviders.yaml:
        apiVersion: 1
        providers:
        - name: 'services'
          orgId: 1
          folder: 'Services'
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards/services
    dashboards:
      services:
        kubernetes-ingress-nginx-1:
          gnetId: 9614
          revision: 1
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
        kubernetes-ingress-nginx-2:
          gnetId: 14314
          revision: 2
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
        kubernetes-storage-view:
          gnetId: 13646
          revision: 2
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
        kubernetes-node-autoscaler:
          gnetId: 22171
          revision: 5
          datasource: Prometheus
        kubernetes-node-rebooter:
          gnetId: 16207
          revision: 3
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
        loki-metrics:
          gnetId: 17781
          revision: 1
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
        promtail-monitoring:
          gnetId: 20881
          revision: 1
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
            - name: DS_LOKI
              value: Loki
        karpenter-performance:
          gnetId: 22173
          revision: 1
          datasource: Prometheus
        loki-stack-monitoring:
          gnetId: 14055
          revision: 1
          datasource:
            - name: DS_PROMETHEUS
              value: Prometheus
            - name: DS_LOKI
              value: Loki
        loki-kubernetes-logs:
          gnetId: 15141
          revision: 1
          datasource:
            - name: DS_LOKI
              value: Loki
        app-resource-utilization:
          gnetId: 12363
          revision: 1
          datasource:
            - name: DS_THANOS
              value: Prometheus
  kubeStateMetrics:
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 256Mi
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: kube-prometheus-stack
  prometheus-node-exporter:
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 128Mi
  prometheus:
    serviceMonitor:
      selfMonitor: true
      additionalLabels:
        release: kube-prometheus-stack
    prometheusSpec:
      resources:
        requests:
          cpu: 500m
          memory: 2Gi
        limits:
          cpu: 2
          memory: 4Gi
      serviceMonitorSelectorNilUsesHelmValues: false
      serviceMonitorSelector: {}
      serviceMonitorNamespaceSelector: {}
      ruleSelectorNilUsesHelmValues: false
      podMonitorSelectorNilUsesHelmValues: false
      probeSelectorNilUsesHelmValues: false
      scrapeConfigSelectorNilUsesHelmValues: false
      retention: 3d
      storageSpec:
        volumeClaimTemplate:
          spec:
            storageClassName: standard
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 50Gi
VALUES
}


resource "random_pet" "grafana_admin" {
  count = var.cluster_monitoring_create ? 1 : 0
  keepers = {
    kubernetes_cluster_name = var.prefix
  }
  length = 1
}

resource "aws_ssm_parameter" "grafana_admin_username" {
  count       = var.cluster_monitoring_create ? 1 : 0
  name        = local.ssm_path_for_grafana_admin_user
  description = "Grafana admin username for the cluster name: ${var.prefix}"
  type        = "String"
  value       = random_pet.grafana_admin[0].id
}

resource "random_password" "grafana_admin" {
  count = var.cluster_monitoring_create ? 1 : 0
  keepers = {
    kubernetes_cluster_name = var.prefix
  }
  special = false
  length  = 19
}

resource "aws_ssm_parameter" "grafana_admin_password" {
  count       = var.cluster_monitoring_create ? 1 : 0
  name        = local.ssm_path_for_grafana_admin_password
  description = "Grafana admin password for the cluster name: ${var.prefix}"
  type        = "SecureString"
  value       = random_password.grafana_admin[0].result
}

locals {
  grafana_admin_creds_secret = [{
    name  = "spec.grafana.adminUser"
    value = try(random_pet.grafana_admin[0].id, "admin")
    }, {
    name  = "spec.grafana.adminPassword"
    value = try(random_password.grafana_admin[0].result, null)
  }]
}

module "cluster_monitoring" {
  count                                             = var.cluster_monitoring_create ? 1 : 0
  source                                            = "./modules/feature-monitoring-metrics"
  cluster_monitoring_helm_chart_repository          = try(coalesce(var.cluster_monitoring.helm_chart_repository, "oci://registry.jetbrains.team/p/helm/library"), "oci://registry.jetbrains.team/p/helm/library")
  cluster_monitoring_helm_chart_repository_config   = try(coalesce(var.cluster_monitoring.helm_chart_repository_config, null), null)
  cluster_monitoring_helm_chart_version             = try(coalesce(var.cluster_monitoring.helm_chart_version, "56.21.1"), "56.21.1")
  cluster_monitoring_helm_chart_name                = try(coalesce(var.cluster_monitoring.helm_chart_name, "kube-prometheus-operator"), "kube-prometheus-operator")
  cluster_monitoring_namespace                      = try(coalesce(var.cluster_monitoring.helm_chart_namespace, "kube-monitoring"), "kube-monitoring")
  cluster_monitoring_create_namespace_if_not_exists = try(coalesce(var.cluster_monitoring.create_namespace_if_not_exists, true), true)
  cluster_monitoring_default_values_dot_yaml        = try(coalesce(var.cluster_monitoring.helm_chart_values, local.cluster_monitoring_default_values), local.cluster_monitoring_default_values)
  cluster_monitoring_params                         = try(coalesce(var.cluster_monitoring.helm_chart_params, []), [])
  cluster_monitoring_secrets                        = try(concat(coalesce(var.cluster_monitoring.helm_chart_secrets, []), local.grafana_admin_creds_secret), [])
  depends_on = [
    aws_eks_addon.ebs_csi_driver,
    aws_eks_addon.efs_csi_driver
  ]
}
