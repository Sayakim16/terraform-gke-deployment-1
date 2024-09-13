# externaldns.tf
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
