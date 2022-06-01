resource "kubernetes_service" "wordpress-service" {
 metadata {
   name = "wordpress-service"
   namespace = kubernetes_namespace.wordpress.metadata.0.name
 }
 spec {
   selector = local.wordpress_labels
   port {
     port        = 80
     target_port = 80
   }
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
     }
   }
 }
}