data "template_file" "install_config" {
  template = <<-EOT
apiVersion: v1
baseDomain: "${var.base_domain}"
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 0
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: "${var.cluster_name}"
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  gcp:
    projectID: "${var.project}"
    region: us-central1
publish: External
pullSecret: '{"auths":{"fake":{"auth": "bar"}}}'
sshKey: "${trimspace(data.local_file.ssh_key.content)}"
EOT
}

resource "local_file" "install_config" {
  depends_on = [data.template_file.install_config]

  content  = data.template_file.install_config.rendered
  filename = "${path.root}/install-config.yaml"
}

data "local_file" "ssh_key" {
  filename = var.ssh_public_key_location
}

resource "null_resource" "generate_ignition_configs" {
  depends_on = [local_file.install_config]

  provisioner "local-exec" {
    command    = <<-EOT
        export GODEBUG=asyncpreemptoff=1
        export GOOGLE_CREDENTIALS="../credentials.json"
        rm -fr "${path.root}/clusterconfig" >/dev/null
        mkdir "${path.root}/clusterconfig"
        mv "${path.root}/install-config.yaml" "${path.root}/clusterconfig/install-config.yaml"
        openshift-install create manifests --dir "${path.root}/clusterconfig"
        rm -f "${path.root}/clusterconfig/openshift/99_openshift-cluster-api_master-machines-*.yaml"
        rm -f "${path.root}/clusterconfig/openshift/99_openshift-cluster-api_worker-machineset-*.yaml"
        openshift-install create ignition-configs --dir "${path.root}/clusterconfig"
    EOT
    on_failure = fail
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -fr "${path.root}/clusterconfig" > /dev/null
    EOT
  }
}

resource "google_storage_bucket_object" "bootstrap_ign" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = "naveenm1786"
  source = "${path.root}/clusterconfig/bootstrap.ign"
  name   = "bootstrap.ign"
}

resource "google_storage_bucket_object" "master_ign" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = "naveenm1786"
  source = "${path.root}/clusterconfig/master.ign"
  name   = "master.ign"
}

resource "google_storage_bucket_object" "worker_ign" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = "naveenm1786"
  source = "${path.root}/clusterconfig/worker.ign"
  name   = "worker.ign"
}

data "google_storage_object_signed_url" "bootstrap_ign" {
  bucket = "naveenm1786"
  path   = "bootstrap.ign"
}

data "google_storage_object_signed_url" "master_ign" {
  bucket = "naveenm1786"
  path   = "master.ign"
}

data "google_storage_object_signed_url" "worker_ign" {
  bucket = "naveenm1786"
  path   = "worker.ign"
}

resource "null_resource" "get_infra_id" {
  depends_on = [null_resource.generate_ignition_configs]

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      cat "${path.root}/clusterconfig/metadata.json" | jq -r .infraID > ${path.module}/infraID | tr -d '\n'
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -rf ${path.module}/infraID
    EOT
  }
}

data "local_file" "infra_id" {
  depends_on = [null_resource.get_infra_id]

  filename = "${path.module}/infraID"
}

output "infraID" {
  value = trimspace(data.local_file.infra_id.content)
}

output "bootstrap_ign" {
  value = data.google_storage_object_signed_url.bootstrap_ign.signed_url
}

output "master_ign" {
  value = data.google_storage_object_signed_url.master_ign.signed_url
}

output "worker_ign" {
  value = data.google_storage_object_signed_url.worker_ign.signed_url
}