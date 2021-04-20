#Helm install of sample "hello world" app on IKS
data "terraform_remote_state" "iksws" {
  backend = "remote"
  config = {
    organization = "CiscoDevNet"
    workspaces = {
      name = var.ikswsname 
    }
  }
}

variable "ikswsname" {
  type = string
}

resource helm_release nginx_ingress {
  name       = "iwok8scollector"

  repository = "https://falkor.tesseractinternal.com/platform-ui"
  repository_username = "dragonfly" 
  repository_password = "[>r}WjuW+og{L1r<"
  chart      = "intersight/iwok8scollector"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "namespace"
    value = "iwo-collector"
  }
  set {
    name  = "iwoServerVersion"
    value = "8.0"
  }
  set {
    name  = "collectorImage.tag"
    value = "8.0.6"
  }
  set {
    name  = "targetName"
    value = "mycluster"
  }
}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
    client_key = base64decode(local.kube_config.users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  }
}

locals {
  kube_config = yamldecode(data.terraform_remote_state.iksws.outputs.kube_config)
}


