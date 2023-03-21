locals {
  name = "how-to-deploy-k8s-apps"
  tags = {
    Purpose = "Demo"
  }
  helm_values_as_strings = {
    space_on_premises_secrets = {
      packages_oauth = {
        clientId     = "space-to-packages"
        clientSecret = "0tXJDEQ2nwMyxiX+1hOCFaiu"
      }
      database_creds = {
        username = "spaceServiceAccount"
        password = "password"
      }
      object_storage_creds = {
        accessKey = "spaceServiceAccount"
        secretKey = "password"
      }
    }
    space_on_premises_config = <<VALUES
space:
  replicaCount: 2
  ingress:
    ingressClassName: public-ingress-nginx
    hostname: "space.jetbrains.local"
    enabled: true
    selfSigned: true
    tls: true
  localAdministrator:
    firstName: "Administrator"
    lastName: "Administrator"
    email: "admin@jetbrains.local"
  database:
    name: "space"
    hostname: "space-dependencies-postgresql-hl"
    port: "5432"
  organization:
    name: "PlutoPlanet"
    slogan: "Barking!"
  eventbus:
    hostname: "space-dependencies-redis-headless"
    port: "6379"
  objectStorage:
    region: "eu-west-1"
    bucketName: "space-packages"
    url: "http://space-dependencies-minio:9000"
  mail:
    enabled: true
    hostname: "space-dependencies-mailhog"
    port: "1025"
    settings:
      fromAddress: "space@space.jetbrains.local"
  elastic:
    search:
      hostname: "space-dependencies-elasticsearch"
      port: "9200"
    audit:
      hostname: "space-dependencies-elasticsearch"
      port: "9200"
    metrics:
      hostname: "space-dependencies-elasticsearch"
      port: "9200"
  externalUrl: "https://space.jetbrains.local"
  altUrls: "https://space.jetbrains.local"
  packages:
    externalUrl: "https://packages.jetbrains.local"
  automation:
    logs:
      storage:
        region: "eu-west-1"
        bucketName: "space-packages"
        url: "http://space-dependencies-minio:9000"
    worker:
      storage:
        region: "eu-west-1"
        bucketName: "space-packages"
        url: "http://space-dependencies-minio:9000"
    dslCompiler:
      storage:
        region: "eu-west-1"
        bucketName: "space-packages"
        url: "http://space-dependencies-minio:9000"
packages:
  replicaCount: 2
  ingress:
    enabled: true
    selfSigned: true
    tls: true
    ingressClassName: public-ingress-nginx
  database:
    name: "space"
    hostname: "space-dependencies-postgresql-hl"
    port: "5432"
  eventbus:
    hostname: "space-dependencies-redis-headless"
    port: "6379"
  objectStorage:
    region: "eu-west-1"
    bucketName: "space-packages"
    url: "http://space-dependencies-minio:9000"
  elastic:
    search:
      hostname: "space-dependencies-elasticsearch"
      port: "9200"
  externalUrl: "https://packages.jetbrains.local"
  space:
    externalUrl: "https://space.jetbrains.local"
vcs:
  replicaCount: 2
  storage:
    eventbus:
      hostname: "space-dependencies-redis-headless"
      port: "6379"
    objectStorage:
      region: "eu-west-1"
      bucketName: "space-vcs"
      url: "http://space-dependencies-minio:9000"
    database:
      name: "space"
      hostname: "space-dependencies-postgresql-hl"
      port: "5432"
  externalUrl: "http://git.jetbrains.local"
  spaceExternalUrl: "http://space.jetbrains.local"
  ingress:
    enabled: true
    selfSigned: true
    tls: true
    ingressClassName: public-ingress-nginx
  externalService:
    enabled: false
langservice:
  replicaCount: 2
VALUES
  }
}

module "kubernetes_cluster" {
  source = "../.."

  kubernetes_cluster_services_configs = {
    kube_public_ingress_set_values = [
      {
        name  = "tcp.12222"
        value = "kube-space/space-vcs:12222"
      }
    ]
    //kube_private_ingress_set_values = []
  }

  kubernetes_packages_as_helm_charts = [
    {
      namespace  = "kube-space"
      repository = "https://charts.on-premises.service.jetbrains.space/library"
      app = {
        name             = "space-dependencies"
        chart            = "space-dependencies"
        version          = "1.2.4"
        create_namespace = true
      }
      params = [{
        name  = "mailhog.ingress.ingressClassName"
        value = "private-ingress-nginx"
      }]
    },
    {
      namespace  = "kube-space-two"
      repository = "https://charts.on-premises.service.jetbrains.space/library"
      app = {
        name             = "space-dependencies"
        chart            = "space-dependencies"
        version          = "1.2.4"
        create_namespace = true
      }
      params = [{
        name  = "mailhog.ingress.ingressClassName"
        value = "public-ingress-nginx"
      }]
    },
    {
      namespace  = "kube-space"
      repository = "https://charts.on-premises.service.jetbrains.space/stable"
      app = {
        name             = "space"
        chart            = "space"
        version          = "2023.1.1"
        create_namespace = true
      }
      secrets = [
        {
          name  = "space.masterSecret"
          value = "OsUqo2xU4IFcdCbPq7sBvvvHWOifNAfevbYiV4B1ijE="
        },
        {
          name  = "space.webHookSecret"
          value = "9EUAuhrmm67CIQLatlQsl5StKZLy8Cs/x7yGLuSl9Dk="
        },
        {
          name  = "space.localAdministrator.username"
          value = "admin"
        },
        {
          name  = "space.localAdministrator.password"
          value = "password"
        },
        {
          name  = "space.oauth.messageEncodingKey"
          value = "eYYQev+ddnWC1xMJUHVQrg=="
        },
        {
          name  = "space.oauth.encodingKey2fa"
          value = "RsAHT3kfCF+UxxVFRMDFsQ=="
        },
        {
          name  = "space.oauth.encodingKey"
          value = "sHjoL4D451laQKjRvyNPiA=="
        },
        {
          name  = "space.oauth.messageSigningRsaPublic"
          value = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwxUlzjAFnwVqVnCHnFvcMmOE8e4uFKYc5Q5fKjdhldwwIA3BObn5LJAmOHGj0FFzcRu9/kQtYOzKIoi1ZfVX8MbR4Y8CQp/006sB+dO0m+mmgU15PhNjqqtMuk4m6wq049F0bsG4cZVQMBZvoeDmdrMVzEzxtmajrXD2ssOhH4gtVthhoW2vXTl0FXlJ518eKMv0+IBtUdehmY3br7ENaakAZ7bUSdiHrg5uGK0sMQgohrO/TNHbA7hhXqOOkNcEn7NOg5CUecAQkG9+ZVBrC/KoUl5bY+sH/ux8dgf1R75v6kAva4zfGmBeJ1BRl/woJH/u05um8OiBTiE4tfQsIsIHH2i9/D46JxZ40xaNjQmosG+VnhpPaqnqgI9PtYPbszmzhu3kSUz/s20ERY7nUtxtf1PRK8GQyy+EuHGlHhXmu2Cis3udpVt38P4UENAulgzr6vztRuz2wr/vCYAPLcjJ0zu33GQnASMwi3FvAihirppovepsyWTkyJOlSt0rpsEKJS5IicC7Dpn33OmFWopUfhZA/U+fmMW5fwGLIcAarp0AzLwa3WOlLUZVh0AqkIRJrWasqYaaV+ztrVCMWRzpfigBhrVeCOHnxspZdMWQ7icJVzZUvHVysiPYCVaM1xYWDIWK9H+cEo+zu58bW4W07JNiXTyr0xZWd6KPEpcCAwEAAQ=="
        },
        {
          name  = "space.oauth.messageSigningRsaPrivate"
          value = "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"
        },
        {
          name  = "space.oauth.accessTokenRsaPublic"
          value = "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAu14kYtanAf90khvYWopHccYg2oSDYkhqq7Thz2PLnjqVvMXQ3aNn2HnjtwTgUzko5aWro/vN6xVyHXHLp3fqHQo9jorekJKH0zHMXEAqqTVVBJb7z0T4aI/gJyVEYi/CuP9PbcmUr6bij+/6sL6R1ZjSsc220ZK2S++Oz/rJ34lVjDiaZzitGP16IfQg9OJ54TEB+mOxX9/SeTnQ5zAoblJ3WdqxjkNfv9HU9PSr3z/9lC2DiynEjZdtOlep8W4lWN5MXWR0jvGQD2ATTWwbnAm0EySLZejlSVFejtyEnZQxllqVZ9cAbfp23O8f1FwdPnV/uNIwWOAdI8rUJbcAcP63FnW4wgK/VjZO553I3+f47Wj20Xq7fR4ZITKhhf6tlFb8+mdBaqHlLsDAzMV/tnh9fnZbcbqnUG/5PRfIyPyq8mLsbcX7pwAIfMVp66bq4xtULl2q9CCu+hFDoLjHB2sqySDLTBTQuuOBvViCqtFnW8u4Q+bypsmv2RW8be0Yegd9GdE358q4rbBpMuvjSMFW4v1ma8MPSyNQM1wfg0JgOY6TiUU9hUB2nuUCYOuBMNfHjCFUcw+qnMPKHI/YaMlzjKHDpN+A8ZW26ONYYfzReQOk8RI/LniBwlruM9i9h5AOIEUtcBWTWCZXWvR6gESGzUlllK6pTBTgy+T8TwMCAwEAAQ=="
        },
        {
          name  = "space.oauth.accessTokenRsaPrivate"
          value = "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"
        },
        {
          name  = "space.mail.username"
          value = "space"
        },
        {
          name  = "space.mail.password"
          value = "password"
        },
        {
          name  = "space.vcs.token"
          value = "mPF5ic9kqBxkNoCvJX6fnjETUyi0kM7gZ7JZL2BWyU4="
        },
        {
          name  = "space.packages.oauth.clientId"
          value = "space-to-packages"
        },
        {
          name  = "space.packages.oauth.clientSecret"
          value = "0tXJDEQ2nwMyxiX+1hOCFaiu"
        },
        {
          name  = "packages.oauth.clientId"
          value = local.helm_values_as_strings.space_on_premises_secrets.packages_oauth.clientId
        },
        {
          name  = "packages.oauth.clientSecret"
          value = local.helm_values_as_strings.space_on_premises_secrets.packages_oauth.clientSecret
        },
        {
          name  = "vcs.secrets.spaceAccessKey"
          value = "mPF5ic9kqBxkNoCvJX6fnjETUyi0kM7gZ7JZL2BWyU4="
        },
        {
          name  = "space.database.username"
          value = local.helm_values_as_strings.space_on_premises_secrets.database_creds.username
        },
        {
          name  = "space.database.password"
          value = local.helm_values_as_strings.space_on_premises_secrets.database_creds.password
        },
        {
          name  = "space.objectStorage.accessKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.accessKey
        },
        {
          name  = "space.objectStorage.secretKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.secretKey
        },
        {
          name  = "space.automation.logs.storage.accessKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.accessKey
        },
        {
          name  = "space.automation.logs.storage.secretKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.secretKey
        },
        {
          name  = "space.automation.worker.storage.accessKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.accessKey
        },
        {
          name  = "space.automation.worker.storage.secretKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.secretKey
        },
        {
          name  = "space.automation.dslCompiler.storage.accessKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.accessKey
        },
        {
          name  = "space.automation.dslCompiler.storage.secretKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.secretKey
        },
        {
          name  = "packages.database.username"
          value = local.helm_values_as_strings.space_on_premises_secrets.database_creds.username
        },
        {
          name  = "packages.database.password"
          value = local.helm_values_as_strings.space_on_premises_secrets.database_creds.password
        },
        {
          name  = "packages.objectStorage.accessKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.accessKey
        },
        {
          name  = "packages.objectStorage.secretKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.secretKey
        },
        {
          name  = "vcs.storage.database.username"
          value = local.helm_values_as_strings.space_on_premises_secrets.database_creds.username
        },
        {
          name  = "vcs.storage.database.password"
          value = local.helm_values_as_strings.space_on_premises_secrets.database_creds.password
        },
        {
          name  = "vcs.storage.objectStorage.accessKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.accessKey
        },
        {
          name  = "vcs.storage.objectStorage.secretKey"
          value = local.helm_values_as_strings.space_on_premises_secrets.object_storage_creds.secretKey
        },
      ]
      values = local.helm_values_as_strings.space_on_premises_config
    }
  ]

  name = local.name
  tags = local.tags
}
