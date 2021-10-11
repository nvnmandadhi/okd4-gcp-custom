variable "infraID" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "control_subnet" {
  type = string
}

variable "master_ign" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "fedora_coreos_image" {
  type = string
}

variable "master_sa_email" {
  type = string
}