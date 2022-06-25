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

resource "kubernetes_manifest" "monitor-mysql" {
  depends_on = [
    helm_release.prometheus
  ]
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "name"      = "mysql-monitor"
      "namespace" = kubernetes_namespace.prometheus.metadata.0.name
      "labels" = {
        "release" = "prometheus"
      }
    }
    "spec" = {
      "selector" = {
        "matchLabels" = local.mysql_labels
      }
      "namespaceSelector" = {
        "any" = true
      }
      "endpoints" = [{
        "port" = "exporter"
      }]
    }
  }
}

resource "kubernetes_config_map_v1" "grafana-mysql-exporter" {
  metadata {
    name = "mysql-exporter"
    namespace = kubernetes_namespace.prometheus.metadata.0.name
    annotations = {
      "meta.helm.sh/release-name" = "prometheus"
      "meta.helm.sh/release-namespace" = "prometheus"
    }
    labels = {
      "app" = "kube-prometheus-stack-grafana"
      "app.kubernetes.io/instance" = "prometheus"
      "grafana_dashboard" = 1
      "release" = "prometheus"
    }
  }

  data = {
    "mysql-exporter.json" = "${file("${path.module}/grafana/mysql-exporter.json")}"
  }
}

resource "kubernetes_config_map_v1" "openresty-exporter" {
  metadata {
    name = "openresty-exporter"
    namespace = kubernetes_namespace.prometheus.metadata.0.name
    annotations = {
      "meta.helm.sh/release-name" = "prometheus"
      "meta.helm.sh/release-namespace" = "prometheus"
    }
    labels = {
      "app" = "kube-prometheus-stack-grafana"
      "app.kubernetes.io/instance" = "prometheus"
      "grafana_dashboard" = 1
      "release" = "prometheus"
    }
  }

  data = {
    "mysql-exporter.json" = "${file("${path.module}/grafana/openresty-exporter.json")}"
  }
}