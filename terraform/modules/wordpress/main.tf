locals {
 wordpress_labels = {
   App = "wordpress"
 }
 mysql_labels = {
   App = "mysql"
 }
 elasticsearch_labels = {
   App = "elasticsearch"
 }
}

resource "kubernetes_persistent_volume" "mysql" {
  metadata {
    name = "mysql-volume"
    labels = {
      "name" = "mysql-volume"
    }
  }
  spec {
    capacity = {
      storage = "10Gi"
    }
    storage_class_name = "default"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "elastic" {
  metadata {
    name = "elastic-volume"
    labels = {
      "name" = "elastic-volume"
    }
  }
  spec {
    capacity = {
      storage = "10Gi"
    }
    storage_class_name = "default"
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/data"
      }
    }
  }
}