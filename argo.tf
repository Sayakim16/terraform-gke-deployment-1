# argo.tf
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
      ingress:
        enabled: true
        hosts:
          - "${var.domain}"
        tls:
          - secretName: argocd-tls-secret
            hosts:
              - "${var.domain}"
    EOF
  ]
}
