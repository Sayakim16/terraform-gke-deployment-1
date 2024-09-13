#!/bin/bash

# Authenticate for gcloud CLI interactive use
echo "Authenticating to Google Cloud with gcloud login..."
gcloud auth login

# Authenticate for application use (used by Terraform and other programs)
echo "Authenticating to Google Cloud with application-default login..."
gcloud auth application-default login --scopes=https://www.googleapis.com/auth/cloud-platform

# Install Terraform via Snap with --classic flag
echo "Installing Terraform via Snap with classic confinement..."
sudo snap install terraform --classic

# Install kubectl in /usr/local/bin
echo "Installing kubectl..."
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install Helm in /usr/local/bin
echo "Installing Helm..."
curl -LO https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz
tar -zxvf helm-v3.9.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm-v3.9.0-linux-amd64.tar.gz

# Install ArgoCD CLI in /usr/local/bin
echo "Installing ArgoCD CLI..."
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

echo "Terraform, kubectl, Helm, ArgoCD CLI, and Git are now installed."
