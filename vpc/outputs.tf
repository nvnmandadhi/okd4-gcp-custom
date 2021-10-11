output "cluster_network" {
  value = google_compute_network.vpc.self_link
}

output "control_subnet" {
  value = google_compute_subnetwork.master-subnet.self_link
}

output "worker_subnet" {
  value = google_compute_subnetwork.worker-subnet.self_link
}