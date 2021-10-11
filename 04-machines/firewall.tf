resource "google_compute_firewall" "bootstrap_ssh" {
  name    = "bootstrap-in-ssh"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["${local.infra_id}-bootstrap"]
}

resource "google_compute_firewall" "api" {
  name    = "api"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  source_ranges = var.publish_external ? ["0.0.0.0/0"] : local.network_cidrs
  target_tags   = ["${local.infra_id}-master"]
}

resource "google_compute_firewall" "health_checks_master" {
  name    = "hc-m"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "tcp"
    ports    = ["6443", "6080", "22624"]
  }
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]
  target_tags = ["${local.infra_id}-master"]
}

resource "google_compute_firewall" "etcd" {
  name    = "etcd"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "tcp"
    ports    = ["2379-2380"]
  }
  source_tags = ["${local.infra_id}-master"]
  target_tags = ["${local.infra_id}-master"]
}

resource "google_compute_firewall" "control_plane" {
  name    = "control-plane"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "tcp"
    ports    = ["10257", "10259", "22623"]
  }
  source_tags = ["${local.infra_id}-master", "${local.infra_id}-worker"]
  target_tags = ["${local.infra_id}-master"]
}

resource "google_compute_firewall" "internal_network" {
  name    = "internal-network"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = local.network_cidrs
  target_tags   = ["${local.infra_id}-master", "${local.infra_id}-worker"]
}

resource "google_compute_firewall" "internal_cluster" {
  name    = "internal-cluster"
  project = var.shared_net_project_id
  network = local.network_self_link
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "udp"
    ports    = ["4789", "6081", "500", "4500", "30000-32767", "9000-9999"]
  }
  allow {
    protocol = "tcp"
    ports    = ["9000-9999", "10250", "30000-32767"]
  }
  source_ranges = local.network_cidrs
  target_tags   = ["${local.infra_id}-master", "${local.infra_id}-worker"]
}
