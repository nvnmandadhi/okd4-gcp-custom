locals {
  gcs_bucket               = data.terraform_remote_state.initialize.outputs.gcs_bucket
  infra_id                 = data.terraform_remote_state.installer.outputs.infra_id
  kms_key_self_link        = data.terraform_remote_state.initialize.outputs.kms_key_self_link
  network_self_link        = data.terraform_remote_state.initialize.outputs.network_self_link
  control_subnet_self_link = data.terraform_remote_state.initialize.outputs.control_subnet_self_link
  master_sa_email          = data.terraform_remote_state.initialize.outputs.master_sa_email
  worker_sa_email          = data.terraform_remote_state.initialize.outputs.worker_sa_email
  network_cidrs            = data.terraform_remote_state.initialize.outputs.network_cidrs
  master_ign               = data.terraform_remote_state.installer.outputs.master_ign
  worker_ign               = data.terraform_remote_state.installer.outputs.worker_ign
  coreos_image_self_link   = data.terraform_remote_state.installer.outputs.coreos_image_self_link
}

data "ignition_config" "master_ignition" {
  replace {
    source = local.master_ign
  }
}

resource "google_compute_instance" "master" {
  count = var.num_master_nodes

  machine_type = var.master_machine_type
  name         = "${local.infra_id}-master-${count.index}"
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
    email  = local.master_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    "user-data"                = data.ignition_config.master_ignition.rendered
    "disable-legacy-endpoints" = "TRUE"
  }
  network_interface {
    subnetwork = local.control_subnet_self_link
  }
  tags = [
    "${local.infra_id}-master"
  ]
  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      metadata["user-data"]
    ]
  }
}
