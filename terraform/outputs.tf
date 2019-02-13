output "kube_config" {
  value = "${module.eks.kubeconfig}"
}

output "endpoint" {
  value = "${module.eks.cluster_endpoint}"
}

output "auth" {
  value = "${module.eks.cluster_certificate_authority_data}"
}

output "cluster_id" {
  value = "${module.eks.cluster_id}"
}

output "service_account_name" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}
