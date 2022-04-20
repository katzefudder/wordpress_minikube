# Wordpress on Kubernetes

Infrastructure as Code (IaC): Terraform & Terragrunt

We are extensively using the Kubernetes Provider to talk to the Kubernetes API.
Regarding Kubernetes, we're using Minikube for local demonstration. With a properly configured Kubernetes backend, this wordpress example is supposed to work as well.

[Kubernetes Provider, Terraform](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

## Minikube Hyperkit
[Installation Manual](https://minikube.sigs.k8s.io/docs/drivers/hyperkit/)

## Terraform

Using [Terraform](https://www.terraform.io), one is able to deliver infrastructure as code

## Terragrunt

### tfenv

With **tfenv** you can keep track of what version of Terraform to work with. Simply install it on your Mac using *Brew*

`brew install tfenv`

Install the appropriate version

`tfenv install`

## Terragrunt

### tgenv

With **tgenv** you can keep track of what version of Terragrunt to work with. Simply install it on your Mac using *Brew*

`brew install tgenv`

Install the appropriate version

`tgenv install`

### Installing Hyperkit on a Mac
`brew install hyperkit`

Start with hyperkit

`minikube start --driver=hyperkit`

Make hyperkit the default

`minikube config set driver hyperkit`


Get all Pods

`kubectl get pods -n dev-wordpress`

Get service's URL

`minikube service wordpress-service --url -n dev-wordpress`