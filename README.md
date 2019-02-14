# Drone Deployment

This repository outlines the steps needed to deploy drone with helm on an eks cluster. The cluster and load balancer sitting in front of the 
drone service will be provisioned with terraform.

## Table of Contents

1. [EKS Cluster Deployment Pre-reqs](#eks-cluster-deployment-pre-reqs)
1. [Deploying an EKS Cluster with Terraform](#deploying-an-eks-cluster-with-terraform)
1. [Installing/Configuring Helm](#installing-and-configuring-helm)
1. [Deploying Drone with Helm](#deploying-drone-with-helm)


## EKS Cluster Deployment Pre-reqs<a name="eks-cluster-deployment-pre-reqs"></a>
There are some things we'll need to do before we can  deploy an EKS cluster with terraform.

### 1. Clone this Repo

### 2. Install Terraform

Install terraform by following the documentation outlined [here](https://learn.hashicorp.com/terraform/getting-started/install.html).
>**NOTE**: It's better to download the binary for a specific version of terraform. Certain terraform configurations require a specific versions of terraform. You can manage different versions of terraform with a tool like [stow](https://www.gnu.org/software/stow/manual/stow.html).

### 3. Configure the Terraform AWS Provider

This step assumes you have an AWS account already. Learn how to configure the terraform aws provider [here](https://www.terraform.io/docs/providers/aws/).

### 4. EKS Module pre-reqs

The [terraform eks module](https://github.com/terraform-aws-modules/terraform-aws-eks) is being used to deploy our eks cluster. The eks module requires that the following software be installed on your system before it can be used:

1.  **Kubectl** : [Installation Instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
1.  **AWS IAM Authenticator** : [Installation Instructions](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

### 5.Configuring the Terraform Backend

1. Edit the bucket used for remote state in [main.tf](./terraform/main.tf)
>__**NOTE**__: For demo purposes, keeping your terraform state local is fine.

## EKS Cluster Deployment<a name="deploying-an-eks-cluster-with-terraform"></a>

`cd`into the [terraform](./terraform/) directory and run the following commands:
1. `terraform init`
1. `terraform plan`
1. `terraform apply`

## Installing and Configuring Helm
### 1. Configuring kubectl
After the terraform apply is finished, a kubeconfig file `kubeconfig_<env>-<workspace>-cluster` will be generated in the [terraform](./terraform/) directory. We need to set the apppropriate context, so that the kubectl client will be able to interact with the eks cluster we spun up. Follow the steps outlined below to configure kubectl:

1. Run `export KUBECONFIG=/full/path/to/kubeconfig_<env>-<workspace>-cluster`

### 2. Creating a Service Account and Cluster Role Bindings for Tiller
Now that we've configured kubectl, we can create kubernetes resources that Helm needs.

1. ``cd`` into the [k8s](./k8s/) directory.
1. Run `kubectl create -f rbac-config.yaml` 

This command will create a Service Account and Cluser Role Binding for Tiller that will allow it to deploy kubernetes resources.

### 3. Installing Helm<a name="installing-and-configuring-helm"></a>
Follow the steps outlined in this [here](https://github.com/helm/helm/blob/master/docs/install.md) to install helm on your workstation. Tiller will be installed after the eks cluster is deployed.

### 4. Install Tiller on  the EKS Cluster
The following steps outline the installation of tiller on our EKS cluster:
1. Run `export KUBE_CONFIG=/full/path/to/kubeconfig_<env>-<workspace>-cluster`
1. Run `helm init`

## Deploying Drone with Helm<a name="deploying-drone-with-helm"></a>

1. `cd` into the [helm](./helm/) directory.
1. Populate [values.yaml](./helm/values.yaml) file with the necessary information.
1. Run `helm install --name drone -f values.yaml stable/demo`

## Accessing Drone
1. `cd` into the [terraform](./terraform/) directory and run `terraform outputs`. This will return the hostname of the elastic load balancer.
1. Drone should now be accessible via the load balancer hostname.
1. Create a CNAME so you can access drone at the URL we specified earlier.

## Danke!
