provider "google-beta" {
  region  = var.region
  project = var.project
}

module "installer" {
  source       = "./installer"
  base_domain  = var.base_domain
  cluster_name = var.cluster_name
  ssh_public_key_location = var.ssh_public_key_location
}

module "vpc" {
  depends_on = [module.installer]

  source             = "./vpc"
  infraID            = module.installer.infraID
  master_subnet_cidr = var.master_subnet_cidr
  region             = var.region
  worker_subnet_cidr = var.worker_subnet_cidr
  project            = var.project
}

module "lb" {
  source                   = "./lb"
  cluster_network          = module.vpc.cluster_network
  control_subnet           = module.vpc.control_subnet
  infraID                  = module.installer.infraID
  region                   = var.region
  zones                    = var.zones
  bootstrap_instance_group = module.bootstrap.bootstrap_instance_groups
  master_instances         = module.master.master_instances
  project                  = var.project
}

module "iam" {
  source  = "./iam"
  infraID = module.installer.infraID
  project = var.project
}

module "dns" {
  source            = "./dns"
  base_domain       = var.base_domain
  cluster_ip        = module.lb.cluster_ip
  cluster_public_ip = module.lb.cluster_public_ip
  cluster_name      = var.cluster_name
  cluster_network   = module.vpc.cluster_network
  infraID           = module.installer.infraID
  project           = var.project
}

module "firewall" {
  source          = "./firewall"
  cluster_network = module.vpc.cluster_network
  infraID         = module.installer.infraID
  network_cidr    = var.vpc_cidr
  project         = var.project
}

data "google_compute_image" "fedora_coreos_image" {
  family  = "fedora-coreos-next"
  project = "fedora-coreos-cloud"
}

module "bootstrap" {
  source                  = "./bootstrap"
  bootstrap_ign           = module.installer.bootstrap_ign
  cluster_network         = module.vpc.cluster_network
  control_subnet          = module.vpc.control_subnet
  infraID                 = module.installer.infraID
  region                  = var.region
  project                 = var.project
  bootstrap_instance_zone = var.zones[0]
  fedora_coreos_image     = data.google_compute_image.fedora_coreos_image.self_link
}

module "master" {
  source              = "./master"
  control_subnet      = module.vpc.control_subnet
  fedora_coreos_image = data.google_compute_image.fedora_coreos_image.self_link
  infraID             = module.installer.infraID
  master_ign          = module.installer.master_ign
  master_sa_email     = module.iam.master_sa_email
  project             = var.project
  region              = var.region
  zones               = var.zones
}