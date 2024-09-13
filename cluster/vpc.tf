# /cluster/vpc.tf

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.2"

  project_id   = var.project_id
  network_name = "gke-vpc-network"

  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.0.0.0/16"
      subnet_region         = var.region
      subnet_flow_logs      = "true"
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "10.2.0.0/20"
      }
    ]
  }
}
