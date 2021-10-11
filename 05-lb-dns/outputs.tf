output "cluster_ip" {
  value = google_compute_address.cluster_ip.address
}

output "cluster_public_ip" {
  value = flatten([for ext_ip in google_compute_address.cluster_public_ip : ext_ip.address])
}