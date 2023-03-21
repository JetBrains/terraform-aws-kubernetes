/**
* A declarative helm chart deployment.
* Ref:
*/

locals {
  charts = var.charts
}

resource "helm_release" "this" {
  count                      = length(local.charts)
  namespace                  = try(local.charts[count.index].namespace, "kube-none")
  repository                 = try(local.charts[count.index].repository, null)
  repository_key_file        = try(lookup(local.charts[count.index].repository_config, "repository_key_file", null), null)
  repository_cert_file       = try(lookup(local.charts[count.index].repository_config, "repository_cert_file", null), null)
  repository_ca_file         = try(lookup(local.charts[count.index].repository_config, "repository_ca_file", null), null)
  repository_username        = try(lookup(local.charts[count.index].repository_config, "repository_username", null), null)
  repository_password        = try(lookup(local.charts[count.index].repository_config, "repository_password", null), null)
  name                       = local.charts[count.index].app["name"]
  version                    = local.charts[count.index].app["version"]
  chart                      = local.charts[count.index].app["chart"]
  force_update               = lookup(local.charts[count.index].app, "force_update", true)
  wait                       = lookup(local.charts[count.index].app, "wait", true)
  recreate_pods              = lookup(local.charts[count.index].app, "recreate_pods", false)
  max_history                = lookup(local.charts[count.index].app, "max_history", 0)
  lint                       = lookup(local.charts[count.index].app, "lint", true)
  cleanup_on_fail            = lookup(local.charts[count.index].app, "cleanup_on_fail", true)
  create_namespace           = lookup(local.charts[count.index].app, "create_namespace", false)
  disable_webhooks           = lookup(local.charts[count.index].app, "disable_webhooks", false)
  verify                     = lookup(local.charts[count.index].app, "verify", true)
  reuse_values               = lookup(local.charts[count.index].app, "reuse_values", false)
  reset_values               = lookup(local.charts[count.index].app, "reset_values", false)
  atomic                     = lookup(local.charts[count.index].app, "atomic", false)
  skip_crds                  = lookup(local.charts[count.index].app, "skip_crds", false)
  render_subchart_notes      = lookup(local.charts[count.index].app, "render_subchart_notes", true)
  disable_openapi_validation = lookup(local.charts[count.index].app, "disable_openapi_validation", false)
  wait_for_jobs              = lookup(local.charts[count.index].app, "wait_for_jobs", true)
  dependency_update          = lookup(local.charts[count.index].app, "dependency_update", true)
  replace                    = lookup(local.charts[count.index].app, "replace", false)
  values                     = local.charts[count.index].values != null ? [local.charts[count.index].values] : []

  dynamic "set" {
    iterator = item
    for_each = local.charts[count.index].params == null ? [] : local.charts[count.index].params

    content {
      name  = item.value.name
      value = item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = item
    for_each = local.charts[count.index].secrets == null ? [] : local.charts[count.index].secrets

    content {
      name  = item.value.name
      value = item.value.value
    }
  }

  # Exception:
  # This resource does not support tags.
}
