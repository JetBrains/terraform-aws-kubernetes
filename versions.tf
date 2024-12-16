terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.26.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
