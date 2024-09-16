# terraform-gke-deployment
Clone from Github to local, execute bastion.sh file, it creates bastion Vm in GCP

Create hosted zone in GCP if you are going to deploy with your domain name.

From your root path, add host to the file ***vi .ssh/config***
```
Host berkay-bastion    #Replace to your own name
    HostName xx.xx.xx.xx      # Replace with your bastion's external IP
    User oz.hidiroglu           # Replace with your Google Cloud username
    IdentityFile ~/.ssh/google_compute_engine
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
```
For not always running belowing commands, we put in our .ssh/config file
    
```
gcloud auth application-default login --scopes=https://www.googleapis.com/auth/cloud-platform  
gcloud compute ssh NAME_OF_YOUR_MACHINE --zone us-central1-a   
```

***SSH*** to your bastion and clone repository again,execute ***package.sh***

Execute cluster folder, create there ***.tfvars*** file , and run terraform init, terraform apply commands

In my case i do not  need config folder , cause i don`t need cert-manager , external dns , i had choosen LB IP.

You need to connect bastion with gke cluster, for that deploy CLI to your bastion
```
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates gnupg curl
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli
gcloud components install gke-gcloud-auth-plugin
```

Get inside your GKe Cluster, get command from GCP/Kubernetes Engine
```
gcloud container clusters get-credentials argocd-cluster --region us-central1 --project argocd-435718
```
We need to deploy CRDs to connect our Kubernetes with 3rd party tools like Helm
```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
```
After this, if you are deploying your ArgiCD with your domain_name ex ***argocd.example.com***, so go to config folder, create your own .tfvars file and execute . 

#2nd Option is like mine :

Deploy ArgoCD decleratively 
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm repo list
helm install argocd argo/argo-cd --namespace argocd --create-namespace
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc -n argocd
```
Retrieve password
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Check your remote git repository,if it is someoneelse git folder URL,then remove and add your github account/repository`s URL, before this, open in your github account the folder. Replace to your own path.

```
git remote -v 
git remote remove origin
git remote add origin https://github.com/YOUR-USERNAME/terraform-gke-deployment.git
git push -u origin main --force
```