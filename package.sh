#!/bin/bash

# Authenticate to Google Cloud inside the bastion host
echo "Authenticating to Google Cloud inside the bastion..."
gcloud auth login

# Install kubectl in /usr/local/bin
echo "Installing kubectl..."
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify kubectl installation
kubectl version --client

# Install Helm in /usr/local/bin
echo "Installing Helm..."
curl -LO https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz
tar -zxvf helm-v3.9.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm-v3.9.0-linux-amd64.tar.gz

# Verify Helm installation
helm version

# Install ArgoCD CLI in /usr/local/bin
echo "Installing ArgoCD CLI..."
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Verify ArgoCD CLI installation
argocd version --client

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

echo "kubectl, Helm, ArgoCD CLI, and Git are now installed and ready to use."
