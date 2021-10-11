resource "google_compute_address" "bootstrap_public_ip" {
  name    = "${var.infraID}-bootstrap-public-ip"
  region  = var.region
  project = var.project
}

data "ignition_config" "ignition" {
  replace {
    source = var.bootstrap_ign
  }
}

resource "google_compute_instance" "bootstrap" {
  machine_type = "n1-standard-4"
  name         = "${var.infraID}-bootstrap"
  zone         = var.bootstrap_instance_zone
  project      = var.project
  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.fedora_coreos_image
      size  = 100
      type  = "pd-ssd"
    }
  }
  scheduling {
    preemptible = true
    automatic_restart = false
  }
  metadata = {
    "user-data" = data.ignition_config.ignition.rendered
  }
  network_interface {
    subnetwork = var.control_subnet
    access_config {
      nat_ip = google_compute_address.bootstrap_public_ip.address
    }
  }
  tags = [
    "${var.infraID}-master",
    "${var.infraID}-bootstrap"
  ]
}

resource "google_compute_instance_group" "bootstrap" {
  name    = "${var.infraID}-bootstrap-instance-group"
  zone    = var.bootstrap_instance_zone
  project = var.project
  named_port {
    name = "ignition"
    port = 22623
  }
  named_port {
    name = "https"
    port = 6443
  }
  instances = google_compute_instance.bootstrap.*.self_link
  network   = var.cluster_network
}