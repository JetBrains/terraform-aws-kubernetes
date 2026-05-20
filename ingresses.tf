locals {
  ingress_vpc_cidr = try(coalesce(var.cluster_network_internal_vpc_cidr, "10.0.0.0/16"), "10.0.0.0/16")

  # Hardened public ingress (kube-ingress-nginx). Keep in sync with JetBrains/kubernetes/aws
  # ingresses.tf local.public_ingress_controller_default_values when upgrading module version.
  # proxy-real-ip-cidr is set from cluster_network_internal_vpc_cidr.
  # Controller image is newer than chart 4.10.0 appVersion (v1.10.0); chart version stays 4.10.0 per Terraform.
  public_ingress_controller_default_values = <<VALUES
spec:
  fullnameOverride: "public-ingress-nginx"
  commonLabels:
    cluster_service: "true"
    public: "true"
  controller:
    enableAnnotationValidations: true
    image:
      registry: registry.k8s.io
      image: ingress-nginx/controller
      tag: "v1.15.1"
      digest: sha256:594ceea76b01c592858f803f9ff4d2cb40542cae2060410b2c95f75907d659e1
      pullPolicy: IfNotPresent
    ingressClassResource:
      name: public-ingress-nginx
      enabled: "${var.cluster_public_ingress_create}"
      default: "false"
      controllerValue: "k8s.io/public-ingress-nginx"
    ingressClass: public-ingress-nginx
    watchIngressWithoutClass: false
    hostPort:
      enabled: false
    replicaCount: 3
    minAvailable: 3
    extraArgs:
      metrics-per-undefined-host: "true"
      enable-metrics: "true"
    extraEnvs: []
    addHeaders:
      X-Content-Type-Options: "nosniff"
      X-Frame-Options: "SAMEORIGIN"
      Referrer-Policy: "strict-origin-when-cross-origin"
      Permissions-Policy: "interest-cohort=()"
    config:
      annotations-risk-level: "High"
      allow-snippet-annotations: "false"
      allow-cross-namespace-resources: "false"
      annotation-value-word-blocklist: "load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount"
      client-header-buffer-size: "32k"
      compute-full-forwarded-for: "true"
      enable-real-ip: "true"
      force-ssl-redirect: "true"
      forwarded-for-header: "X-Forwarded-For"
      large-client-header-buffers: "4 32k"
      proxy-buffer-size: "128k"
      proxy-buffers: "4 256k"
      proxy-busy-buffers-size: "256k"
      proxy-real-ip-cidr: "${local.ingress_vpc_cidr}"
      ssl-redirect: "true"
      use-forwarded-headers: "true"
      use-proxy-protocol: "false"
      hsts: "true"
      hsts-include-subdomains: "true"
      hsts-max-age: "31536000"
      hsts-preload: "true"
      hide-headers: "Server,X-Powered-By"
      server-tokens: "false"
      ssl-protocols: "TLSv1.2 TLSv1.3"
      ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305"
      ssl-session-tickets: "false"
      ssl-ecdh-curve: "X25519:prime256v1:secp384r1"
      log-format-escape-json: "true"
      limit-req-status-code: "429"
      strict-validate-path-type: "true"
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                    - ingress-nginx
                - key: app.kubernetes.io/instance
                  operator: In
                  values:
                    - ingress-nginx
                - key: app.kubernetes.io/component
                  operator: In
                  values:
                    - controller
            topologyKey: "kubernetes.io/hostname"
    topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app.kubernetes.io/instance: public-ingress-nginx
    nodeSelector:
      kubernetes.io/os: linux
    resources:
      limits:
        cpu: 2
        memory: 2048Mi
      requests:
        cpu: 2
        memory: 2048Mi
    autoscaling:
      enabled: "true"
      minReplicas: 3
      maxReplicas: 7
      targetCPUUtilizationPercentage: 71
      targetMemoryUtilizationPercentage: 71
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
            - type: Pods
              value: 1
              periodSeconds: 180
        scaleUp:
          stabilizationWindowSeconds: 300
          policies:
            - type: Pods
              value: 2
              periodSeconds: 60
    autoscalingTemplate: []
    customTemplate:
      configMapName: ""
      configMapKey: ""
    service:
      enabled: "true"
      type: LoadBalancer
      external:
        enabled: "true"
    metrics:
      port: 10254
      portName: metrics
      enabled: true
      service:
        annotations:
          prometheus.io/scrape: "true"
          prometheus.io/port: "10254"
        servicePort: 10254
        type: ClusterIP
      serviceMonitor:
        enabled: true
        scrapeInterval: 15s
        additionalLabels:
          release: kube-prometheus-stack
      prometheusRule:
        enabled: true
        additionalLabels:
          release: kube-prometheus-stack
        rules:
          - alert: NGINXConfigFailed
            expr: count(nginx_ingress_controller_config_last_reload_successful == 0) > 0
            for: 1s
            labels:
              severity: critical
            annotations:
              description: bad ingress config - nginx config test failed
              summary: uninstall the latest ingress changes to allow config reloads to resume
          - alert: NGINXCertificateExpiry
            expr: (avg(nginx_ingress_controller_ssl_expire_time_seconds) by (host) - time()) < 604800
            for: 1s
            labels:
              severity: critical
            annotations:
              description: ssl certificate(s) will expire in less then a week
              summary: renew expiring certificates to avoid downtime
          - alert: NGINXTooMany500s
            expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"5.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
            for: 1m
            labels:
              severity: warning
            annotations:
              description: Too many 5XXs
              summary: More than 5% of all requests returned 5XX, this requires your attention
          - alert: NGINXTooMany400s
            expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"4.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
            for: 1m
            labels:
              severity: warning
            annotations:
              description: Too many 4XXs
              summary: More than 5% of all requests returned 4XX, this requires your attention
  admissionWebhooks:
    enabled: "false"
  tcp: {}
  udp: {}
VALUES

  # Hardened private ingress (kube-ingress-nginx). Keep in sync with JetBrains/kubernetes/aws
  # ingresses.tf local.private_ingress_controller_default_values when upgrading module version.
  # proxy-real-ip-cidr is set from cluster_network_internal_vpc_cidr.
  # Controller image is newer than chart 4.10.0 appVersion (v1.10.0); chart version stays 4.10.0 per Terraform.
  private_ingress_controller_default_values = <<VALUES
spec:
  fullnameOverride: "private-ingress-nginx"
  commonLabels:
    cluster_service: "true"
    public: "false"
  controller:
    enableAnnotationValidations: true
    image:
      registry: registry.k8s.io
      image: ingress-nginx/controller
      tag: "v1.15.1"
      digest: sha256:594ceea76b01c592858f803f9ff4d2cb40542cae2060410b2c95f75907d659e1
      pullPolicy: IfNotPresent
    ingressClassResource:
      name: private-ingress-nginx
      enabled: "true"
      default: "true"
      controllerValue: "k8s.io/private-ingress-nginx"
    ingressClass: private-ingress-nginx
    watchIngressWithoutClass: false
    hostPort:
      enabled: false
    replicaCount: 3
    minAvailable: 3
    extraArgs:
      metrics-per-undefined-host: "true"
      enable-metrics: "true"
    extraEnvs: []
    addHeaders:
      X-Content-Type-Options: "nosniff"
      X-Frame-Options: "SAMEORIGIN"
      Referrer-Policy: "strict-origin-when-cross-origin"
      Permissions-Policy: "interest-cohort=()"
    config:
      annotations-risk-level: "High"
      allow-snippet-annotations: "false"
      allow-cross-namespace-resources: "false"
      annotation-value-word-blocklist: "load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount"
      client-header-buffer-size: "32k"
      compute-full-forwarded-for: "true"
      enable-real-ip: "true"
      force-ssl-redirect: "true"
      forwarded-for-header: "X-Forwarded-For"
      large-client-header-buffers: "4 32k"
      proxy-buffer-size: "128k"
      proxy-buffers: "4 256k"
      proxy-busy-buffers-size: "256k"
      proxy-real-ip-cidr: "${local.ingress_vpc_cidr}"
      ssl-redirect: "true"
      use-forwarded-headers: "true"
      use-proxy-protocol: "false"
      hsts: "true"
      hsts-include-subdomains: "true"
      hsts-max-age: "31536000"
      hsts-preload: "true"
      hide-headers: "Server,X-Powered-By"
      server-tokens: "false"
      ssl-protocols: "TLSv1.2 TLSv1.3"
      ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305"
      ssl-session-tickets: "false"
      ssl-ecdh-curve: "X25519:prime256v1:secp384r1"
      log-format-escape-json: "true"
      limit-req-status-code: "429"
      strict-validate-path-type: "true"
    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                    - ingress-nginx
                - key: app.kubernetes.io/instance
                  operator: In
                  values:
                    - ingress-nginx
                - key: app.kubernetes.io/component
                  operator: In
                  values:
                    - controller
            topologyKey: "kubernetes.io/hostname"
    topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app.kubernetes.io/instance: private-ingress-nginx
    nodeSelector:
      kubernetes.io/os: linux
    resources:
      limits:
        cpu: 2
        memory: 2048Mi
      requests:
        cpu: 2
        memory: 2048Mi
    autoscaling:
      enabled: "true"
      minReplicas: 3
      maxReplicas: 7
      targetCPUUtilizationPercentage: 71
      targetMemoryUtilizationPercentage: 71
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
            - type: Pods
              value: 1
              periodSeconds: 180
        scaleUp:
          stabilizationWindowSeconds: 300
          policies:
            - type: Pods
              value: 2
              periodSeconds: 60
    autoscalingTemplate: []
    customTemplate:
      configMapName: ""
      configMapKey: ""
    service:
      enabled: "true"
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-internal: "true"
      type: LoadBalancer
      external:
        enabled: "true"
    metrics:
      port: 10254
      portName: metrics
      enabled: true
      service:
        annotations:
          prometheus.io/scrape: "true"
          prometheus.io/port: "10254"
        servicePort: 10254
        type: ClusterIP
      serviceMonitor:
        enabled: true
        scrapeInterval: 15s
        additionalLabels:
          release: kube-prometheus-stack
      prometheusRule:
        enabled: true
        additionalLabels:
          release: kube-prometheus-stack
        rules:
          - alert: NGINXConfigFailed
            expr: count(nginx_ingress_controller_config_last_reload_successful == 0) > 0
            for: 1s
            labels:
              severity: critical
            annotations:
              description: bad ingress config - nginx config test failed
              summary: uninstall the latest ingress changes to allow config reloads to resume
          - alert: NGINXCertificateExpiry
            expr: (avg(nginx_ingress_controller_ssl_expire_time_seconds) by (host) - time()) < 604800
            for: 1s
            labels:
              severity: critical
            annotations:
              description: ssl certificate(s) will expire in less then a week
              summary: renew expiring certificates to avoid downtime
          - alert: NGINXTooMany500s
            expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"5.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
            for: 1m
            labels:
              severity: warning
            annotations:
              description: Too many 5XXs
              summary: More than 5% of all requests returned 5XX, this requires your attention
          - alert: NGINXTooMany400s
            expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"4.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
            for: 1m
            labels:
              severity: warning
            annotations:
              description: Too many 4XXs
              summary: More than 5% of all requests returned 4XX, this requires your attention
  admissionWebhooks:
    enabled: "false"
  tcp: {}
  udp: {}
VALUES
}

module "cluster_public_ingress_controller" {
  count                                  = var.cluster_public_ingress_create ? 1 : 0
  source                                 = "./modules/template-ingress"
  ingress_helm_chart_repository          = try(coalesce(var.cluster_public_ingress.helm_chart_repository, "oci://registry.jetbrains.team/p/helm/library"), "oci://registry.jetbrains.team/p/helm/library")
  ingress_helm_chart_repository_config   = try(coalesce(var.cluster_public_ingress.helm_chart_repository_config, null), null)
  ingress_helm_chart_version             = try(coalesce(var.cluster_public_ingress.helm_chart_version, "4.10.0"), "4.10.0")
  ingress_helm_chart_name                = try(coalesce(var.cluster_public_ingress.helm_chart_name, "kube-ingress-nginx"), "kube-ingress-nginx")
  ingress_namespace                      = try(coalesce(var.cluster_public_ingress.helm_chart_namespace, "kube-public-ingress"), "kube-public-ingress")
  ingress_create_namespace_if_not_exists = try(coalesce(var.cluster_public_ingress.create_namespace_if_not_exists, true), true)
  ingress_default_values_dot_yaml        = try(coalesce(var.cluster_public_ingress.helm_chart_values, local.public_ingress_controller_default_values), null)
  ingress_params                         = try(coalesce(var.cluster_public_ingress.helm_chart_params, []), [])
  ingress_secrets                        = try(coalesce(var.cluster_public_ingress.helm_chart_secrets, []), [])
  depends_on                             = [module.cluster_monitoring]
}

module "cluster_private_ingress_controller" {
  count                                  = var.cluster_private_ingress_create ? 1 : 0
  source                                 = "./modules/template-ingress"
  ingress_helm_chart_repository          = try(coalesce(var.cluster_private_ingress.helm_chart_repository, "oci://registry.jetbrains.team/p/helm/library"), "oci://registry.jetbrains.team/p/helm/library")
  ingress_helm_chart_repository_config   = try(coalesce(var.cluster_private_ingress.helm_chart_repository_config, null), null)
  ingress_helm_chart_version             = try(coalesce(var.cluster_private_ingress.helm_chart_version, "4.10.0"), "4.10.0")
  ingress_helm_chart_name                = try(coalesce(var.cluster_private_ingress.helm_chart_name, "kube-ingress-nginx"), "kube-ingress-nginx")
  ingress_namespace                      = try(coalesce(var.cluster_private_ingress.helm_chart_namespace, "kube-private-ingress"), "kube-private-ingress")
  ingress_create_namespace_if_not_exists = try(coalesce(var.cluster_private_ingress.create_namespace_if_not_exists, true), true)
  ingress_default_values_dot_yaml        = try(coalesce(var.cluster_private_ingress.helm_chart_values, local.private_ingress_controller_default_values), null)
  ingress_params                         = try(coalesce(var.cluster_private_ingress.helm_chart_params, []), [])
  ingress_secrets                        = try(coalesce(var.cluster_private_ingress.helm_chart_secrets, []), [])
  depends_on                             = [module.cluster_monitoring]
}

data "kubernetes_service_v1" "kube_private_ingress_svc_url" {
  count = var.cluster_private_ingress_create ? 1 : 0
  metadata {
    name      = "private-ingress-nginx-controller"
    namespace = try(coalesce(var.cluster_private_ingress.helm_chart_namespace, "kube-private-ingress"), "kube-private-ingress")
  }
  depends_on = [
    module.cluster_private_ingress_controller
  ]
}

data "kubernetes_service_v1" "kube_public_ingress_svc_url" {
  count = var.cluster_public_ingress_create ? 1 : 0
  metadata {
    name      = "public-ingress-nginx-controller"
    namespace = try(coalesce(var.cluster_public_ingress.helm_chart_namespace, "kube-public-ingress"), "kube-public-ingress")
  }
  depends_on = [
    module.cluster_public_ingress_controller
  ]
}

resource "kubernetes_ingress_v1" "private_ingress_controller_metrics" {
  count = var.cluster_private_ingress_create ? 1 : 0

  metadata {
    name      = "private-ingress-nginx-controller-metrics"
    namespace = try(coalesce(var.cluster_private_ingress.helm_chart_namespace, "kube-private-ingress"), "kube-private-ingress")
    labels = {
      cluster_service = "true"
      public          = "false"
    }
  }

  spec {
    ingress_class_name = "private-ingress-nginx"

    rule {
      http {
        path {
          path      = "/metrics"
          path_type = "Exact"

          backend {
            service {
              name = "private-ingress-nginx-controller-metrics"
              port {
                number = 10254
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    module.cluster_private_ingress_controller
  ]
}
