resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.tiller_service_account_name
    namespace = var.tiller_namespace

    labels = {
      "app.kubernetes.io/name"       = "helm"
      "app.kubernetes.io/component"  = "tiller"
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      "field.cattle.io/description" = "Helm Package Manager: required server-side component"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name = "tiller"

    labels = {
      "app.kubernetes.io/name"       = "helm"
      "app.kubernetes.io/component"  = "tiller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = kubernetes_service_account.this.metadata[0].namespace
  }
}

resource "kubernetes_secret" "this_tls" {
  count = var.tiller_tls.enabled ? 1 : 0

  metadata {
    name      = "tiller-secrets"
    namespace = var.tiller_namespace

    labels = {
      "app.kubernetes.io/name"       = "helm"
      "app.kubernetes.io/component"  = "tiller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    "tls.key" = var.tiller_tls.private_key_pem
    "tls.crt" = var.tiller_tls.cert_pem
    "ca.crt"  = var.tiller_tls.ca_cert_pem
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = "tiller-deploy"
    namespace = var.tiller_namespace

    labels = {
      "app.kubernetes.io/name"       = "helm"
      "app.kubernetes.io/component"  = "tiller"
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/version"    = var.tiller_version
    }

    annotations = {
      "field.cattle.io/description" = "Helm Package Manager: required server-side component"
    }
  }

  spec {
    replicas = 1
    strategy {
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "helm"
        "app.kubernetes.io/component" = "tiller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "helm"
          "app.kubernetes.io/component" = "tiller"
          "app.kubernetes.io/version"   = var.tiller_version

          # helm uses these pod labels to find tiller, so they must be set:
          app  = "helm"
          name = "tiller"

          version = var.tiller_version
        }
      }

      spec {

        dynamic "affinity" {
          for_each = length(var.node_selectors) > 0 ? ["placeholder"] : []
          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                dynamic "node_selector_term" {
                  for_each = var.node_selectors
                  content {
                    match_expressions {
                      key      = node_selector_term.key
                      operator = "In"
                      values   = [node_selector_term.value]
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "toleration" {
          for_each = var.tolerations
          content {
            key      = toleration.value["key"]
            operator = toleration.value["operator"]
            value    = toleration.value["value"]
            effect   = toleration.value["effect"]
          }
        }

        automount_service_account_token = true

        dynamic "volume" {
          for_each = [for enabled in [var.tiller_tls.enabled] : enabled if enabled]

          content {
            name = "tiller-certs"
            secret {
              secret_name = kubernetes_secret.this_tls[0].metadata.0.name
            }
          }
        }

        #priority_class_name = "system-cluster-critical"
        service_account_name = kubernetes_service_account.this.metadata[0].name

        container {
          env {
            name  = "TILLER_NAMESPACE"
            value = var.tiller_namespace
          }

          env {
            name  = "TILLER_HISTORY_MAX"
            value = var.tiller_history_max
          }

          env {
            name  = "TILLER_STORAGE"
            value = var.tiller_storage
          }

          env {
            name  = "TILLER_TLS_ENABLE"
            value = var.tiller_tls.enabled ? "1" : ""
          }

          env {
            name  = "TILLER_TLS_VERIFY"
            value = var.tiller_tls.enabled && var.tiller_tls.verify ? "1" : ""
          }

          env {
            name  = "TILLER_TLS_CERTS"
            value = "/var/run/tiller/certs"
          }

          dynamic "volume_mount" {
            for_each = [for enabled in [var.tiller_tls.enabled] : enabled if enabled]

            content {
              name       = "tiller-certs"
              mount_path = "/var/run/tiller/certs"
              read_only  = true
            }
          }

          image             = "gcr.io/kubernetes-helm/tiller:v${var.tiller_version}"
          image_pull_policy = var.tiller_image_pull_policy

          liveness_probe {
            http_get {
              path = "/liveness"
              port = 44135
            }

            initial_delay_seconds = 1
            timeout_seconds       = 1
          }

          name = "tiller"

          port {
            container_port = 44134
            name           = "tiller"
          }

          port {
            container_port = "44135"
            name           = "http"
          }

          readiness_probe {
            http_get {
              path = "/readiness"
              port = 44135
            }

            initial_delay_seconds = 1
            timeout_seconds       = 1
          }

          resources {
          }
        }

        node_selector = var.tiller_pod_node_selector
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "helm"
      "app.kubernetes.io/component"  = "tiller"
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      "field.cattle.io/description" = "Helm Package Manager: required server-side component"
    }

    name      = "tiller-deploy"
    namespace = var.tiller_namespace
  }

  spec {
    port {
      name        = "tiller"
      port        = 44134
      target_port = "tiller"
    }

    selector = {
      "app.kubernetes.io/name"      = "helm"
      "app.kubernetes.io/component" = "tiller"
      "app.kubernetes.io/version"   = var.tiller_version
    }

    type = var.tiller_service_type
  }
}

