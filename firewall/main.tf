resource "google_compute_firewall" "bootstrap_ssh" {
  name    = "${var.infraID}-bootstrap-in-ssh"
  project = var.project
  network = var.cluster_network
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.infraID}-bootstrap"]
}

resource "google_compute_firewall" "api" {
  name    = "${var.infraID}-api"
  project = var.project
  network = var.cluster_network
  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.infraID}-master"]
}

resource "google_compute_firewall" "health_checks" {
  name    = "${var.infraID}-health-checks"
  project = var.project
  network = var.cluster_network
  allow {
    protocol = "tcp"
    ports    = ["6443", "6080", "22624"]
  }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["${var.infraID}-master"]
}

resource "google_compute_firewall" "etcd" {
  name    = "${var.infraID}-etcd"
  project = var.project
  network = var.cluster_network
  allow {
    protocol = "tcp"
    ports    = ["2379-2380"]
  }
  source_tags = ["${var.infraID}-master"]
  target_tags = ["${var.infraID}-master"]
}

resource "google_compute_firewall" "control_plane" {
  name    = "${var.infraID}-control-plane"
  project = var.project
  network = var.cluster_network
  allow {
    protocol = "tcp"
    ports    = ["10257", "10259", "22623"]
  }
  source_tags = ["${var.infraID}-master", "${var.infraID}-worker"]
  target_tags = ["${var.infraID}-master"]
}

resource "google_compute_firewall" "internal_network" {
  name    = "${var.infraID}-internal-network"
  project = var.project
  network = var.cluster_network
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [var.network_cidr]
  target_tags   = ["${var.infraID}-master", "${var.infraID}-worker"]
}

resource "google_compute_firewall" "internal_cluster" {
  name    = "${var.infraID}-internal-cluster"
  project = var.project
  network = var.cluster_network
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
  source_ranges = [var.network_cidr]
  target_tags   = ["${var.infraID}-master", "${var.infraID}-worker"]
}