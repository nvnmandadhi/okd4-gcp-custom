output "master_instance_groups" {
  value = google_compute_instance.master.*.self_link
}