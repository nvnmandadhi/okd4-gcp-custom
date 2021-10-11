output "infra_id" {
  depends_on = [
    null_resource.infra_id,
    data.local_file.infra_id
  ]
  value = trimspace(data.local_file.infra_id.content)
}

output "credentials_name" {
  value = "${var.cluster_name}-${random_id.rand.hex}"
}

output "bootstrap_ign" {
  value = "gs://${local.gcs_bucket}/${google_storage_bucket_object.bootstrap_ign.name}"
}

output "master_ign" {
  value = "gs://${local.gcs_bucket}/${google_storage_bucket_object.master_ign.name}"
}

output "worker_ign" {
  value = "gs://${local.gcs_bucket}/${google_storage_bucket_object.worker_ign.name}"
}

output "coreos_image_self_link" {
  value = data.google_compute_image.fedora_coreos_image.self_link
}