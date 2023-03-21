/*
* This file defines the public output interface of this Module.
*/

output "charts_info" {
  description = <<EOF
    List of charts and configurations that are deployed in the cluster.
  EOF
  value       = helm_release.this[*]
}