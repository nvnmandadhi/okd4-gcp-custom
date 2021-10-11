resource "random_id" "rand" {
  byte_length = 4
}

data "google_project" "cluster_project" {
  project_id = var.cluster_project_id
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.3"

  project_id      = var.cluster_project_id
  location        = var.kms_region
  keyring         = "${var.cluster_name}-keyring-${random_id.rand.hex}"
  keys            = ["${var.cluster_name}-key-${random_id.rand.hex}"]
  set_owners_for  = ["${var.cluster_name}-key-${random_id.rand.hex}"]
  prevent_destroy = false
  owners = [
    "serviceAccount:${google_service_account.kms_sa.email}"
  ]
}

module "gcs_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 5.0"

  name                     = "${var.cluster_name}-bucket-${random_id.rand.hex}"
  project_id               = var.cluster_project_id
  location                 = "US"
  public_access_prevention = "enforced"
  force_destroy            = true
  versioning               = false
  labels                   = {}
}

resource "google_kms_crypto_key_iam_member" "kms_key_iam" {
  crypto_key_id = module.kms.keys["${var.cluster_name}-key-${random_id.rand.hex}"]
  member        = "serviceAccount:service-${data.google_project.cluster_project.number}@compute-system.iam.gserviceaccount.com"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}