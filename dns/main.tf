resource "google_dns_managed_zone" "private_zone" {
  name       = "${var.infraID}-private-zone"
  dns_name   = "${var.cluster_name}.${var.base_domain}."
  project    = var.project
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = var.cluster_network
    }
  }
}

resource "google_dns_record_set" "api" {
  managed_zone = google_dns_managed_zone.private_zone.name
  project      = var.project
  name         = "api.${var.cluster_name}.${var.base_domain}."
  rrdatas      = [var.cluster_ip]
  ttl          = 60
  type         = "A"
}

resource "google_dns_record_set" "api-int" {
  managed_zone = google_dns_managed_zone.private_zone.name
  project      = var.project
  name         = "api-int.${var.cluster_name}.${var.base_domain}."
  rrdatas      = [var.cluster_ip]
  ttl          = 60
  type         = "A"
}

resource "google_dns_record_set" "api_ext" {
  managed_zone = google_dns_managed_zone.private_zone.name
  project      = var.project
  name         = "api.${var.cluster_name}.${var.base_domain}."
  rrdatas      = [var.cluster_public_ip]
  ttl          = 60
  type         = "A"
}
