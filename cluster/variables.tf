# /cluster/variable.tf

variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "gke_cluster_version" {
  description = "Kubernetes version for GKE cluster"
  type        = string
}
