# /config/variable.tf
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

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt"
  type        = string
}

variable "domain" {
  description = "Domain for external DNS and certificates"
  type        = string
}

variable "hostedzone_name" {
  description = "Hosted zone name in Google CloudDNS"
  type        = string
}