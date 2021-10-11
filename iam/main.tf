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
}
resource "google_service_account" "master" {
  account_id   = "${var.infraID}-m"
  display_name = "${var.infraID}-master-node"
  project      = var.project
}

resource "google_service_account" "worker" {
  account_id   = "${var.infraID}-w"
  display_name = "${var.infraID}-worker-node"
  project      = var.project
}

resource "google_project_iam_member" "master" {
  for_each = toset(local.master_roles)
  member   = "serviceAccount:${google_service_account.master.email}"
  role     = each.value
  project  = var.project
}

resource "google_project_iam_member" "worker" {
  for_each = toset(local.worker_roles)
  member   = "serviceAccount:${google_service_account.worker.email}"
  role     = each.value
  project  = var.project
}

resource "google_service_account_key" "master" {
  service_account_id = google_service_account.master.id
}

resource "google_service_account_key" "worker" {
  service_account_id = google_service_account.worker.id
}