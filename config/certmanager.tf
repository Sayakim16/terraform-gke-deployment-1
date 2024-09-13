# Create the namespace for cert-manager if it doesn't already exist
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Create a service account for cert-manager in Google Cloud
resource "google_service_account" "cert_manager" {
  account_id   = "cert-manager-sa"
  display_name = "Cert Manager Service Account"
}

# Assign DNS Admin role to the Google Cloud service account
resource "google_project_iam_member" "cert_manager_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager.email}"
}

# Create Kubernetes service account in the GKE cluster for cert-manager
resource "kubernetes_service_account" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.cert_manager.email}"
    }
  }
}

# Bind the Kubernetes service account to the Google Cloud service account using Workload Identity
resource "google_service_account_iam_member" "cert_manager_binding" {
  service_account_id = google_service_account.cert_manager.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"
}

# Deploy cert-manager using Helm, using the Kubernetes service account created above
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"

  create_namespace = false

  values = [
    <<EOF
    google:
      project: ${var.project_id}
    serviceAccount:
      create: false
      name: cert-manager
    EOF
  ]
}

# Update ClusterIssuer to use DNS-01 with Google CloudDNS
resource "kubernetes_manifest" "letsencrypt_prod_issuer" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
        }
        solvers = [
          {
            dns01 = {
              cloudDNS = {
                project = var.project_id
                hostedZoneName = "berkayh"  # Replace with your CloudDNS zone name
              }
            }
          }
        ]
      }
    }
  }
}


resource "kubernetes_manifest" "argo_domain_certificate" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "argocd-cert"
      namespace = "argocd"
    }
    spec = {
      secretName = "argocd-tls-secret"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }

      commonName = "argocd.${var.domain}"
      dnsNames   = ["argocd.${var.domain}"]
    }
  }
}
