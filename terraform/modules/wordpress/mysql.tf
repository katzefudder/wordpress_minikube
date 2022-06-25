resource "kubernetes_secret" "mysql-pass" {
 metadata {
   name = "mysql-pass"
   namespace = kubernetes_namespace.wordpress.metadata.0.name
 }
 data = {
   password = "root"
 }

 type = "kubernetes.io/basic-auth"
}

resource "kubernetes_service" "mysql-service" {
 metadata {
   name = "mysql-service"
   namespace = kubernetes_namespace.wordpress.metadata.0.name
   labels = local.mysql_labels
 }
 spec {
    selector = local.mysql_labels
    port {
      name = "mysql"
      port        = 3306
      target_port = 3306
    }
    port {
      name = "exporter"
      port        = 9104
      target_port = 9104
    }
   type = "NodePort"
 }
}

resource "kubernetes_stateful_set" "mysql" {
  metadata {
   name = "mysql"
   labels = local.mysql_labels
   namespace = kubernetes_namespace.wordpress.metadata.0.name
 }
  spec {
    replicas = 1
    selector {
     match_labels = local.mysql_labels
   }

    service_name = "mysql"

    template {
      metadata {
        labels = local.mysql_labels
      }

      spec {
        container {
          image = "mysql:8.0.28"
          name  = "mysql"
          port {
            container_port = 3306
          }
          env {
           name = "MYSQL_ROOT_PASSWORD"
           value_from {
             secret_key_ref {
               name = "mysql-pass"
               key = "password"
             }
           }
         }
         env {
             name = "MYSQL_DATABASE"
             value = "wordpress"
         }

          volume_mount {
            name       = "db"
            mount_path = "/var/lib/mysql"
          }
        }

        container {
          image = "prom/mysqld-exporter"
          name = "mysql-exporter"
          port {
            container_port = 9104
          }
          env {
            name = "DATA_SOURCE_NAME"
            value = "root:root@(localhost:3306)/wordpress"
          }
        }

        termination_grace_period_seconds = 10
      }
    }

    volume_claim_template {
      metadata {
        name = "db"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "100Mi"
          }
        }
      }
    }
  }
}