# provider.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "helm" {
  kubernetes {
    host                   = module.gke.endpoint
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}
