locals {
  gcs_bucket                = data.terraform_remote_state.initialize.outputs.gcs_bucket
  master_sa_email           = data.terraform_remote_state.initialize.outputs.master_sa_email
  network_name              = data.terraform_remote_state.initialize.outputs.network_name
  control_plane_subnet_name = data.terraform_remote_state.initialize.outputs.control_plane_subnet
  compute_subnet_name       = data.terraform_remote_state.initialize.outputs.compute_subnet
  kms_key                   = data.terraform_remote_state.initialize.outputs.kms_key
  kms_key_ring              = data.terraform_remote_state.initialize.outputs.kms_key_ring
  kms_sa_email              = data.terraform_remote_state.initialize.outputs.kms_sa_email
}

resource "local_file" "install_config" {
  content = templatefile("${path.module}/install-config.tftpl", {
    base_domain                = var.base_domain,
    num_worker_nodes           = var.num_worker_nodes,
    num_master_nodes           = var.num_master_nodes,
    cluster_name               = var.cluster_name,
    project_id                 = var.cluster_project_id,
    shared_vpc_host_project_id = var.shared_net_project_id,
    region                     = var.region,
    network                    = local.network_name,
    control_plane_subnet_name  = local.control_plane_subnet_name,
    compute_subnet_name        = local.compute_subnet_name,
    disk_type                  = var.disk_type,
    kms_key_name               = local.kms_key,
    kms_key_ring               = local.kms_key_ring,
    kms_key_location           = var.kms_region,
    kms_key_project_id         = var.cluster_project_id,
    kms_key_sa_email           = local.kms_sa_email,
    ssh_key_content            = trimspace(var.ssh_public_key),
    pods_cidr                  = var.pods_cidr,
    services_cidr              = var.services_cidr,
    machines_cidr              = var.compute_subnet_cidr,
    control_plane_cidr         = var.control_plane_subnet_cidr,
    control_plane_sa_email     = local.master_sa_email,
    publish                    = var.publish_external ? "External" : "Internal"
  })
  filename = "${path.root}/install-config.yaml"
}

resource "google_storage_bucket_object" "install_config" {
  depends_on = [local_file.install_config]

  bucket = local.gcs_bucket
  source = "${path.root}/install-config.yaml"
  name   = "install-config.yaml"
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "null_resource" "generate_ignition_configs" {
  depends_on = [
    google_storage_bucket_object.install_config
  ]

  provisioner "local-exec" {
    when       = create
    command    = <<-EOT
        set -ex
        rm -fr "${path.root}/clusterconfig" > /dev/null 2>&1
        mkdir "${path.root}/clusterconfig"
        mv "${path.root}/install-config.yaml" "${path.root}/clusterconfig/install-config.yaml"
        RELEASE_IMAGE=$(openshift-install version | awk '/release image/ {print $3}')
        oc adm release extract \
          --from=$${RELEASE_IMAGE} \
          --credentials-requests \
          --included \
          --install-config="${path.root}/clusterconfig/install-config.yaml" \
          --to="${path.root}/credentials"
        CREDENTIALS_NAME="${var.cluster_name}-${random_id.rand.hex}"
        ccoctl gcp create-all \
          --name=$${CREDENTIALS_NAME} \
          --region=${var.region} \
          --project=${var.cluster_project_id} \
          --shared-vpc-host-project=${var.shared_net_project_id} \
          --enable-tech-preview \
          --credentials-requests-dir="${path.root}/credentials" \
          --output-dir="${path.root}/ccoctl_output"
        openshift-install create manifests --dir "${path.root}/clusterconfig"
        cp ../config/*.yaml "${path.root}/clusterconfig/manifests/"
       for file in "${path.root}/clusterconfig/openshift/99_openshift-cluster-api_master-machines-*.yaml"; do
         mv $${file} ../config
       done
       for file in "${path.root}/clusterconfig/openshift/99_openshift-cluster-api_worker-machineset-*.yaml"; do
         mv $${file} ../config
       done
        cp ccoctl_output/manifests/* "${path.root}/clusterconfig/manifests/"
        cp -r ccoctl_output/tls "${path.root}/clusterconfig"
        tree "${path.root}/clusterconfig"
        openshift-install create ignition-configs --dir "${path.root}/clusterconfig"
    EOT
    on_failure = fail
  }
}

resource "null_resource" "infra_id" {
  depends_on = [null_resource.generate_ignition_configs]

  triggers = {
    always-run = timestamp()
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      if [ ! -f "${path.module}/clusterconfig/metadata.json" ]; then
        echo "waiting for infra_id"
        sleep 10;
      fi
      cat ${path.module}/clusterconfig/metadata.json | jq -r ".infraID" > ${path.module}/infraID
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
  depends_on = [null_resource.infra_id]

  filename = "${path.module}/infraID"
}

resource "google_storage_bucket_object" "bootstrap_ign" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = local.gcs_bucket
  source = "${path.root}/clusterconfig/bootstrap.ign"
  name   = "bootstrap.ign"
}

resource "google_storage_bucket_object" "master_ign" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = local.gcs_bucket
  source = "${path.root}/clusterconfig/master.ign"
  name   = "master.ign"
}

resource "google_storage_bucket_object" "worker_ign" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = local.gcs_bucket
  source = "${path.root}/clusterconfig/worker.ign"
  name   = "worker.ign"
}

resource "google_storage_bucket_object" "metadata" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = local.gcs_bucket
  source = "${path.root}/clusterconfig/metadata.json"
  name   = "metadata.json"
}

resource "google_storage_bucket_object" "kube_config" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = local.gcs_bucket
  source = "${path.root}/clusterconfig/auth/kubeconfig"
  name   = "kubeconfig"
}

resource "google_storage_bucket_object" "auth" {
  depends_on = [null_resource.generate_ignition_configs]

  bucket = local.gcs_bucket
  source = "${path.root}/clusterconfig/auth/kubeadmin-password"
  name   = "kubeadmin-password"
}

resource "google_storage_bucket_object" "ssh_key" {
  depends_on = [google_storage_bucket_object.install_config]

  bucket = local.gcs_bucket
  source = "../config/ssh/okd"
  name   = "okd"
}

resource "google_storage_bucket_object" "ssh_pub_key" {
  depends_on = [google_storage_bucket_object.install_config]

  bucket = local.gcs_bucket
  source = "../config/ssh/okd.pub"
  name   = "okd.pub"
}

data "google_compute_image" "fedora_coreos_image" {
  family  = "fedora-coreos-next"
  project = "fedora-coreos-cloud"
}
