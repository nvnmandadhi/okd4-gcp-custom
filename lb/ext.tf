resource "google_compute_address" "cluster_public_ip" {
  name    = "${var.infraID}-cluster-public-ip"
  project = var.project
  region = var.region
}

resource "google_compute_http_health_check" "cluster_api_hc" {
  name         = "${var.infraID}-api-http-health-check"
  project      = var.project
  port         = 6080
  request_path = "/readyz"
}

resource "google_compute_target_pool" "cluster_api_tp" {
  name          = "${var.infraID}-api-target-pool"
  project       = var.project
  region        = var.region
  health_checks = [google_compute_http_health_check.cluster_api_hc.name]
  instances     = var.master_instances
}

resource "google_compute_forwarding_rule" "cluster_api_fw_rule" {
  name       = "${var.infraID}-api-forwarding-rule"
  project    = var.project
  region     = var.region
  ip_address = google_compute_address.cluster_public_ip.self_link
  target     = google_compute_target_pool.cluster_api_tp.self_link
  port_range = 6443
}