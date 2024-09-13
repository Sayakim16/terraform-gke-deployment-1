#!/bin/bash

# Authenticate to Google Cloud
echo "Authenticating to Google Cloud..."
gcloud auth login

# Set your Google Cloud project
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
gcloud config set project $PROJECT_ID

# Set your region (default: us-central1)
read -p "Enter the region (default: us-central1): " REGION
REGION=${REGION:-"us-central1"}

# Set your zone (default: us-central1-a)
read -p "Enter the zone (default: us-central1-a): " ZONE
ZONE=${ZONE:-"us-central1-a"}

# Set the machine type (default: e2-micro)
read -p "Enter the machine type (default: e2-micro): " MACHINE_TYPE
MACHINE_TYPE=${MACHINE_TYPE:-"e2-micro"}

# Set variables for the bastion host
read -p "Enter the name for the bastion host (e.g., bastion-host): " BASTION_HOST_NAME

# Create a network for the bastion host if not already created
NETWORK_NAME="bastion-network"
if ! gcloud compute networks describe $NETWORK_NAME &>/dev/null; then
  echo "Creating network: $NETWORK_NAME"
  gcloud compute networks create $NETWORK_NAME --subnet-mode=auto
else
  echo "Network $NETWORK_NAME already exists"
fi

# Create firewall rules to allow SSH traffic if they don't exist
FIREWALL_NAME="allow-ssh"
if ! gcloud compute firewall-rules describe $FIREWALL_NAME &>/dev/null; then
  echo "Creating firewall rule to allow SSH traffic"
  gcloud compute firewall-rules create $FIREWALL_NAME \
    --network $NETWORK_NAME \
    --allow tcp:22
else
  echo "Firewall rule $FIREWALL_NAME already exists"
fi

# Create the bastion host (using Ubuntu)
echo "Creating bastion host: $BASTION_HOST_NAME"
gcloud compute instances create $BASTION_HOST_NAME \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --network=$NETWORK_NAME \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --tags=bastion \
  --metadata startup-script="#! /bin/bash
sudo apt-get update"

# Ensure the instance is created and running
echo "Waiting for instance to start..."
sleep 20

# Check if the instance is running
STATUS=$(gcloud compute instances describe $BASTION_HOST_NAME --zone=$ZONE --format='get(status)')
if [[ "$STATUS" != "RUNNING" ]]; then
  echo "Instance $BASTION_HOST_NAME is not in RUNNING state. Current state: $STATUS"
  exit 1
fi

# Ensure the instance has an external IP address
EXTERNAL_IP=$(gcloud compute instances describe $BASTION_HOST_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
if [[ -z "$EXTERNAL_IP" ]]; then
  echo "No external IP address assigned to the instance. Assigning one now..."
  gcloud compute instances add-access-config $BASTION_HOST_NAME --zone $ZONE
  EXTERNAL_IP=$(gcloud compute instances describe $BASTION_HOST_NAME --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
  echo "External IP assigned: $EXTERNAL_IP"
else
  echo "External IP already assigned: $EXTERNAL_IP"
fi

# Wait for the SSH key to propagate
echo "Waiting for SSH key to propagate..."
sleep 30

# SSH into the bastion host
echo "SSH-ing into the bastion host..."
gcloud compute ssh $BASTION_HOST_NAME --zone $ZONE -- -t 'bash -s' << 'EOF'
echo "You are now inside the bastion host!"
EOF
