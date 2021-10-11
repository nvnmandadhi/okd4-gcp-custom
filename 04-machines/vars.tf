variable "tf_sa_email" {
  type = string
}

variable "cluster_project_id" {
  type = string
}

variable "master_machine_type" {
  type = string
}

variable "zones" {
  type = list(string)
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

variable "disk_type" {
  type = string
}

variable "shared_net_project_id" {
  type = string
}

variable "publish_external" {
  type    = bool
  default = false
}
