locals {
  cluster_logging_default_values = <<VALUES
spec:
  loki:
    commonConfig:
      replication_factor: 1
    storage:
      type: 'filesystem'
    schemaConfig:
      configs:
        - from: "2022-01-11"
          store: boltdb-shipper
          object_store: filesystem
          schema: v12
          index:
            prefix: loki_index_
            period: 24h
        - from: "2026-06-01"
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: loki_index_
            period: 24h
    storage_config:
      boltdb_shipper:
        active_index_directory: /var/loki/boltdb-shipper-active
        cache_location: /var/loki/boltdb-shipper-cache
        shared_store: filesystem
      tsdb_shipper:
        active_index_directory: /var/loki/tsdb-index
        cache_location: /var/loki/tsdb-cache
    auth_enabled: false
    limits_config:
      enforce_metric_name: true
      reject_old_samples: true
      reject_old_samples_max_age: 168h
      max_cache_freshness_per_query: 10m
      split_queries_by_interval: 1h
      retention_period: 168h
      max_query_lookback: 168h
    compactor:
      working_directory: /var/loki/compactor
      compaction_interval: 10m
      retention_enabled: true
      retention_delete_delay: 2h
      delete_request_store: filesystem
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
          - from: 2026-06-01
            store: tsdb
            object_store: {{ .Values.loki.storage.type }}
            schema: v13
            index:
              prefix: loki_index_
              period: 24h
      {{- end }}

      {{ include "loki.rulerConfig" . }}

      table_manager:
        retention_deletes_enabled: true
        retention_period: 168h

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
  gateway:
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 256Mi
  write:
    persistence:
      enableStatefulSetAutoDeletePVC: true
      size: 50Gi
      storageClass: standard
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2
        memory: 2Gi
    extraEnv:
      - name: GOMEMLIMIT
        value: 1800MiB
  read:
    persistence:
      enableStatefulSetAutoDeletePVC: true
      size: 50Gi
      storageClass: standard
    resources:
      requests:
        cpu: 250m
        memory: 512Mi
      limits:
        cpu: 1
        memory: 1Gi
    extraEnv:
      - name: GOMEMLIMIT
        value: 900MiB
  backend:
    persistence:
      enableStatefulSetAutoDeletePVC: true
      size: 50Gi
      storageClass: standard
    resources:
      requests:
        cpu: 250m
        memory: 512Mi
      limits:
        cpu: 1
        memory: 1Gi
    extraEnv:
      - name: GOMEMLIMIT
        value: 900MiB
  monitoring:
    serviceMonitor:
      enabled: true
    selfMonitoring:
      enabled: false
    lokiCanary:
      enabled: false
  singleBinary:
    replicas: 1
    persistence:
      enableStatefulSetAutoDeletePVC: true
      enabled: true
      size: 50Gi
      storageClass: standard
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2
        memory: 2Gi
    extraEnv:
      - name: GOMEMLIMIT
        value: 1800MiB
  extraObjects:
  - apiVersion: monitoring.coreos.com/v1
    kind: PrometheusRule
    metadata:
      name: loki-custom-alerting-rules
      namespace: "{{ .Release.Namespace }}"
    spec:
      groups:
        - name: loki_custom_rules
          rules:
          - alert: LokiIngestionLag
            expr: max by (namespace, job) (loki_ingester_flush_queue_length) > 50
            for: 15m
            labels:
              severity: warning
              category: logs
            annotations:
              summary: Loki ingester flush queue is backing up
              description: |
                The ingester flush queue length is {{`{{`}} printf "%.0f" $value {{`}}`}} for
                {{`{{`}} $labels.namespace {{`}}`}}/{{`{{`}} $labels.job {{`}}`}}. Ingestion may be lagging
                behind flush capacity; check write path load and storage health.
          - alert: LokiWriteComponentUnavailable
            expr: min by (namespace, job) (up{job=~".+/write"}) < 1
            for: 5m
            labels:
              severity: critical
              category: logs
            annotations:
              summary: Loki write component is unavailable
              description: |
                One or more Loki write scrape targets are down in namespace
                {{`{{`}} $labels.namespace {{`}}`}} (job {{`{{`}} $labels.job {{`}}`}}). Log ingestion may
                be impaired.
          - alert: LokiReadComponentUnavailable
            expr: min by (namespace, job) (up{job=~".+/read"}) < 1
            for: 5m
            labels:
              severity: critical
              category: logs
            annotations:
              summary: Loki read component is unavailable
              description: |
                One or more Loki read scrape targets are down in namespace
                {{`{{`}} $labels.namespace {{`}}`}} (job {{`{{`}} $labels.job {{`}}`}}). Log queries may
                fail or return incomplete results.
          - alert: LokiIngesterFlushFailureRateHigh
            expr: |
              (
                sum(rate(loki_ingester_chunks_flush_errors_total[5m])) by (namespace, job)
                /
                sum(
                  rate(loki_ingester_chunks_flushed_total[5m])
                  + rate(loki_ingester_chunks_flush_errors_total[5m])
                ) by (namespace, job)
              ) > 0.05
              and sum(rate(loki_ingester_chunks_flush_errors_total[5m])) by (namespace, job) > 0
            for: 10m
            labels:
              severity: critical
              category: logs
            annotations:
              summary: Loki ingester chunk flush error rate is high
              description: |
                More than 5% of ingester chunk flush operations are failing for
                {{`{{`}} $labels.namespace {{`}}`}}/{{`{{`}} $labels.job {{`}}`}} (current rate
                {{`{{`}} printf "%.2f" $value {{`}}`}}). Check object storage credentials,
                permissions, and disk space on write nodes.
VALUES

  cluster_logging_collector_default_values = <<VALUES
spec:
  daemonset:
    enabled: true
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 256Mi
  serviceMonitor:
    enabled: true
  prometheusRule:
    enabled: true
    rules:
      - alert: PromtailTargetScrapeFailures
        expr: sum(rate(promtail_targets_failed_total[5m])) by (namespace, job, reason) > 0
        for: 10m
        labels:
          severity: warning
          category: logs
        annotations:
          summary: Promtail is failing to scrape log targets
          description: |
            Promtail target scrape failures are occurring in {{`{{`}} $labels.namespace {{`}}`}}
            (job {{`{{`}} $labels.job {{`}}`}}, reason {{`{{`}} $labels.reason {{`}}`}}). Check file paths,
            permissions, and relabel rules for affected targets.
  config:
    logLevel: info
    serverPort: 3101
    # Promtail must send X-Scope-OrgID (tenant_id) when Loki uses multi-tenant mode.
    # Align with Grafana Loki datasource (fake) in monitoring.tf.
    clients:
      - url: http://loki-headless:3100/loki/api/v1/push
        tenant_id: fake
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


module "cluster_logging" {
  count                                          = var.cluster_logging_create ? 1 : 0
  source                                         = "./modules/feature-grafana-loki"
  cluster_logging_helm_chart_repository          = try(coalesce(var.cluster_logging.helm_chart_repository, "oci://registry.jetbrains.team/p/helm/library"), "oci://registry.jetbrains.team/p/helm/library")
  cluster_logging_helm_chart_repository_config   = try(coalesce(var.cluster_logging.helm_chart_repository_config, null), null)
  cluster_logging_helm_chart_version             = try(coalesce(var.cluster_logging.helm_chart_version, "5.43.3"), "5.43.3")
  cluster_logging_helm_chart_name                = try(coalesce(var.cluster_logging.helm_chart_name, "kube-grafana-loki"), "kube-grafana-loki")
  cluster_logging_namespace                      = try(coalesce(var.cluster_logging.helm_chart_namespace, "kube-monitoring"), "kube-monitoring")
  cluster_logging_create_namespace_if_not_exists = try(coalesce(var.cluster_logging.create_namespace_if_not_exists, true), true)
  cluster_logging_default_values_dot_yaml        = try(coalesce(var.cluster_logging.helm_chart_values, local.cluster_logging_default_values), local.cluster_logging_default_values)
  cluster_logging_params                         = try(coalesce(var.cluster_logging.helm_chart_params, []), [])
  cluster_logging_secrets                        = try(coalesce(var.cluster_logging.helm_chart_secrets, []), [])
  depends_on = [
    module.cluster_monitoring
  ]
}

module "cluster_logging_collector" {
  count                                                    = var.cluster_logging_create ? 1 : 0
  source                                                   = "./modules/feature-grafana-promtail"
  cluster_logging_collector_helm_chart_repository          = try(coalesce(var.cluster_logging_collector.helm_chart_repository, "oci://registry.jetbrains.team/p/helm/library"), "oci://registry.jetbrains.team/p/helm/library")
  cluster_logging_collector_helm_chart_repository_config   = try(coalesce(var.cluster_logging_collector.helm_chart_repository_config, null), null)
  cluster_logging_collector_helm_chart_version             = try(coalesce(var.cluster_logging_collector.helm_chart_version, "6.15.5"), "6.15.5")
  cluster_logging_collector_helm_chart_name                = try(coalesce(var.cluster_logging_collector.helm_chart_name, "kube-grafana-promtail"), "kube-grafana-promtail")
  cluster_logging_collector_namespace                      = try(coalesce(var.cluster_logging_collector.helm_chart_namespace, "kube-monitoring"), "kube-monitoring")
  cluster_logging_collector_create_namespace_if_not_exists = try(coalesce(var.cluster_logging_collector.create_namespace_if_not_exists, true), true)
  cluster_logging_collector_default_values_dot_yaml        = try(coalesce(var.cluster_logging_collector.helm_chart_values, local.cluster_logging_collector_default_values), local.cluster_logging_collector_default_values)
  cluster_logging_collector_params                         = try(coalesce(var.cluster_logging_collector.helm_chart_params, []), [])
  cluster_logging_collector_secrets                        = try(coalesce(var.cluster_logging_collector.helm_chart_secrets, []), [])
  depends_on = [
    module.cluster_monitoring
  ]
}
