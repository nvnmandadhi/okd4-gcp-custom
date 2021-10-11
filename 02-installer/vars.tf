variable "cluster_project_id" {
  type = string
}

variable "tf_sa_email" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "num_master_nodes" {
  type = number
}

variable "num_worker_nodes" {
  type = number
}

variable "region" {
  type = string
}

variable "disk_type" {
  type = string
}

variable "kms_region" {
  type = string
}

variable "pods_cidr" {
  type = string
}

variable "services_cidr" {
  type = string
}

variable "control_plane_subnet_cidr" {
  type = string
}

variable "compute_subnet_cidr" {
  type = string
}

variable "shared_net_project_id" {
  type = string
}

variable "publish_external" {
  type    = bool
  default = false
}

