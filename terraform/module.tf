data "aws_availability_zones" "available" {}

module "vpc" {
  source             = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git?ref=v1.53.0"
  name               = "drone-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true

  public_subnet_tags = {
    KubernetesCluster        = "${var.env}-${terraform.workspace}-cluster"
    "kubernetes.io/role/elb" = ""
  }

  tags = {
    environment = "${var.env}"
    workspace   = "${terraform.workspace}"
  }
}

module "eks" {
  source       = "git::git@github.com:terraform-aws-modules/terraform-aws-eks.git?ref=v2.2.0"
  cluster_name = "${var.env}-${terraform.workspace}-cluster"
  subnets      = ["${module.vpc.private_subnets}"]
  vpc_id       = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_max_size  = 5
    },
  ]

  tags = {
    environment = "${var.env}"
    workspace   = "${terraform.workspace}"
  }
}
