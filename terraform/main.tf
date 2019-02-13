terraform {
  required_version = "=0.11.11"

  backend "s3" {
    bucket = "infra-nwi-poc"
    key    = "mr/drone.tfstate"
    region = "us-west-2"
  }
}

data "aws_eks_cluster" "eks" {
  name = "${module.eks.cluster_id}"
}

data "aws_eks_cluster_auth" "eks" {
  name = "${module.eks.cluster_id}"
}

provider "kubernetes" {
  host                   = "${module.eks.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.eks.token}"
  version                = "= 1.5.0"
  load_config_file       = false
}

provider "aws" {
  version = "1.58"
  region  = "us-east-1"
}

provider "helm" {
  version                         = "0.7.0"
  install_tiller                  = true
  tiller_image                    = "gcr.io/kubernetes-helm/tiller:v2.12.0"
  service_account                 = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace                       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  automount_service_account_token = true

  kubernetes {
    host                   = "${module.eks.cluster_endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)}"
    token                  = "${data.aws_eks_cluster_auth.eks.token}"
  }
}
