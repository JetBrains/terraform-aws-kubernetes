resource "null_resource" "wait_for_kubernetes_api_be_active" {
  // This resource is a hack. It helps to wait for the EKS cluster to be ready before requesting an Access Token
  // and pass it down to the Helm and Kubernetes providers.
  provisioner "local-exec" {
    command = <<EOT
        until [ "${module.kubernetes.cluster_status}" = "ACTIVE" ]; do
          echo "Waiting for the EKS cluster to be ready..."
          sleep 5
        done
    EOT
  }
  depends_on = [module.kubernetes]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "current" {
  name = split("/", data.aws_caller_identity.current.arn)[1]
}

data "aws_eks_cluster" "this_cluster" {
  name       = module.kubernetes.cluster_name
  depends_on = [null_resource.wait_for_kubernetes_api_be_active]
}

data "aws_eks_cluster_auth" "this_cluster" {
  name       = module.kubernetes.cluster_name
  depends_on = [null_resource.wait_for_kubernetes_api_be_active]
}