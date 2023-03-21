/**
* This file defines the place where the cluster services are configured for deployment.
*
*
* To get more information about the Kubernetes Nginx Ingress Controller use this URL
*   ref: https://kubernetes.github.io/ingress-nginx/tree/main/charts/ingress-nginx
*
* TCP service key-value pairs
*   ref: https://kubernetes.github.io/ingress-nginx/blob/main/docs/user-guide/exposing-tcp-udp-services.md
*
* Automatic node reboot handler
*  ref: https://github.com/kubereboot/charts/tree/main/charts/kured
*
* Troubleshoot AWS Cloud Service Load Balancers
*  ref: https://aws.amazon.com/premiumsupport/knowledge-center/eks-load-balancers-troubleshooting/
*/

locals {

  // user_specified_configurations is an internal representation of the public var.kubernetes_cluster_services_configs object.
  // It is used to decouple public values from the internal uses.
  user_specified_configurations = {
    kube_private_ingress_set_values = var.kubernetes_cluster_services_configs.kube_private_ingress_set_values != null ? var.kubernetes_cluster_services_configs.kube_private_ingress_set_values : []
    kube_public_ingress_set_values  = var.kubernetes_cluster_services_configs.kube_public_ingress_set_values != null ? var.kubernetes_cluster_services_configs.kube_public_ingress_set_values : []
  }
  helm_charts = {
    default_values = {
      prometheus_operator = {
        values_as_string = <<VALUES
commonLabels:
  cluster_service: "true"
  public: "false"
additionalPrometheusRulesMap: {}
alertmanager:
  alertmanagerSpec:
    retention: 36h
    storage:
       volumeClaimTemplate:
         spec:
           storageClassName: standard
           accessModes: ["ReadWriteOnce"]
           resources:
             requests:
               storage: 10Gi
grafana:
  adminUser: "administrator"
  adminPassword: "j@F652#pMBUGc&us8nr"
  defaultDashboardsTimezone: utc
  extraConfigmapMounts: []
  additionalDataSources: []
  ingress:
    enabled: false
    hosts: []
  additionalDataSources:
  - name: 'Loki'
    type: loki
    url: 'http://loki-headless:3100'
    editable: false
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
      - name: 'space'
        orgId: 1
        folder: 'Space'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/space
  dashboards:
    services:
      kubernetes-ingress-nginx-1:
        gnetId: 9614
        revision: 1
        datasource: Prometheus
      kubernetes-ingress-nginx-2:
        gnetId: 14314
        revision: 2
        datasource: Prometheus
      kubernetes-storage-view:
        gnetId: 13646
        revision: 2
        datasource: Prometheus

prometheus:
  prometheusSpec:
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
      metrics_server = {
        values_as_string = <<VALUES
args:
- --kubelet-insecure-tls
VALUES
      }
      grafana_promtail = {
        values_as_string = <<VALUES
daemonset:
  enabled: true
serviceMonitor:
  enabled: true
config:
  logLevel: info
  serverPort: 3101
  clients:
    - url: http://loki-headless:3100/loki/api/v1/push
  snippets:
    pipelineStages:
      - cri: {}
    common:
      - action: replace
        source_labels:
          - __meta_kubernetes_pod_node_name
        target_label: node_name
      - action: replace
        source_labels:
          - __meta_kubernetes_namespace
        target_label: namespace
      - action: replace
        replacement: $1
        separator: /
        source_labels:
          - namespace
          - app
        target_label: job
      - action: replace
        source_labels:
          - __meta_kubernetes_pod_name
        target_label: pod
      - action: replace
        source_labels:
          - __meta_kubernetes_pod_container_name
        target_label: container
      - action: replace
        replacement: /var/log/pods/*$1/*.log
        separator: /
        source_labels:
          - __meta_kubernetes_pod_uid
          - __meta_kubernetes_pod_container_name
        target_label: __path__
      - action: replace
        replacement: /var/log/pods/*$1/*.log
        regex: true/(.*)
        separator: /
        source_labels:
          - __meta_kubernetes_pod_annotationpresent_kubernetes_io_config_hash
          - __meta_kubernetes_pod_annotation_kubernetes_io_config_hash
          - __meta_kubernetes_pod_container_name
        target_label: __path__

    scrapeConfigs: |
      # See also https://github.com/grafana/loki/blob/master/production/ksonnet/promtail/scrape_config.libsonnet for reference
      - job_name: kubernetes-pods
        pipeline_stages:
          {{- toYaml .Values.config.snippets.pipelineStages | nindent 4 }}
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels:
              - __meta_kubernetes_pod_controller_name
            regex: ([0-9a-z-.]+?)(-[0-9a-f]{8,10})?
            action: replace
            target_label: __tmp_controller_name
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_name
              - __meta_kubernetes_pod_label_app
              - __tmp_controller_name
              - __meta_kubernetes_pod_name
            regex: ^;*([^;]+)(;.*)?$
            action: replace
            target_label: app
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_instance
              - __meta_kubernetes_pod_label_release
            regex: ^;*([^;]+)(;.*)?$
            action: replace
            target_label: instance
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_component
              - __meta_kubernetes_pod_label_component
            regex: ^;*([^;]+)(;.*)?$
            action: replace
            target_label: component
          {{- if .Values.config.snippets.addScrapeJobLabel }}
          - replacement: kubernetes-pods
            target_label: scrape_job
          {{- end }}
          {{- toYaml .Values.config.snippets.common | nindent 4 }}
          {{- with .Values.config.snippets.extraRelabelConfigs }}
          {{- toYaml . | nindent 4 }}
          {{- end }}
VALUES
      }
      grafana_loki = {
        values_as_string = <<VALUES
loki:
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
  auth_enabled: false
  limits_config:
    enforce_metric_name: true
    reject_old_samples: true
    reject_old_samples_max_age: 72h
    max_cache_freshness_per_query: 10m
    split_queries_by_interval: 15m
  config: |
    {{- if .Values.enterprise.enabled }}
    {{- tpl .Values.enterprise.config . }}
    {{- else }}
    auth_enabled: {{ .Values.loki.auth_enabled }}
    {{- end }}

    {{- with .Values.loki.server }}
    server:
      {{- toYaml . | nindent 2}}
    {{- end}}

    memberlist:
      join_members:
        - {{ include "loki.memberlist" . }}
        {{- with .Values.migrate.fromDistributed }}
        {{- if .enabled }}
        - {{ .memberlistService }}
        {{- end }}
        {{- end }}

    {{- with .Values.loki.ingester }}
    ingester:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}

    {{- if .Values.loki.commonConfig}}
    common:
    {{- toYaml .Values.loki.commonConfig | nindent 2}}
      storage:
      {{- include "loki.commonStorageConfig" . | nindent 4}}
    {{- end}}

    {{- with .Values.loki.limits_config }}
    limits_config:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}

    runtime_config:
      file: /etc/loki/runtime-config/runtime-config.yaml

    {{- with .Values.loki.memcached.chunk_cache }}
    {{- if and .enabled (or .host .addresses) }}
    chunk_store_config:
      chunk_cache_config:
        memcached:
          batch_size: {{ .batch_size }}
          parallelism: {{ .parallelism }}
        memcached_client:
          {{- if .host }}
          host: {{ .host }}
          {{- end }}
          {{- if .addresses }}
          addresses: {{ .addresses }}
          {{- end }}
          service: {{ .service }}
    {{- end }}
    {{- end }}

    {{- if .Values.loki.schemaConfig}}
    schema_config:
    {{- toYaml .Values.loki.schemaConfig | nindent 2}}
    {{- else }}
    schema_config:
      configs:
        - from: 2022-01-11
          store: boltdb-shipper
          object_store: {{ .Values.loki.storage.type }}
          schema: v12
          index:
            prefix: loki_index_
            period: 24h
    {{- end }}

    {{ include "loki.rulerConfig" . }}

    table_manager:
      retention_deletes_enabled: true
      retention_period: 72h

    {{- with .Values.loki.memcached.results_cache }}
    query_range:
      align_queries_with_step: true
      {{- if and .enabled (or .host .addresses) }}
      cache_results: {{ .enabled }}
      results_cache:
        cache:
          default_validity: {{ .default_validity }}
          memcached_client:
            {{- if .host }}
            host: {{ .host }}
            {{- end }}
            {{- if .addresses }}
            addresses: {{ .addresses }}
            {{- end }}
            service: {{ .service }}
            timeout: {{ .timeout }}
      {{- end }}
    {{- end }}

    {{- with .Values.loki.storage_config }}
    storage_config:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}

    {{- with .Values.loki.query_scheduler }}
    query_scheduler:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}

    {{- with .Values.loki.compactor }}
    compactor:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}

    {{- with .Values.loki.analytics }}
    analytics:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}

    {{- with .Values.loki.querier }}
    querier:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}
write:
  persistence:
    enableStatefulSetAutoDeletePVC: true
    size: 10Gi
    storageClass: standard
read:
  persistence:
    enableStatefulSetAutoDeletePVC: true
    size: 10Gi
    storageClass: standard
backend:
  persistence:
    enableStatefulSetAutoDeletePVC: true
    size: 10Gi
    storageClass: standard
singleBinary:
  persistence:
    enableStatefulSetAutoDeletePVC: true
    enabled: true
    size: 10Gi
    storageClass: standard
extraObjects:
- apiVersion: monitoring.coreos.com/v1
  kind: PrometheusRule
  metadata:
    name: loki-custom-alerting-rules
    namespace: "{{ .Release.Namespace }}"
  spec:
    groups:
      - name: loki_custom_example_rules
        rules:
        - alert: ExampleCustomAlertForLoki
          expr: sum(count_over_time({app="loki"}[1m:1h])) > 0
          for: 3m
          labels:
            severity: warning
            category: logs
            cluster: kube-loki
            message: "loki has encountered errors"
VALUES
      }
      kubereboot_kured = {
        values_as_string = <<VALUES
metrics:
  create: true
  labels:
    release: kube-prometheus-stack
service:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "8080"
configuration:
  startTime: "10:00"
  endTime: "17:00"
  timeZone: "Europe/Amsterdam"
  period: "30m0s"
  rebootDays: [mo,tu,we,th,fr]
  annotateNodes: true
  prometheusUrl: "http://kube-prometheus-stack-prometheus.kube-monitoring.svc:9090"
    VALUES
      }
    }
  }
  cluster_services_logging = [
    {
      namespace  = "kube-monitoring"
      repository = "https://grafana.github.io/helm-charts"
      app = {
        name             = "promtail"
        chart            = "promtail"
        version          = "6.8.2"
        create_namespace = true
      }
      values = local.helm_charts.default_values.grafana_promtail.values_as_string
    },
    {
      namespace  = "kube-monitoring"
      repository = "https://grafana.github.io/helm-charts"
      app = {
        name             = "loki"
        chart            = "loki"
        version          = "4.4.2"
        create_namespace = true
      }
      values = local.helm_charts.default_values.grafana_loki.values_as_string
    }
  ]
  cluster_services_monitoring = [
    {
      namespace  = "kube-monitoring"
      repository = "https://prometheus-community.github.io/helm-charts"
      app = {
        name             = "kube-prometheus-stack"
        chart            = "kube-prometheus-stack"
        version          = "45.0.0"
        create_namespace = true
      }
      values = local.helm_charts.default_values.prometheus_operator.values_as_string
    },
    {
      namespace  = "kube-monitoring"
      repository = "https://kubernetes-sigs.github.io/metrics-server"
      app = {
        name             = "metrics-server"
        chart            = "metrics-server"
        version          = "3.8.3"
        create_namespace = true
      }
      values = local.helm_charts.default_values.metrics_server.values_as_string
    }
  ]
  // cluster_services_kubereboot_kured is an internal object that is used to store in memory and not on files the customizations
  // for the Kured Helm Chart.


  // cluster_services_helm_charts represents a list of deployment objects expressed as Helm charts. This list
  // outlines the services that are made available in Kubernetes at run time.
  cluster_services_helm_charts = [
    {
      namespace  = "kube-administrative-tools"
      repository = "https://kubereboot.github.io/charts"
      app = {
        name             = "kubereboot"
        chart            = "kured"
        version          = "4.1.0"
        create_namespace = true
      }
      values = local.helm_charts.default_values.kubereboot_kured.values_as_string
    },
    {
      namespace  = "kube-private-ingress"
      repository = "https://kubernetes.github.io/ingress-nginx"
      app = {
        name             = "ingress-nginx"
        chart            = "ingress-nginx"
        version          = "4.4.0"
        create_namespace = true
      }
      values = templatefile("${path.module}/files/helm-values/private-ingress-controller.values.yaml", {})
      params = local.user_specified_configurations.kube_private_ingress_set_values
    },
    {
      namespace  = "kube-public-ingress"
      repository = "https://kubernetes.github.io/ingress-nginx"
      app = {
        name             = "ingress-nginx"
        chart            = "ingress-nginx"
        version          = "4.4.0"
        create_namespace = true
      }
      values = templatefile("${path.module}/files/helm-values/public-ingress-controller.values.yaml", {})
      params = local.user_specified_configurations.kube_public_ingress_set_values
    }
  ]
}