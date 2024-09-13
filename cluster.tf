# cluster.tf
module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google"
  project_id        = var.project_id
  name              = var.gke_cluster_name
  region            = var.region
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  kubernetes_version = var.gke_cluster_version

  node_pools = [
    {
      name               = "default-pool"
      machine_type       = "e2-micro" # Smallest machine type
      min_count          = 1
      max_count          = 1
      disk_size_gb       = 30
      preemptible        = true
    },
  ]

  ip_range_pods     = "pods"
  ip_range_services = "services"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id   = var.project_id
  network_name = "gke-vpc-network"

  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.0.0.0/16"
      subnet_region         = var.region
      subnet_flow_logs      = "true"
      subnet_private_access = "true"
    },
  ]
}

output "gke_cluster_name" {
  value = module.gke.name
}

output "gke_endpoint" {
  value = module.gke.endpoint
}

output "gke_cluster_version" {
  value = module.gke.master_version
}
