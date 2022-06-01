resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = "${var.stage}-${var.namespace}"
  }
}

locals {
 wordpress_labels = {
   App = "wordpress"
 }
 mysql_labels = {
   App = "wordpress"
 }
}

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