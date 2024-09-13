# ArgoCD Deployment with Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"

  values = [
    <<EOF
    server:
      service:
        type: LoadBalancer
        annotations:
          external-dns.alpha.kubernetes.io/hostname: "${var.domain}"
    EOF
  ]
}

# Cert Manager and External DNS for domain management
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

resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"

  values = [
    <<EOF
    provider: google
    domainFilters:
      - "${var.domain}"
    EOF
  ]
}
