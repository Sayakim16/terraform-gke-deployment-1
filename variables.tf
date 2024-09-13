# variables.tf
variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "region" {
  description = "Google Cloud region"
  default     = "us-central1"
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  default     = "my-gke-cluster"
}

variable "gke_cluster_version" {
  description = "Version of GKE"
  default     = "1.26.9-gke.1000"
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt registration"
  default     = "your-email@example.com"
}

variable "domain" {
  description = "Domain name to attach to the load balancer"
  default     = "example.com"
}
