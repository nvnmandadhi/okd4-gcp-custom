variable "project" {
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

variable "ssh_public_key_location" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "base_domain_zone_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "master_subnet_cidr" {
  type = string
}

variable "worker_subnet_cidr" {
  type = string
}