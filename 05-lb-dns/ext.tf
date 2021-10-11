resource "google_compute_address" "cluster_public_ip" {
  count        = var.publish_external ? 1 : 0
  name         = "${local.infra_id}-cluster-public-ip"
  project      = var.cluster_project_id
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_http_health_check" "cluster_api_hc" {
  count        = var.publish_external ? 1 : 0
  name         = "${local.infra_id}-api-http-health-check"
  project      = var.cluster_project_id
  port         = 6080
  request_path = "/readyz"
}

resource "google_compute_target_pool" "cluster_api_tp" {
  count         = var.publish_external ? 1 : 0
  name          = "${local.infra_id}-api-target-pool"
  project       = var.cluster_project_id
  region        = var.region
  health_checks = [google_compute_http_health_check.cluster_api_hc[count.index].name]
  instances     = local.master_instance_groups
}

resource "google_compute_forwarding_rule" "cluster_api_fw_rule" {
  count      = var.publish_external ? 1 : 0
  name       = "${local.infra_id}-api-forwarding-rule"
  project    = var.cluster_project_id
  region     = var.region
  ip_address = google_compute_address.cluster_public_ip[count.index].self_link
  target     = google_compute_target_pool.cluster_api_tp[count.index].self_link
  port_range = 6443
}
