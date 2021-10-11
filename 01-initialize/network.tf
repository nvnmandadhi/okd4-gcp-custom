module "net" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  network_name = "okd-net-${random_id.rand.hex}"
  routing_mode = "GLOBAL"
  project_id   = var.shared_net_project_id
  mtu          = 1460

  subnets = [
    {
      subnet_name           = "${var.cluster_name}-control-plane-snet"
      subnet_ip             = var.control_plane_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
    },
    {
      subnet_name           = "${var.cluster_name}-compute-snet"
      subnet_ip             = var.compute_subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    "compute-snet" = [
      {
        range_name    = "${var.cluster_name}-pods"
        ip_cidr_range = var.pods_cidr
      },
      {
        range_name    = "${var.cluster_name}-services"
        ip_cidr_range = var.services_cidr
      },
    ]
  }
}

resource "google_compute_shared_vpc_service_project" "svc_project" {
  host_project    = var.shared_net_project_id
  service_project = var.cluster_project_id
}

resource "google_compute_subnetwork_iam_binding" "subnet_iam" {
  for_each = { for k, v in module.net.subnets_self_links : k => v }

  role       = "roles/compute.networkUser"
  subnetwork = each.value
  members = [
    "serviceAccount:${data.google_project.cluster_project.number}@cloudservices.gserviceaccount.com",
    "serviceAccount:${google_service_account.master.email}",
    "serviceAccount:${google_service_account.worker.email}"
  ]
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"

  name    = "${var.cluster_name}-router"
  project = var.shared_net_project_id
  network = module.net.network_name
  region  = var.region

  nats = [{
    name                               = "${var.cluster_name}-nat-gwy"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    log_config = {
      enable = false
      filter = "ERRORS_ONLY"
    }
  }]
}