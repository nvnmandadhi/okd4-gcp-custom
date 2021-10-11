provider "google" {
  impersonate_service_account = var.tf_sa_email
}

provider "google-beta" {
  impersonate_service_account = var.tf_sa_email
}

provider "ignition" {}