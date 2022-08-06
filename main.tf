terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
  #"dop_v1_f969d9694d14e440b55c69c96f529e65483eaff708b6ba59ae9f3773ad4a044c"
}

resource "digitalocean_kubernetes_cluster" "k8s_gustavo" {
  name   = var.k8s_name
  #"k8s-gustavo-devops"
  region = var.do_region 
  #"nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.23.9-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2    
  }
}

resource "digitalocean_kubernetes_node_pool" "node_premium" {
  cluster_id = digitalocean_kubernetes_cluster.k8s_gustavo.id
  name       = "backend-pool"
  size       = "s-2vcpu-4gb"
  node_count = 2
}

variable "do_token" {}
variable "k8s_name" {}
variable "do_region" {}

output "kube_endpoint" {
  value = digitalocean_kubernetes_cluster.k8s_gustavo.endpoint
}

resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.k8s_gustavo.kube_config.0.raw_config
    filename = "kubeconfig.yaml"
}
