locals {
  title = "kube-ingress-proxy"
  tags = {
    DeploymentType = "Example"
  }
  /*
    TODO: The example below tries to configure multiple protocols for the TCP proxy. TCP and UDP.

  */
  kube_private_ingress_set_values = [
    {
      name  = "tcp.8080"
      value = "default/not-existent:8888"
    },
    {
      name  = "tcp.8081"
      value = "kube-system/not-existent:8888"
    }
  ]
  kube_public_ingress_set_values = [
    /*
     NOTE: this is not supported by the Ingress Controller
        {
          name  = "tcp.12222"
          value = "default/my-vcs:22"
        },
        {
          name  = "udp.53"
          value = "kube-system/kube-dns:53"
        }
       When setting the above values the following errors happen.
          module.eks_minimal.module.k8s_cluster_services.helm_release.this[2]: Creation complete after 44s [id=ingress-nginx]
        ╷
        │ Warning: Helm release "ingress-nginx" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
        │
        │   with module.eks_minimal.module.k8s_cluster_services.helm_release.this[1],
        │   on ../../modules/k8s-helm-packages/main.tf line 10, in resource "helm_release" "this":
        │   10: resource "helm_release" "this" {
        │
        │ Error: Service "private-ingress-nginx-controller" is invalid: spec.ports: Invalid value: []core.ServicePort{core.ServicePort{Name:"http", Protocol:"TCP", AppProtocol:(*string)(nil), Port:80, TargetPort:intstr.IntOrString{Type:1, IntVal:0, StrVal:"http"}, NodePort:30630}, core.ServicePort{Name:"https", Protocol:"TCP", AppProtocol:(*string)(nil), Port:443, TargetPort:intstr.IntOrString{Type:1, IntVal:0, StrVal:"https"}, NodePort:31654}, core.ServicePort{Name:"8080-tcp", Protocol:"TCP", AppProtocol:(*string)(nil), Port:8080, TargetPort:intstr.IntOrString{Type:1, IntVal:0, StrVal:"8080-tcp"}, NodePort:30092}, core.ServicePort{Name:"53-udp", Protocol:"UDP", AppProtocol:(*string)(nil), Port:53, TargetPort:intstr.IntOrString{Type:1, IntVal:0, StrVal:"53-udp"}, NodePort:30453}}: may not contain more than 1 protocol when type is 'LoadBalancer'
        │
        │   with module.eks_minimal.module.k8s_cluster_services.helm_release.this[1],
        │   on ../../modules/k8s-helm-packages/main.tf line 10, in resource "helm_release" "this":
        │   10: resource "helm_release" "this" {
    */
  ]
}

module "eks_minimal" {
  source = "../.."

  kubernetes_cluster_services_configs = {
    kube_private_ingress_set_values = local.kube_private_ingress_set_values
    kube_public_ingress_set_values  = local.kube_public_ingress_set_values
  }
  name = local.title
  tags = local.tags
}