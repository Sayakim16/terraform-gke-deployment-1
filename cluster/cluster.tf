# /cluster/cluster.tf

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google"
  project_id        = var.project_id
  name              = var.gke_cluster_name
  region            = var.region
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  kubernetes_version = var.gke_cluster_version

  remove_default_node_pool = true   # Prevent GKE from creating the default node pool
  initial_node_count = 1            # Required when `remove_default_node_pool` is true

  node_pools = [
    {
      name               = "default-pool"
      machine_type       = "e2-medium" 
      min_count          = 1
      max_count          = 1
      disk_size_gb       = 30
      preemptible        = true
    },
  ]

  ip_range_pods     = "pods-range"
  ip_range_services = "services-range"

  depends_on = [module.vpc]
}

output "gke_cluster_name" {
  value = module.gke.name
}

output "connect_to_cluster" {
  description = "Command to connect to the GKE cluster"
  value       = "Run the following command to connect to the cluster: gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${var.project_id}"
}
