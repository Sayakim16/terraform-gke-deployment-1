# Create the namespace for external-dns if it doesn't already exist
resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

# Create a service account for External DNS in Google Cloud
resource "google_service_account" "external_dns" {
  account_id   = "external-dns-sa"
  display_name = "External DNS Service Account"
}

# Assign DNS Admin role to the Google Cloud service account
resource "google_project_iam_member" "external_dns_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns.email}"
}

# Create Kubernetes service account in the GKE cluster
resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.external_dns.email}"
    }
  }
}

# Bind the Kubernetes service account to the Google Cloud service account using Workload Identity
resource "google_service_account_iam_member" "external_dns_binding" {
  service_account_id = google_service_account.external_dns.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"
}

# Deploy External DNS using Helm, using the Kubernetes service account created above
# /config/externaldns.tf

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "external-dns"

  values = [
    <<EOF
    provider: google
    google:
      project: ${var.project_id}
    domainFilters:
      - "${var.domain}"
    sources:
      - service
    namespace: argocd # Add this to explicitly set the namespace
    serviceAccount:
      create: false
      name: external-dns
    EOF
  ]
}


