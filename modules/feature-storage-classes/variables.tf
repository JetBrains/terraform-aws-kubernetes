
variable "cluster_default_storage_storage_classes" {
  type = map(object({
    name                   = optional(string)
    annotations            = optional(any)
    reclaim_policy         = optional(string)
    volume_binding_mode    = optional(string)
    allow_volume_expansion = optional(bool)
    parameters             = optional(any)
  }))
  description = "The default standard storage class type for the current Kubernetes cluster"
  default = {
    standard = {
      name = "standard"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" : "true"
      }
      reclaim_policy         = "Retain"
      volume_binding_mode    = "WaitForFirstConsumer"
      allow_volume_expansion = true
      parameters = {
        encrypted : true
        type : "gp3"
        "csi.storage.k8s.io/fstype" : "ext3"
        allowAutoIOPSPerGBIncrease : true
      }
    }
    golden = {
      name = "golden"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" : "false"
      }
      reclaim_policy         = "Retain"
      volume_binding_mode    = "WaitForFirstConsumer"
      allow_volume_expansion = true
      parameters = {
        encrypted : true
        type : "io1"
        "csi.storage.k8s.io/fstype" : "ext3"
        allowAutoIOPSPerGBIncrease : true
      }
    }
    platinum = {
      name = "platinum"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" : "false"
      }
      reclaim_policy         = "Retain"
      volume_binding_mode    = "WaitForFirstConsumer"
      allow_volume_expansion = true
      parameters = {
        encrypted : true
        type : "io2"
        "csi.storage.k8s.io/fstype" : "xfs"
        allowAutoIOPSPerGBIncrease : true
      }
    }
  }
}

variable "cluster_custom_storage_classes" {
  type = map(object({
    name                   = optional(string)
    annotations            = optional(any)
    reclaim_policy         = optional(string)
    volume_binding_mode    = optional(string)
    allow_volume_expansion = optional(bool)
    storage_provisioner    = optional(string)
    parameters             = optional(any)
  }))
  description = "Custom storage class objects for the current Kubernetes cluster that can be created in addition of as a substitution for the ones defined in the cluster_default_storage_storage_classes variable"
  default     = {}
}