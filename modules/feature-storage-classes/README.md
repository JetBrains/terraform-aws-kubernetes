<!-- BEGIN_TF_DOCS -->
# terraform-feature-storage-classes

This module creates StorageClass resources into a Kubernetes cluster. 

## Requirements

No requirements.
## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
## Resources

| Name | Type |
|------|------|
| [kubernetes_storage_class_v1.custom](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_custom_storage_classes"></a> [cluster\_custom\_storage\_classes](#input\_cluster\_custom\_storage\_classes) | Custom storage class objects for the current Kubernetes cluster that can be created in addition of as a substitution for the ones defined in the cluster\_default\_storage\_storage\_classes variable | <pre>map(object({<br/>    name                   = optional(string)<br/>    annotations            = optional(any)<br/>    reclaim_policy         = optional(string)<br/>    volume_binding_mode    = optional(string)<br/>    allow_volume_expansion = optional(bool)<br/>    storage_provisioner    = optional(string)<br/>    parameters             = optional(any)<br/>  }))</pre> | `{}` | no |
| <a name="input_cluster_default_storage_storage_classes"></a> [cluster\_default\_storage\_storage\_classes](#input\_cluster\_default\_storage\_storage\_classes) | The default standard storage class type for the current Kubernetes cluster | <pre>map(object({<br/>    name                   = optional(string)<br/>    annotations            = optional(any)<br/>    reclaim_policy         = optional(string)<br/>    volume_binding_mode    = optional(string)<br/>    allow_volume_expansion = optional(bool)<br/>    parameters             = optional(any)<br/>  }))</pre> | <pre>{<br/>  "golden": {<br/>    "allow_volume_expansion": true,<br/>    "annotations": {<br/>      "storageclass.kubernetes.io/is-default-class": "false"<br/>    },<br/>    "name": "golden",<br/>    "parameters": {<br/>      "allowAutoIOPSPerGBIncrease": true,<br/>      "csi.storage.k8s.io/fstype": "ext3",<br/>      "encrypted": true,<br/>      "type": "io1"<br/>    },<br/>    "reclaim_policy": "Retain",<br/>    "volume_binding_mode": "WaitForFirstConsumer"<br/>  },<br/>  "platinum": {<br/>    "allow_volume_expansion": true,<br/>    "annotations": {<br/>      "storageclass.kubernetes.io/is-default-class": "false"<br/>    },<br/>    "name": "platinum",<br/>    "parameters": {<br/>      "allowAutoIOPSPerGBIncrease": true,<br/>      "csi.storage.k8s.io/fstype": "xfs",<br/>      "encrypted": true,<br/>      "type": "io2"<br/>    },<br/>    "reclaim_policy": "Retain",<br/>    "volume_binding_mode": "WaitForFirstConsumer"<br/>  },<br/>  "standard": {<br/>    "allow_volume_expansion": true,<br/>    "annotations": {<br/>      "storageclass.kubernetes.io/is-default-class": "true"<br/>    },<br/>    "name": "standard",<br/>    "parameters": {<br/>      "allowAutoIOPSPerGBIncrease": true,<br/>      "csi.storage.k8s.io/fstype": "ext3",<br/>      "encrypted": true,<br/>      "type": "gp3"<br/>    },<br/>    "reclaim_policy": "Retain",<br/>    "volume_binding_mode": "WaitForFirstConsumer"<br/>  }<br/>}</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_storage_classes"></a> [cluster\_storage\_classes](#output\_cluster\_storage\_classes) | Cluster storage classes of the Kubernetes cluster |
<!-- END_TF_DOCS -->