output "eks_extensions_details" {
  description = <<-EOF
    Object with relevant extensions' configuration details.
  EOF
  value = {
    ebs_csi_driver_service_account_name = local.ebs_csi_driver.k8s_service_account
  }
}