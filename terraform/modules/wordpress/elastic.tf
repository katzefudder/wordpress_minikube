resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
}

resource "kubernetes_secret" "elastic-pass" {
 metadata {
   name = "elastic-pass"
   namespace = kubernetes_namespace.elasticsearch.metadata.0.name
 }
 data = {
   password = "a12sdf"
 }

 type = "kubernetes.io/basic-auth"
}

resource "kubernetes_service" "kibana" {
 metadata {
   name = "kibana"
   namespace = kubernetes_namespace.elasticsearch.metadata.0.name
   labels = local.elasticsearch_labels
 }
 spec {
    selector = local.elasticsearch_labels
    port {
      name = "kibana"
      port        = 5601
      target_port = 5601
    }
   type = "NodePort"
 }
}

resource "kubernetes_deployment" "kibana" {
 metadata {
   name = "kibana"
   labels = local.elasticsearch_labels
   namespace = kubernetes_namespace.elasticsearch.metadata.0.name
 }
 spec {
   replicas = 1
   selector {
     match_labels = local.elasticsearch_labels
   }
   template {
     metadata {
       labels = local.elasticsearch_labels
     }
     spec {
       container {
         image = "kibana:8.3.1"
         name  = "kibana"
         port {
            container_port = 5601
         }
         env {
            name = "elasticsearch.hosts"
            value = "http://elasticsearch:9200"
         }
       }
     }
   }
 }
}

resource "kubernetes_service" "elasticsearch" {
 metadata {
   name = "elasticsearch"
   namespace = kubernetes_namespace.elasticsearch.metadata.0.name
   labels = local.elasticsearch_labels
 }
 spec {
    selector = local.elasticsearch_labels
    port {
      name = "elastic"
      port        = 9200
      target_port = 9200
    }
    port {
      name = "inter-node"
      port = 9300
      target_port = 9300
    }
   type = "NodePort"
 }
}

resource "kubernetes_stateful_set" "elastic" {
  metadata {
   name = "elastic"
   labels = local.elasticsearch_labels
   namespace = kubernetes_namespace.elasticsearch.metadata.0.name
 }
  spec {
    replicas = 1
    selector {
     match_labels = local.elasticsearch_labels
   }

    service_name = "elastic"

    template {
      metadata {
        labels = local.elasticsearch_labels
      }

      spec {
        init_container {
          name = "ownership"
          image = "alpine"
          command = ["chown", "-R", "1000:1000", "/usr/share/elasticsearch/data"]
          volume_mount {
            name = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        container {
          image = "docker.elastic.co/elasticsearch/elasticsearch:8.3.1"
          name  = "elastic"
          port {
            container_port = 9200
          }
          env {
           name = "ELASTIC_PASSWORD"
           value_from {
             secret_key_ref {
               name = "elastic-pass"
               key = "password"
             }
           }
         }
         env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms512m -Xmx512m"
        }
        env {
          name = "discovery.type"
          value = "single-node"
        }
        env {
          name = "xpack.security.enabled"
          value = "false"
        }

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }

        termination_grace_period_seconds = 10
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "default"

        resources {
          requests = {
            storage = "100Mi"
          }
        }

        selector {
          match_labels = {
            name = "elastic-volume"
          }
        }
      }
    }
  }
}