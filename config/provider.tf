provider "google" {
  project = var.project_id
  region  = var.region
}

# Use google_container_cluster data to retrieve the cluster endpoint and authentication
data "google_container_cluster" "gke_cluster" {
  name     = var.gke_cluster_name
  location = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}
