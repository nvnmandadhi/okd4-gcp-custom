variable "shared_net_project_id" {
  type = string
}

variable "cluster_project_id" {
  type = string
}

variable "tf_sa_email" {
  type = string
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "base_domain" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "base_domain_zone_name" {
  type = string
}

variable "control_plane_subnet_cidr" {
  type = string
}

variable "compute_subnet_cidr" {
  type = string
}

variable "pods_cidr" {
  type = string
}

variable "services_cidr" {
  type = string
}

variable "bootstrap_machine_type" {
  type = string
}

variable "master_machine_type" {
  type = string
}

variable "worker_machine_type" {
  type = string
}

variable "num_master_nodes" {
  type = number
}

variable "num_worker_nodes" {
  type = number
}

variable "kms_region" {
  type = string
}

variable "disk_type" {
  type = string
}
