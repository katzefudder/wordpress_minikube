resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = "${var.stage}-wordpress"
  }
}

resource "kubernetes_service" "wordpress-service" {
 metadata {
   name = "wordpress-service"
   namespace = kubernetes_namespace.wordpress.metadata.0.name
   labels = local.wordpress_labels
 }
 spec {
   selector = local.wordpress_labels
   port {
     name = "web"
     port        = 8080
     target_port = 8080
   }
 }
}

resource "kubernetes_config_map" "openresty-proxy-conf" {
  metadata {
    name      = "openresty-proxy-conf"
    namespace = kubernetes_namespace.wordpress.metadata.0.name
  }

  data = {
    "proxy.conf" = "${file("${path.module}/openresty/proxy.conf")}"
  }
}

resource "kubernetes_deployment" "wordpress" {
 metadata {
   name = "wordpress"
   labels = local.wordpress_labels
   namespace = kubernetes_namespace.wordpress.metadata.0.name
 }
 spec {
   replicas = 1
   selector {
     match_labels = local.wordpress_labels
   }
   template {
     metadata {
       labels = local.wordpress_labels
     }
     spec {
       container {
         image = "wordpress:php8.0-apache"
         name  = "wordpress"
         port {
            container_port = 80
         }
         env {
            name = "WORDPRESS_DB_HOST"
            value = "mysql-service"
         }
         env {
             name = "WORDPRESS_DB_NAME"
             value = "wordpress"
         }
         env {
            name = "WORDPRESS_DB_USER"
            value = "root"
         }
         env {
           name = "WORDPRESS_DB_PASSWORD"
           value_from {
             secret_key_ref {
               name = "mysql-pass"
               key = "password"
             }
           }
         }
       }
       container {
         image = "ghcr.io/katzefudder/openresty:latest"
         name  = "openresty"
         port {
            container_port = 8080
         }
         volume_mount {
            mount_path = "/etc/nginx/conf.d"
            name       = "openresty-conf"
         }
       }
       volume {
          name = "openresty-conf"
          config_map {
            name = kubernetes_config_map.openresty-proxy-conf.metadata.0.name
          }
        }
     }
   }
 }
}