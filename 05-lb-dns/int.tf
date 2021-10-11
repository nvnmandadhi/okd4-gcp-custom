resource "google_compute_address" "cluster_ip" {
  name         = "${local.infra_id}-cluster-ip"
  address_type = "INTERNAL"
  region       = var.region
  subnetwork   = local.control_subnet_self_link
  project      = var.cluster_project_id
}

resource "google_compute_health_check" "cluster_api_internal_hc" {
  name    = "${local.infra_id}-api-internal-health-check"
  project = var.cluster_project_id
  https_health_check {
    port         = 6443
    request_path = "/readyz"
  }
}

resource "google_compute_instance_group" "master_instance_group" {
  count = length(var.zones)

  name    = "${local.infra_id}-master-${var.zones[count.index]}-instance-group"
  project = var.cluster_project_id
  named_port {
    name = "ignition"
    port = 22623
  }
  named_port {
    name = "https"
    port = 6443
  }
  instances = [local.master_instance_groups[count.index]]
  network   = local.cluster_network
  zone      = var.zones[count.index]
}

resource "google_compute_region_backend_service" "api_internal_backend_svc" {
  name                  = "${local.infra_id}-api-internal-backend-service"
  project               = var.cluster_project_id
  health_checks         = [google_compute_health_check.cluster_api_internal_hc.self_link]
  load_balancing_scheme = "INTERNAL"
  region                = var.region
  protocol              = "TCP"
  timeout_sec           = 120

  dynamic "backend" {
    for_each = google_compute_instance_group.master_instance_group.*.self_link
    content {
      group = backend.value
    }
  }
  dynamic "backend" {
    for_each = local.bootstrap_instance_groups
    content {
      group = backend.value
    }
  }
}

resource "google_compute_forwarding_rule" "api_internal_fw_rule" {
  name                  = "${local.infra_id}-api-internal-forwarding-rule"
  project               = var.cluster_project_id
  backend_service       = google_compute_region_backend_service.api_internal_backend_svc.self_link
  ip_address            = google_compute_address.cluster_ip.self_link
  load_balancing_scheme = "INTERNAL"
  ports                 = ["6443", "22623"]
  region                = var.region
  subnetwork            = local.control_subnet_self_link
}
