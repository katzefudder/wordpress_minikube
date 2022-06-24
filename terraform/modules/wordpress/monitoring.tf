resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name        = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace = kubernetes_namespace.prometheus.metadata.0.name
}

resource "kubernetes_manifest" "monitor-wordpress" {
  depends_on = [
    helm_release.prometheus
  ]
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "name"      = "wordpress-monitor"
      "namespace" = kubernetes_namespace.prometheus.metadata.0.name
      "labels" = {
        "release" = "prometheus"
      }
    }
    "spec" = {
      "selector" = {
        "matchLabels" = local.wordpress_labels
      }
      "namespaceSelector" = {
        "any" = true
      }
      "endpoints" = [{
        "port" = "web"
      }]
    }
  }
}