# Adding this file to pass the TFLINT checks

output "values" {
  value     = module.example_full_internal_network.*
  sensitive = true
}