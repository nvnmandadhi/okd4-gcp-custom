locals {
  infra_id                  = data.terraform_remote_state.installer.outputs.infra_id
  bootstrap_instance_groups = data.terraform_remote_state.bootstrap.outputs.bootstrap_instance_groups
  master_instance_groups    = data.terraform_remote_state.machines.outputs.master_instance_groups
  cluster_network           = data.terraform_remote_state.initialize.outputs.network_self_link
  control_subnet_self_link  = data.terraform_remote_state.initialize.outputs.control_subnet_self_link
}

resource "google_dns_managed_zone" "private_zone" {
  name       = "${local.infra_id}-private-zone"
  dns_name   = "${var.cluster_name}.${var.base_domain}."
  project    = var.cluster_project_id
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = local.cluster_network
    }
  }
}

resource "google_dns_record_set" "api" {
  managed_zone = google_dns_managed_zone.private_zone.name
  project      = var.cluster_project_id
  name         = "api.${var.cluster_name}.${var.base_domain}."
  rrdatas      = [google_compute_address.cluster_ip.address]
  ttl          = 60
  type         = "A"
}

resource "google_dns_record_set" "api-int" {
  managed_zone = google_dns_managed_zone.private_zone.name
  project      = var.cluster_project_id
  name         = "api-int.${var.cluster_name}.${var.base_domain}."
  rrdatas      = [google_compute_address.cluster_ip.address]
  ttl          = 60
  type         = "A"
}

data "google_dns_managed_zone" "public" {
  count   = var.publish_external ? 1 : 0
  name    = replace(var.base_domain, ".", "-")
  project = var.cluster_project_id
}

resource "google_dns_record_set" "api_ext" {
  count        = var.publish_external ? 1 : 0
  managed_zone = data.google_dns_managed_zone.public[count.index].name
  project      = var.cluster_project_id
  name         = "api.${var.cluster_name}.${var.base_domain}."
  rrdatas      = [google_compute_address.cluster_public_ip[count.index].address]
  ttl          = 60
  type         = "A"
}
