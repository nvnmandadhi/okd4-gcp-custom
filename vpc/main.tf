resource "google_compute_network" "vpc" {
  name                    = "${var.infraID}-network"
  auto_create_subnetworks = false
  project                 = var.project
}

resource "google_compute_subnetwork" "master-subnet" {
  name          = "${var.infraID}-master-subnet"
  ip_cidr_range = var.master_subnet_cidr
  network       = google_compute_network.vpc.self_link
  region        = var.region
  project       = var.project
}

resource "google_compute_subnetwork" "worker-subnet" {
  name          = "${var.infraID}-worker-subnet"
  ip_cidr_range = var.worker_subnet_cidr
  network       = google_compute_network.vpc.self_link
  region        = var.region
  project       = var.project
}

resource "google_compute_router" "router" {
  name    = "${var.infraID}-router"
  network = google_compute_network.vpc.self_link
  region  = var.region
  project = var.project
}

resource "google_compute_router_nat" "master-nat" {
  name                               = "${var.infraID}-nat-master"
  region                             = var.region
  project                            = var.project
  nat_ip_allocate_option             = "AUTO_ONLY"
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  min_ports_per_vm                   = 7168
  subnetwork {
    name                    = google_compute_subnetwork.master-subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_router_nat" "worker-nat" {
  name                               = "${var.infraID}-nat-worker"
  region                             = var.region
  project                            = var.project
  nat_ip_allocate_option             = "AUTO_ONLY"
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  min_ports_per_vm                   = 512
  subnetwork {
    name                    = google_compute_subnetwork.worker-subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}