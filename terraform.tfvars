cluster_name          = "okd"
base_domain           = "okd.nmandadhi.com"
base_domain_zone_name = "okd-nmandadhi-com"
region                = "us-central1"
kms_region            = "us-central1"
zones = [
  "us-central1-a",
  "us-central1-b",
  "us-central1-f"
]
disk_type                 = "pd-ssd"
control_plane_subnet_cidr = "10.0.0.0/28"
compute_subnet_cidr       = "10.1.0.0/16"
pods_cidr                 = "10.2.0.0/16"
services_cidr             = "10.3.0.0/20"
bootstrap_machine_type    = "e2-standard-4"
master_machine_type       = "e2-standard-4"
worker_machine_type       = "e2-standard-4"

# Set to zero for user provisioned infrastructure
num_master_nodes = 3
num_worker_nodes = 0