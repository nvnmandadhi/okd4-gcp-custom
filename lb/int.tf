resource "google_compute_address" "cluster_ip" {
  name         = "${var.infraID}-cluster-ip"
  address_type = "INTERNAL"
  region       = var.region
  subnetwork   = var.control_subnet
  project      = var.project
}

resource "google_compute_health_check" "cluster_api_internal_hc" {
  name    = "${var.infraID}-api-internal-health-check"
  project = var.project
  https_health_check {
    port         = 6443
    request_path = "/readyz"
  }
}

resource "google_compute_instance_group" "master_instance_group" {
  count = length(var.zones)

  name    = "${var.infraID}-master-${var.zones[count.index]}-instance-group"
  project = var.project
  named_port {
    name = "ignition"
    port = 22623
  }
  named_port {
    name = "https"
    port = 6443
  }
  instances = [var.master_instances[count.index]]
  network   = var.cluster_network
  zone      = var.zones[count.index]
}

resource "google_compute_region_backend_service" "api_internal_backend_svc" {
  name                  = "${var.infraID}-api-internal-backend-service"
  project               = var.project
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
    for_each = var.bootstrap_instance_group
    content {
      group = backend.value
    }
  }
}

resource "google_compute_forwarding_rule" "api_internal_fw_rule" {
  name                  = "${var.infraID}-api-internal-forwarding-rule"
  project               = var.project
  backend_service       = google_compute_region_backend_service.api_internal_backend_svc.self_link
  ip_address            = google_compute_address.cluster_ip.self_link
  load_balancing_scheme = "INTERNAL"
  ports                 = ["6443", "22623"]
  region                = var.region
  subnetwork            = var.control_subnet
}