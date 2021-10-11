variable "cluster_project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "publish_external" {
  type    = bool
  default = false
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}