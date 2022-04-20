locals {
  environment_vars = jsondecode(file("${path_relative_to_include()}/params.json"))
  stage            = local.environment_vars.environment
}

# Generate an k8s provider block. You can run `minikube ip` to get the local ip address.
# And run `minikube config view` to get the certificates and key
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "2.10.0"
        }
      }
    }

    provider "kubernetes" {
      config_path = "~/.kube/config"
    }
    provider "kubernetes" {
      alias = "github"
      config_path = "~/runner/.minikube/config"
    }
EOF
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_original_terragrunt_dir()}/terraform.tfstate"
  }
}

terraform {
    source = "../../terraform//modules/wordpress/"
}

inputs = merge (
  local.environment_vars,
  local
)