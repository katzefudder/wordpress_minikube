resource "kubernetes_ingress_v1" "wordpress" {
   metadata {
      name        = "wordpress-ingress"
      namespace = kubernetes_namespace.wordpress.metadata.0.name
      annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      }
   }
   spec {
    ingress_class_name = "nginx"
      rule {
        http {
         path {
           path = "/"
           path_type = "Prefix"
           backend {
             service {
               name = "wordpress-service"
               port {
                 number = 80
               }
             }
           }
        }
      }
    }
  }
}