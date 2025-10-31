terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 0.14.8"
}

provider "yandex" {
  zone = var.yandex_zone
}

data "yandex_client_config" "client" {}

provider "helm" {
  kubernetes = {
    host                   = var.kubernetes_cluster_endpoint
    cluster_ca_certificate = var.kubernetes_cluster_cert_data
    token                  = data.yandex_client_config.client.iam_token
  }
}

resource "helm_release" "traefik-ingress" {
  name       = "ms-traefik-ingress"
  chart      = "traefik"
  repository = "https://helm.traefik.io/traefik"
  values = [<<EOF
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      externalTrafficPolicy: Local
  EOF
  ]
}