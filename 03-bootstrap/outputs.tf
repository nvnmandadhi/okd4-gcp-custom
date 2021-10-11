output "bootstrap_instance_groups" {
  value = google_compute_instance_group.bootstrap.*.self_link
}

output "instance_name" {
  value = google_compute_instance.bootstrap.name
}