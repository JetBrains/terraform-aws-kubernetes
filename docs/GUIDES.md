# Guides

This page outlines what supporting instruments are available with the Kubernetes cluster when the `terraform-aws-kubernetes`
Terraform module is used. This page also describes how to use the cluster services.

## Available cluster services

| Cluster Service             | Deployment Namespace      | Purpose                                                             |                                     Applied Configuration Object                                      |
|:----------------------------|:--------------------------|:--------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------:|
| Prometheus Operator         | kube-monitoring           | Monitoring and alerting of resources within the Kubernetes cluster. |          [prometheus-operator.values.yaml](../locals.cluster_services.k8s-helm-packages.tf)           |
| Kubereboot Kured            | kube-administrative-tools | Reboot the Kubernetes workers after AWS applied patches to them.    |         [cluster_services_kubereboot_kured](../locals.cluster_services.k8s-helm-packages.tf)          |
| snapshot-validation-webhook | kube-system               | EBS CSI technical dependency                                        |                       Not available. Default configuration from the Helm chart.                       |
| snapshot-controller         | kube-system               | EBS CSI technical dependency                                        |                       Not available. Default configuration from the Helm chart.                       |
| ingress-nginx               | kube-public-ingress       | Ingress Controller to expose workloads to the Internet.             |  [public-ingress-controller.values.yaml](../files/helm-values/public-ingress-controller.values.yaml)  |
| ingress-nginx               | kube-private-ingress      | Ingress Controller to expose workloads to the intranet.             | [private-ingress-controller.values.yaml](../files/helm-values/private-ingress-controller.values.yaml) |
| aws-ebs-csi-driver          | kube-system               | Storage extension for Kubernetes in AWS.                            |                   [ebs-csi-driver.values.yaml](../modules/eks-extensions/locals.tf)                   |
| grafana-promtail            | kube-monitoring           | Log collector for Grafana Loki.                                     |            [grafana-promtail.values.yaml](../locals.cluster_services.k8s-helm-packages.tf)            |
| grafana-loki                | kube-monitoring           | Log management system.                                              |              [grafana-loki.values.yaml](../locals.cluster_services.k8s-helm-packages.tf)              |
 | aws-eks-karpenter           | kube-node-autoscaler      | Kubernetes node auto-scaler for EKS in AWS.                         |                 [aws-eks-karpenter.values.yaml](../modules/eks-extensions/locals.tf)                  |   
 | metrics-server              | kube-monitoring           | Aggregator of metrics from the Kubernetes API                       |                   [metrics-server](../locals.cluster_services.k8s-helm-packages.tf)                   |

## Available storage classes

In the Kubernetes cluster there are available three storage classes (KSC): `standard`, `golden`, `platinum`. 
They are ordered by performance guarantees. The standard KSC is the cheapest class and platinum KSC most expensive and performant.

Use the standard storage class (also the default one) as much as possible.
In case the IOPS are mission critical for your application, then choose one that suits best the performance requirements
you have from `golden` or `platinum`.

```
  - name: standard
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Retain
    allowVolumeExpansion: true
    parameters:
      "csi.storage.k8s.io/fstype": ext3
      encrypted: "true"
      type: gp3
      allowAutoIOPSPerGBIncrease: "true"
  - name: golden
    annotations:
      storageclass.kubernetes.io/is-default-class: "false"
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
      storageclass.kubernetes.io/is-default-class: "false"
    volumeBindingMode: WaitForFirstConsumer
    allowVolumeExpansion: true
    reclaimPolicy: Retain
    parameters:
      "csi.storage.k8s.io/fstype": xfs
      encrypted: "true"
      type: io2
      allowAutoIOPSPerGBIncrease: "true"

```

## Kubernetes Workers' Reboot schedule

An agent in the Kubernetes cluster, named Kured, checks every 30min if AWS installed a patch on the Kubernetes worker nodes.
Kured avoids weekend reboots and only restarts the nodes from Monday to Friday during office hours (9:00-17:00 Europe/Amsterdam).

## How to

### Get EKS credentials

#### Characteristics

At the moment, the module allows all users within IAM to have Administrators access to the Kubernetes API.
This is the default.

To limit the administrative access, consider specifying the desired IAM roles in the following module's variable 
`kubernetes_cluster_admin_iam_roles`.

Given that:

* `EKS_CLUSTER_NAME` is an environment variable and its value represents a valid EKS cluster name;
* `KUBECONFIG` is an environment variable abd uts value represents a valid and existing kubectl configuration file path.

The command to download the cluster credentials follow:

```shell
export EKS_CLUSTER_NAME="kube-cluster"
aws eks update-kubeconfig \
  --name "${EKS_CLUSTER_NAME}" \
  --kubeconfig "~/.kube/${EKS_CLUSTER_NAME}.yaml"
export KUBECONFIG="$HOME/.kube/${EKS_CLUSTER_NAME}.yaml" 
```

Note:
find the name of the cluster through the AWS portal of the EKS service or in the value of the module's output variable `module.eks.kubernetes_api.name`.


### Use the public ingress controller

#### Characteristics

* The public Ingress Controller is hosted in `kube-public-ingress` namespace;

* The public Ingress Controller is the default Kubernetes Ingress Controller cluster wide.

#### Specify the ingress as ingressClassName

This is the preferable option to instruct the public Ingress Controller to publish the service outside the Kubernetes
cluster. 

Specify the `ingressClassName` property with `public-ingress-nginx` value,
under the `spec` field of the Ingress object. 

  ```
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: my-public-ingress
    spec:
      ingressClassName: public-ingress-nginx
      ...
  ```

#### Specify the ingress as an annotation

For retro compatibility reasons, you can use the `kubernetes.io/ingress.class` annotation with value `public-ingress-nginx`.
Notice that this option is deprecated. Opt for `Specify the ingress as ingressClassName` option as soon as possible.

  ```
  ...
  kind: Ingress
  metadata:
    name: my-public-ingress
    annotations:
      kubernetes.io/ingress.class: "public-ingress-nginx"
  ...
  ```

### Use the private ingress controller

#### Characteristics

* The private ingress controller is hosted in `kube-private-ingress` namespace;

* This ingress class is mutual exclusive with `kube-public-ingress` Ingress Controller.

#### Specify the ingress as ingressClassName

This is the preferable option to instruct the public Ingress Controller to publish the service outside the Kubernetes
cluster.

Specify the `ingressClassName` property with `private-ingress-nginx` value,
under the `spec` field of the Ingress object.

  ```
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: my-private-ingress
    spec:
      ingressClassName: private-ingress-nginx
      ...
  ```

#### Specify the ingress as an annotation

For retro compatibility reasons, you can use the `kubernetes.io/ingress.class` annotation with value `private-ingress-nginx`.
Notice that this option is deprecated. Opt for `Specify the ingress as ingressClassName` option as soon as possible.

  ```
  ...
  kind: Ingress
  metadata:
    name: my-private-ingress
    annotations:
      kubernetes.io/ingress.class: "private-ingress-nginx"
  ...
  ```

### Monitor workloads

Prometheus Operator monitors every resource in the cluster as a blackbox. The monitoring system does not
have understanding of what is inside a pod.

In order to monitor the pods as white boxes, you need to make sure that pods are instrumented with a Prometheus library 
that exposes metrics in the Prometheus format.
Check out this [Prometheus Overview](https://prometheus.io/docs/introduction/overview/) for details.

To get started with Prometheus Operator, reference this [user-guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md).

#### Specify what is the Prometheus endpoint

This section will detail how to use the ServiceMonitor object to configure the targets to monitor. A ServiceMonitor specifies
how a group of services can be monitored. From a reliability perspective, this object is safer compared to PodMonitors,
ServiceMonitors do not affect the uptime of the remote monitored pods. If annotations change at run time, the applications
are not impacted since the instrumented object is a Kubernetes Service. This monitoring object is very useful to abstract
the remote endpoints and get an aggregated collection of time series data points.


The same can be achieved with PodMonitors. A PodMonitor specifies how a group of pods can be monitored.
A change in the monitoring details like port, URI involves restart of the pod.

The following code block shows how the Prometheus annotations can be configured on the Service object of the application.

  ```
    apiVersion: v1
    kind: Service
    metadata:
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: "8080"
        prometheus.io/scrape: "true"
      name: kubereboot-kured
      namespace: kube-administrative-tools
    spec:
     ports:
       - name: metrics
         port: 8080
         protocol: TCP
         targetPort: 8080
     selector:
       app.kubernetes.io/instance: kubereboot
       app.kubernetes.io/name: kured
     type: ClusterIP
  ```

As soon as the Service is annotated, create a ServiceMonitor like the following.

  ```
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      name: kubereboot-kured
      namespace: kube-administrative-tools
      labels:
        release: kube-prometheus-stack
    spec:
       endpoints:
         - honorLabels: true
           interval: 60s
           path: /metrics
           scheme: http
           targetPort: 8080
       jobLabel: kubereboot
       namespaceSelector:
         matchNames:
           - kube-administrative-tools
       selector:
         matchLabels:
           app.kubernetes.io/instance: kubereboot
           app.kubernetes.io/name: kured
  ```

Do not miss the label `release: kube-prometheus-stack`; without it Prometheus won't be able to discover the
ServiceMonitor object.

#### Specify alerting rules for the workload

Custom alerts are possible via [Prometheus rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) objects. 

Reference this [detailed example](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/alerting.md#deploying-prometheus-rules) for details.

Do not miss the label `release: kube-prometheus-stack`; without it Prometheus won't be able to discover the
PrometheusRule object.

## Caution

* No cluster service is available outside the network area of the Kubernetes cluster.