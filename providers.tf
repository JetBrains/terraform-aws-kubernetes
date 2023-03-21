provider "aws" {
  region = local.region
  default_tags {
    tags = local.tags
  }
}

provider "kubernetes" {
  host                   = module.eks.kubernetes_api.url
  cluster_ca_certificate = base64decode(module.eks.kubernetes_api_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this_cluster.token
}

provider "kubectl" {
  host                   = module.eks.kubernetes_api.url
  cluster_ca_certificate = base64decode(module.eks.kubernetes_api_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this_cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.eks.kubernetes_api.url
    cluster_ca_certificate = base64decode(module.eks.kubernetes_api_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this_cluster.token
  }
}