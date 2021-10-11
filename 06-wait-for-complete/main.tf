locals {
  bootstrap_instance_name = data.terraform_remote_state.bootstrap.outputs.bootstrap_instance_name
}

resource "null_resource" "wait-for-bootstrap" {
  provisioner "local-exec-exec" {
    command = <<-EOT
      gcloud compute ssh --zone "${var.zones[0]}" "core@${local.bootstrap_instance_name}" \
        --tunnel-through-iap --project "${var.cluster_project_id}" --ssh-key-file "../config/ssh/okd" \
          journalctl -b -f -u release-image.service -u bootkube.service
    EOT
  }
}