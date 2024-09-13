# certmanager.tf
# Install Cert Manager via Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"

  values = [
    <<EOF
    installCRDs: true
    EOF
  ]
}

# Let's Encrypt ClusterIssuer for production
resource "kubernetes_manifest" "letsencrypt_prod_issuer" {
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
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

# SSL Certificate for ArgoCD
resource "kubernetes_manifest" "argo_domain_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "argocd-cert"
      namespace = "argocd"
    }
    spec = {
      secretName = "argocd-tls-secret" # Secret where the certificate will be stored
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      commonName = var.domain # Your domain
      dnsNames   = [var.domain] # Add domain name here
    }
  }
}
