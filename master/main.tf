data "ignition_config" "ignition" {
  replace {
    source = var.master_ign
  }
}

resource "google_compute_instance" "master" {
  count = 3

  machine_type = "n1-standard-4"
  name         = "${var.infraID}-master-${count.index}"
  zone         = var.zones[count.index]
  project      = var.project
  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.fedora_coreos_image
      size  = 120
      type  = "pd-ssd"
    }
  }
  scheduling {
    preemptible = true
    automatic_restart = false
  }
  service_account {
    email  = var.master_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    "user-data" = data.ignition_config.ignition.rendered
  }
  network_interface {
    subnetwork = var.control_subnet
  }
  tags = [
    "${var.infraID}-master",
  ]
}