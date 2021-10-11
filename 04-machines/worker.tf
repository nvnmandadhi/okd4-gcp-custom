data "ignition_config" "worker_ignition" {
  replace {
    source = local.worker_ign
  }
}

resource "google_compute_instance" "worker" {
  count = var.num_worker_nodes

  machine_type = var.worker_machine_type
  name         = "${local.infra_id}-worker-${count.index}"
  zone         = var.zones[count.index]
  project      = var.cluster_project_id
  boot_disk {
    auto_delete = true
    initialize_params {
      image = local.coreos_image_self_link
      size  = 120
      type  = var.disk_type
    }
    kms_key_self_link = local.kms_key_self_link
  }
  # confidential_instance_config {
  #   enable_confidential_compute = true
  # }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }
  service_account {
    email  = local.worker_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    "user-data"                = data.ignition_config.worker_ignition.rendered
    "disable-legacy-endpoints" = "TRUE"
  }
  network_interface {
    subnetwork = local.control_subnet_self_link
  }
  tags = [
    "${local.infra_id}-worker"
  ]
  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      metadata["user-data"]
    ]
  }
}
