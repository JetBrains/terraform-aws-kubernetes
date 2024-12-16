# Guides

This page outlines what services are available in the Kubernetes cluster and how to use them.

## Available cluster services

| Cluster Service            | Deployment Namespace | Purpose                                                                       | 
|:---------------------------|:---------------------|:------------------------------------------------------------------------------|
| Monitoring                 | kube-monitoring      | Monitoring and alerting of resources within the Kubernetes cluster.           |
| Cluster metrics            | kube-monitoring      | Aggregator of metrics from the Kubernetes API.                                |
| Logging collection         | kube-monitoring      | Log collector for Grafana Loki.                                               |
| Logging store              | kube-monitoring      | Log management system.                                                        |
| Host patcher               | kube-node-rebooter   | Reboot the EC2 hosts in a controller way when necessary; example: OS updates. |
| Public Ingress controller  | kube-public-ingress  | Ingress Controller to expose workloads to the Internet. Disabled by default.  |
| Private Ingress controller | kube-private-ingress | Ingress Controller to expose workloads to the intranet. Enabled by default.   |
| Cluster node autoscaler.   | kube-node-autoscaler | Scale cluster computing pool just in time with Karpenter.                     |
| Cluster descheduler        | kube-system          | Kubernetes node auto-scaler for EKS in AWS.                                   |


## Available storage classes

By default, there are three storage classes: `standard`, `golden`, `platinum`. Each of which has different performance guarantees.
The cheapest one is `standard`, while the most expensive one is `platinum`.

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

If these storage classes do not meet your requirements, you can disable their creation and provide your own storage classes with the option
described in the next section: *Additional storage classes*.

## Additional storage classes

For creating custom storage classes, use the following terraform variable: `cluster_custom_storage_classes`. The configuration
is similar to the structure of the default storage classes.

## Patching

The module installs an agent in the Kubernetes cluster that reboots the worker nodes when necessary. It checks every 30min if
there is installed a patch on the Kubernetes worker nodes. The patching is configured to actuate reboots, by default, on the following schedule:
from Monday to Friday, office hours (9:00–17:00/Central European Time Zone).

## Instructions

### Get EKS credentials

At the moment, the module assignes the IAM Role `arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy` to the entity that deploys this module.
This is the default because it is necessary to further configure the cluster in Terraform and create a unified life cycle for cluster services.

Use the variable `cluster_access_management` to provide access to your users in the cluster. 

Given that:

* `EKS_CLUSTER_NAME` is an environment variable and its value represents a valid EKS cluster name;
* `KUBECONFIG` is an environment variable abd uts value represents a valid and existing kubectl configuration file path.

Use the following command to download the cluster credentials if you are allowed:

```shell
export EKS_CLUSTER_NAME="kube-cluster"
aws eks update-kubeconfig \
  --name "${EKS_CLUSTER_NAME}" \
  --kubeconfig "~/.kube/${EKS_CLUSTER_NAME}.yaml"
export KUBECONFIG="$HOME/.kube/${EKS_CLUSTER_NAME}.yaml" 
```

Note:

Find the name of the cluster through the AWS portal of the EKS service or in the output of the module.

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

Prometheus Operator is the central monitoring solution for the Kubernetes cluster created by this module.

Any custom resource that Prometheus Operator is discovered automatically. Prometheus Operator watches for its resources
cross-namespaces.

Check out this [Prometheus Overview](https://prometheus.io/docs/introduction/overview/) for details.

To get started with Prometheus Operator, reference this [user-guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md).

#### Specify what is the Prometheus endpoint

This section will detail how to use the ServiceMonitor object to configure the targets to monitor. A ServiceMonitor specifies
how a group of services can be monitored. From a reliability perspective, this object is safer compared to PodMonitors,
ServiceMonitors do not affect the uptime of the remote monitored pods. If annotations change at run time, the applications
are not impacted since the instrumented object is a Kubernetes Service. This monitoring object is very useful to abstract
the remote endpoints and get an aggregated collection of time series data points.

#### How to scrape the metrics from the pods

ServiceMonitors are the objects that specify how a Kubernetes service can be monitored.

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

#### Specify alerting rules for the workload

Custom alerts are possible via [Prometheus rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) objects.

Reference this [detailed example](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/alerting.md#deploying-prometheus-rules) for details.

Prometheus Operator monitors at cluster level for any PrometheusRule object.


#### Credentials for Grafana

The module generates when the module is instantiated for the first time a random password and random user for Grafana root user creds. 
These creds are stored in the AWS Secrets Manager. The actual path to the secret is stored in the output variable [cluster_ssm_params_paths](../outputs.tf).

