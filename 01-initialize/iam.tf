locals {
  master_roles = [
    "roles/compute.instanceAdmin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin"
  ]
  worker_roles = [
    "roles/compute.viewer",
    "roles/storage.admin"
  ]
  bootstrap_roles = [
    "roles/storage.admin"
  ]
}

resource "google_project_iam_custom_role" "network_role" {
  permissions = [
    "compute.networks.updatePolicy",
    "compute.firewalls.list",
    "compute.firewalls.get",
    "compute.firewalls.create",
    "compute.firewalls.update",
    "compute.firewalls.delete"
  ]
  role_id = "okd_firewall_admin${lower(random_id.rand.hex)}"
  title   = "Firewall Role for OKD Cluster"
  project = var.shared_net_project_id
}

resource "google_service_account" "master" {
  account_id   = "master-sa"
  display_name = "master-node"
  project      = var.cluster_project_id
}

resource "google_service_account" "worker" {
  account_id   = "worker-sa"
  display_name = "worker-node"
  project      = var.cluster_project_id
}

resource "google_service_account" "bootstrap" {
  account_id   = "bootstrap-sa"
  display_name = "bootstrap-node"
  project      = var.cluster_project_id
}

resource "google_project_iam_member" "master" {
  for_each = toset(local.master_roles)
  member   = "serviceAccount:${google_service_account.master.email}"
  role     = each.value
  project  = var.cluster_project_id
}

resource "google_project_iam_member" "master_shared_net_host" {
  member  = "serviceAccount:${google_service_account.master.email}"
  role    = google_project_iam_custom_role.network_role.id
  project = var.shared_net_project_id
}

resource "google_project_iam_member" "worker" {
  for_each = toset(local.worker_roles)
  member   = "serviceAccount:${google_service_account.worker.email}"
  role     = each.value
  project  = var.cluster_project_id
}

resource "google_project_iam_member" "bootstrap" {
  for_each = toset(local.bootstrap_roles)
  member   = "serviceAccount:${google_service_account.bootstrap.email}"
  role     = each.value
  project  = var.cluster_project_id
}

resource "google_service_account" "kms_sa" {
  account_id = "kms-sa-${random_id.rand.hex}"
  project    = var.cluster_project_id
}