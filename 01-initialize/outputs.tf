output "network_name" {
  value = module.net.network_name
}

output "network_self_link" {
  value = module.net.network_self_link
}

output "control_plane_subnet" {
  value = module.net.subnets["${var.region}/${var.cluster_name}-control-plane-snet"]["name"]
}

output "control_subnet_self_link" {
  value = module.net.subnets["${var.region}/${var.cluster_name}-control-plane-snet"]["self_link"]
}

output "compute_subnet" {
  value = module.net.subnets["${var.region}/${var.cluster_name}-compute-snet"]["name"]
}

output "compute_subnet_self_link" {
  value = module.net.subnets["${var.region}/${var.cluster_name}-compute-snet"]["self_link"]
}

output "shared_subnets" {
  value = module.net.subnets_self_links
}

output "kms_key_self_link" {
  value = module.kms.keys["${var.cluster_name}-key-${random_id.rand.hex}"]
}

output "kms_sa_email" {
  value = google_service_account.kms_sa.email
}

output "gcs_bucket" {
  value = module.gcs_bucket.name
}

output "master_sa_email" {
  value = google_service_account.master.email
}

output "worker_sa_email" {
  value = google_service_account.worker.email
}

output "bootstrap_sa_email" {
  value = google_service_account.bootstrap.email
}

output "kms_key_ring" {
  value = module.kms.keyring_name
}

output "kms_key" {
  value = "${var.cluster_name}-key-${random_id.rand.hex}"
}

output "kms_key_ring_self_link" {
  value = module.kms.keyring
}

output "network_cidrs" {
  value = [
    var.control_plane_subnet_cidr,
    var.compute_subnet_cidr,
    var.pods_cidr,
    var.services_cidr
  ]
}