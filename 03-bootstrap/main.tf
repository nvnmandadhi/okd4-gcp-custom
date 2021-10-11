locals {
  gcs_bucket               = data.terraform_remote_state.initialize.outputs.gcs_bucket
  infra_id                 = data.terraform_remote_state.installer.outputs.infra_id
  kms_key_self_link        = data.terraform_remote_state.initialize.outputs.kms_key_self_link
  network_self_link        = data.terraform_remote_state.initialize.outputs.network_self_link
  control_subnet_self_link = data.terraform_remote_state.initialize.outputs.control_subnet_self_link
  bootstrap_ign            = data.terraform_remote_state.installer.outputs.bootstrap_ign
  coreos_image_self_link   = data.terraform_remote_state.installer.outputs.coreos_image_self_link
  bootstrap_sa_email       = data.terraform_remote_state.initialize.outputs.bootstrap_sa_email
}

data "ignition_config" "bootstrap_ignition" {
  replace {
    source = local.bootstrap_ign
  }
}

resource "google_compute_instance" "bootstrap" {
  machine_type = var.bootstrap_machine_type
  name         = "${local.infra_id}-bootstrap"
  zone         = var.zones[0]
  project      = var.cluster_project_id
  boot_disk {
    auto_delete = true
    initialize_params {
      image = local.coreos_image_self_link
      size  = 100
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
    email  = local.bootstrap_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    "user-data"                = data.ignition_config.bootstrap_ignition.rendered
    "disable-legacy-endpoints" = "TRUE"
  }
  network_interface {
    subnetwork = local.control_subnet_self_link
  }
  tags = [
    "${local.infra_id}-master",
    "${local.infra_id}-bootstrap"
  ]

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      metadata["user-data"]
    ]
  }
}

resource "google_compute_instance_group" "bootstrap" {
  name    = "${local.infra_id}-bootstrap-instance-group"
  zone    = var.zones[0]
  project = var.cluster_project_id
  named_port {
    name = "ignition"
    port = 22623
  }
  named_port {
    name = "https"
    port = 6443
  }
  instances = google_compute_instance.bootstrap.*.self_link
  network   = local.network_self_link
}

