# /config/argo.tf

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"

  create_namespace = true

  values = [
    <<EOF
    server:
      service:
        type: LoadBalancer
        annotations:
          external-dns.alpha.kubernetes.io/hostname: "argocd.${var.domain}"  # This allows ExternalDNS to create the DNS record
    EOF
  ]
}
