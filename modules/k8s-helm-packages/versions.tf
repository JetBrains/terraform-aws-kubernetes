terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.33.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.7.0"
    }
  }
}
