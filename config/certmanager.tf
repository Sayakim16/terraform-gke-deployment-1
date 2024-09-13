# In cert-manager Helm release values
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace  = "cert-manager"

  create_namespace = true

  version = "v1.7.1"  # Specify the version to avoid issues with latest changes

  # Ensure CRDs are installed
  set {
    name  = "installCRDs"
    value = "false"
  }

  # Configure HTTP-01 solver to use LoadBalancer for public accessibility
  values = [
    <<EOF
    http01:
      solver:
        serviceType: LoadBalancer
        ingress:
          annotations:
            cert-manager.io/acme-http01-edit-in-place: "true"
            nginx.ingress.kubernetes.io/ssl-redirect: "false"
            nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
            nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0,::/0
    EOF
  ]
}



# Ensure that the CRDs are installed before applying the ClusterIssuer manifest
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

# Ensure Certificate manifest waits until Cert Manager is installed
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
      commonName = var.domain
      dnsNames   = [var.domain]
    }
  }
}
