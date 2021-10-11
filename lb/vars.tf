variable "infraID" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_network" {
  type = string
}

variable "control_subnet" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "bootstrap_instance_group" {
  type = list(string)
}

variable "master_instances" {
  type = list(string)
}