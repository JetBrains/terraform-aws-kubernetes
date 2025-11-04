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

## Module Outputs

This section documents all outputs exposed by the module, providing detailed information about the structure and contents of each output.

### `cluster`

The main EKS cluster configuration output. Contains comprehensive information about the Kubernetes cluster, including:

- **`access_entries`**: Map of access entries for cluster authentication. Each entry contains:
  - `access_entry_arn`: ARN of the access entry
  - `cluster_name`: Name of the EKS cluster
  - `created_at` / `modified_at`: Timestamps
  - `id`: Unique identifier
  - `kubernetes_groups`: Set of Kubernetes groups
  - `principal_arn`: ARN of the IAM principal
  - `tags` / `tags_all`: Resource tags
  - `type`: Access entry type (e.g., "STANDARD")
  - `user_name`: Assumed role user name

- **`access_policy_associations`**: Map of access policy associations, including:
  - `access_scope`: List of access scopes (cluster/namespace level)
  - `associated_at` / `modified_at`: Timestamps
  - `policy_arn`: ARN of the associated policy
  - `principal_arn`: ARN of the IAM principal

- **`cloudwatch_log_group_arn`** / **`cloudwatch_log_group_name`**: CloudWatch log group details for cluster logs

- **`cluster_addons`**: Map of installed EKS addons (e.g., `coredns`, `vpc-cni`, `kube-proxy`, `eks-pod-identity-agent`, `snapshot-controller`). Each addon contains:
  - `addon_name`: Name of the addon
  - `addon_version`: Version string
  - `arn`: ARN of the addon
  - `created_at` / `modified_at`: Timestamps
  - `configuration_values`: YAML configuration
  - `preserve`: Whether addon is preserved on delete
  - `resolve_conflicts_on_create` / `resolve_conflicts_on_update`: Conflict resolution strategy
  - `service_account_role_arn`: IAM role ARN for the addon

- **`cluster_arn`**: ARN of the EKS cluster
- **`cluster_certificate_authority_data`**: Base64-encoded certificate authority data
- **`cluster_dualstack_oidc_issuer_url`** / **`cluster_oidc_issuer_url`**: OIDC issuer URLs
- **`cluster_endpoint`**: Kubernetes API server endpoint URL
- **`cluster_iam_role_arn`** / **`cluster_iam_role_name`** / **`cluster_iam_role_unique_id`**: Cluster IAM role details
- **`cluster_ip_family`**: IP family (e.g., "ipv4")
- **`cluster_name`**: Name of the cluster
- **`cluster_platform_version`**: EKS platform version
- **`cluster_primary_security_group_id`**: Primary security group ID
- **`cluster_security_group_arn`** / **`cluster_security_group_id`**: Cluster security group details
- **`cluster_service_cidr`**: Service CIDR block
- **`cluster_status`**: Current cluster status (e.g., "ACTIVE")
- **`cluster_version`**: Kubernetes version (e.g., "1.34")
- **`cluster_tls_certificate_sha1_fingerprint`**: TLS certificate fingerprint

- **`eks_managed_node_groups`**: Map of EKS managed node groups. Each group contains:
  - `iam_role_arn` / `iam_role_name` / `iam_role_unique_id`: Node group IAM role details
  - `node_group_arn`: ARN of the node group
  - `node_group_autoscaling_group_names`: List of Auto Scaling group names
  - `node_group_id`: Unique identifier
  - `node_group_labels`: Labels applied to nodes
  - `node_group_resources`: Resource details including Auto Scaling groups
  - `node_group_status`: Current status (e.g., "ACTIVE")
  - `node_group_taints`: Set of taints applied to nodes
  - `platform`: Platform type (e.g., "linux")
  - `launch_template_*`: Launch template details (if used)

- **`eks_managed_node_groups_autoscaling_group_names`**: List of all Auto Scaling group names

- **`fargate_profiles`**: Map of Fargate profiles (if configured)

- **`kms_key_arn`** / **`kms_key_id`** / **`kms_key_policy`**: KMS encryption key details

- **`node_security_group_arn`** / **`node_security_group_id`**: Node security group details

- **`oidc_provider`** / **`oidc_provider_arn`**: OIDC provider details

- **`self_managed_node_groups`** / **`self_managed_node_groups_autoscaling_group_names`**: Self-managed node groups (if configured)

### `cluster_network`

Network configuration output containing both internal and external network details.

- **`internal`**: Internal network configuration (when using module-managed VPC):
  - **`network`**: List containing VPC network objects with:
    - **Subnet information**:
      - `public_subnets` / `public_subnet_arns` / `public_subnets_cidr_blocks`: Public subnet details
      - `private_subnets` / `private_subnet_arns` / `private_subnets_cidr_blocks`: Private subnet details
      - `intra_subnets` / `intra_subnet_arns` / `intra_subnets_cidr_blocks`: Intra-VPC subnet details
      - `database_subnets` / `database_subnet_arns` / `database_subnets_cidr_blocks`: Database subnet details
      - Subnet objects with full details (IDs, ARNs, availability zones, CIDR blocks, tags, etc.)
    - **Route tables**: IDs and association IDs for public, private, intra, and database subnets
    - **NAT Gateways**: IDs, interface IDs, Elastic IP allocation IDs, and public IPs
    - **Internet Gateway**: ID and ARN
    - **VPC details**: ID, ARN, CIDR block, DNS settings, owner ID, main route table ID
    - **Availability zones**: List of AZs used
  - **`vpc_endpoints`**: List of VPC endpoint configurations with security group details

- **`external`**: External network configuration (when using existing VPC):
  - `vpc_id`: VPC ID
  - `node_subnet_ids`: Subnet IDs for worker nodes
  - `control_plane_subnet_ids`: Subnet IDs for control plane

### `cluster_storage_classes`

Map of storage class configurations. Contains:

- **`default`**: List of default storage classes (e.g., `standard`, `golden`, `platinum`). Each storage class includes:
  - `id`: Storage class name
  - `allow_volume_expansion`: Whether volume expansion is allowed
  - `reclaim_policy`: Policy (e.g., "Retain")
  - `volume_binding_mode`: Binding mode (e.g., "WaitForFirstConsumer")
  - `storage_provisioner`: Provisioner (e.g., "ebs.csi.aws.com")
  - `parameters`: Map of storage class parameters (e.g., `type`, `encrypted`, `csi.storage.k8s.io/fstype`)
  - `metadata`: List containing Kubernetes metadata (annotations, labels, name, etc.)

- **`additional`**: List of additional custom storage classes (if configured)

### `cluster_autoscaler_resources`

Autoscaler resource names for use by cluster users. Contains:

- **`default`**: Default autoscaler resources:
  - `ec2_node_class`: Name of the default EC2NodeClass resource
  - `node_pool`: Name of the default NodePool resource

These can be referenced in Kubernetes manifests to use the default autoscaler configuration.

### `cluster_ssm_params_paths`

SSM Parameter Store paths for sensitive values stored by the module. Contains:

- **`prometheus_stack`**: Prometheus/Grafana stack credentials:
  - `grafana_root_username`: SSM parameter path for Grafana admin username
  - `grafana_root_password`: SSM parameter path for Grafana admin password

Use these paths to retrieve credentials from AWS Systems Manager Parameter Store.

### Sensitive Outputs

The following outputs are marked as sensitive and contain Helm chart values or deployment configurations:

- **`cluster_autoscaler`**: Complete autoscaler (Karpenter) Helm chart values and deployment configuration
- **`cluster_descheduler`**: Descheduler Helm chart values and deployment configuration
- **`cluster_ingresses`**: Ingress controller configurations:
  - `private`: Private ingress controller details:
    - `values`: Helm chart values
    - `hostname`: Load balancer hostname
  - `public`: Public ingress controller details:
    - `values`: Helm chart values
    - `hostname`: Load balancer hostname
- **`cluster_logging`**: Logging stack configuration:
  - `storage`: Grafana Loki storage configuration (Helm values)
  - `collector`: Promtail collector configuration (Helm values)
- **`cluster_monitoring`**: Prometheus/Grafana monitoring stack Helm chart values and configuration
- **`cluster_node_rebooter`**: Node rebooter/patcher Helm chart values and configuration

**Note**: These sensitive outputs contain complete Helm chart configurations and should be handled carefully. They are primarily useful for debugging or when you need to reference specific deployment details in other Terraform configurations.

