output "cluster_ip" {
  value = google_compute_address.cluster_ip.address
}

output "cluster_public_ip" {
  value = google_compute_address.cluster_public_ip.address
}