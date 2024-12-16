output "cluster_network" {
  description = "Configuration of the internal network"
  value = {
    internal = {
      network       = try(coalesce(module.internal_network.*, null), {})
      vpc_endpoints = try(coalesce(module.internal_network_vpc_endpoints.*, null), {})
    }
    external = {
      vpc_id                   = try(coalesce(var.cluster_network_external_vpc_id, null), null)
      node_subnet_ids          = try(coalesce(var.cluster_network_external_node_subnet_ids, null), null)
      control_plane_subnet_ids = try(coalesce(var.cluster_network_external_control_plane_subnet_ids, null), null)
    }
  }
}

output "cluster" {
  description = "Configuration of the Kubernetes cluster"
  value       = module.kubernetes.*
}

output "cluster_storage_classes" {
  description = "Storage classes for the Kubernetes cluster"
  value       = var.cluster_storage_classes_create ? module.cluster_storage_classes[0].cluster_storage_classes : {}
}

output "cluster_monitoring" {
  description = "Monitoring configuration for the Kubernetes cluster"
  sensitive   = true
  value       = var.cluster_monitoring_create ? module.cluster_monitoring[0].values : null
}

output "cluster_node_rebooter" {
  description = "Node rebooter configuration for the Kubernetes cluster"
  sensitive   = true
  value       = var.cluster_node_patcher_create ? module.kube_node_patcher[0].values : null
}

output "cluster_logging" {
  description = "Cluster logging configuration for the Kubernetes cluster"
  sensitive   = true
  value = {
    storage   = var.cluster_logging_create ? module.cluster_logging[0].values : null
    collector = var.cluster_logging_create ? module.cluster_logging_collector[0].values : null
  }
}

output "cluster_ingresses" {
  description = "Ingresses for the Kubernetes cluster"
  sensitive   = true
  value = {
    private = {
      values   = var.cluster_private_ingress_create ? module.cluster_private_ingress_controller[0].values : null
      hostname = var.cluster_private_ingress_create ? data.kubernetes_service_v1.kube_private_ingress_svc_url[0].status.0.load_balancer.0.ingress.0.hostname : null
    }
    public = {
      values   = var.cluster_public_ingress_create ? module.cluster_public_ingress_controller[0].values : null
      hostname = var.cluster_public_ingress_create ? data.kubernetes_service_v1.kube_public_ingress_svc_url[0].status.0.load_balancer.0.ingress.0.hostname : null
    }
  }
}

output "cluster_descheduler" {
  description = "Descheduler configuration for the Kubernetes cluster"
  sensitive   = true
  value       = var.cluster_descheduler_create ? module.kube_descheduler[0].values : null
}

output "cluster_additional_apps" {
  description = "Additional apps' configurations"
  sensitive   = true
  value       = var.cluster_additional_apps_create ? module.additional_apps[0].values : null
}

output "cluster_ssm_params_paths" {
  description = "SSM parameters paths exported by the module for the Kubernetes cluster"
  value = {
    prometheus_stack = {
      grafana_root_username = var.cluster_monitoring_create ? local.ssm_path_for_grafana_admin_user : null
      grafana_root_password = var.cluster_monitoring_create ? local.ssm_path_for_grafana_admin_password : null
    }
  }
}

output "cluster_autoscaler" {
  description = "Autoscaler configuration for the Kubernetes cluster"
  sensitive   = true
  value       = var.cluster_autoscaler_create ? module.kube_node_autoscaler[0].values : null
}

output "cluster_autoscaler_resources" {
  description = "Autoscaler resources for the Kubernetes cluster to be used by Cluster Users"
  value = {
    default = {
      ec2_node_class = var.cluster_autoscaler_create ? kubectl_manifest.default_ec2_node_class[0].name : null
      node_pool      = var.cluster_autoscaler_create ? kubectl_manifest.default_node_pool[0].name : null
    }
  }
}

#output "debug" {
#  sensitive = true
#  value = module.cluster_private_ingress_controller.*
#}