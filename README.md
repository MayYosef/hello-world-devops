# Hello World Node- DevOps Project

## About

This repository provides a complete solution for a DevOps assignment:

- **Task 1:** Provision infrastructure on AWS with Terraform (VPC, EKS)
- **Task 2:** Create CI/CD pipeline to build and push Docker images to AWS ECR
			& Deploy a high-availability Node.js application (GitHub Actions → ECR → EKS via ArgoCD)
- **Logging:** Loki installed with Helm (`grafana/loki-stack`) + Grafana + Promtail
- **Auto-scaling:** HPA and CronJobs with RBAC for controlled, scheduled scaling

---

## 📁 Project Structure

```
.
├── hello-world-node-app/   # Node.js application source code
├── infra/					# Terraform infrastructure files
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars 	# (Doesn't contain secret variables)
│   ├── vpc.tf
│   └── eks.tf
├── .github/workflows/build-and-deploy.yml   # GitHub Actions workflow (build and deploy)
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   ├── cronjob-scale-up.yaml
│   ├── cronjob-scale-down.yaml
│   ├── scale-serviceaccount.yaml
│   ├── scale-role.yaml
│   ├── scale-rolebinding.yaml
│   └── argocd-app.yaml
├── .gitignore
└── README.md
```

---

## ☁️ Terraform

```
terraform init
terraform plan
terraform apply
```

Creates:

- VPC (2 AZs, public/private subnets)
- One NAT Gateway, serving all Private Subnets (by internetGW)
- EKS with managed node groups
- **Outputs:** VPC ID, public/private subnet IDs, EKS cluster name & endpoint
Run ```terraform output``` to view them.

EKS API Access Configuration
In the Terraform file for the EKS module, the following parameters are configured:

endpoint_private_access = true
Enables API access only from within the VPC.

endpoint_public_access = true
Enables API access from outside the VPC, e.g., from your local machine or any internet IP.

public_access_cidrs = ["0.0.0.0/0"]
Allows API access from any IP address, for convenience during development and testing.

⚠️ Note: This configuration is suitable for development or homework environments only.
In production environments, restrict access to specific IP addresses or use a VPN for enhanced security.

---

## 🚀 CI/CD Workflow

- Builds Docker image and tags with commit SHA (& latest)
- Pushes to ECR (to new repository- "may-hello-world-node")
- Updates `deployment.yaml` with new image tag
- Commits the updated manifest back to the `main` branch
- ArgoCD detects the change and syncs automatically

Secrets used:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Repository variables:

- `AWS_REGION`
- `ECR_REPOSITORY`

## Notes
- The GitHub Actions workflow (`.github/workflows/...`) is currently triggered on **every push** to the `main` branch.
- For production use, it is recommended to limit the trigger using the `paths` filter to run only when the application code changes.
  ```yaml
  on:
    push:
      branches:
        - main
      paths:
        - 'hello-world-node-app/**'
 ```
- For easier testing during development, the filter is commented out for now.

---

## 🔗 ArgoCD

- Installed on EKS cluster
- Connected to this GitHub repo
- `argocd-app.yaml` defines the target repo, branch and path (`k8s/`)
- ArgoCD syncs automatically on changes

---

## 📊 Logs & Monitoring — Grafana + Loki

- Loki installed via Helm (`grafana/loki-stack`)
- Promtail collects Pod logs and ships them to Loki
- Grafana installed for dashboards and visualization

Note: For production use, Loki should be configured with a durable backend such as S3 or GCS. 
For demo purposes, local ephemeral storage is used.

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki-stack grafana/loki-stack --namespace logging
```

Port-forward Grafana for local access:

```kubectl port-forward --namespace logging svc/loki-stack-grafana 3000:80```
 → http://localhost:3000

---

### ✅ Dashboard Panels

**The Grafana dashboard includes:**

1. **Live Logs**
   - Real-time view of all application logs:
     ```logql
     {app="hello-world-node"}
     ```

2. **Error Logs**
   - Filtered view showing only error lines:
     ```logql
     {app="hello-world-node"} |= "error"
     ```

3. **Log Volume Over Time**
   - Shows log count over 5m intervals:
     ```logql
     count_over_time({app="hello-world-node"}[5m])
     ```


### 🎯 Purpose

- Observe real-time application behavior.
- Detect and debug issues quickly.
- Identify high-traffic periods (like daily peak at 10:00 AM).

---

## ⚙️ HPA & Performance

- `hpa.yaml` configures auto-scaling when CPU > 80%

Every morning at 10:00 AM, the app experiences predictable high traffic which the HPA alone cannot handle fast enough,
sometimes causing downtime during peak load. 

I added:
- `cronjob-scale-up.yaml` runs daily at 09:55 to pre-scale replicas
- `cronjob-scale-down.yaml` runs at 11:00 to scale back down
- CronJobs use `ServiceAccount` + `Role` + `RoleBinding` for RBAC

To handle predictable daily peak traffic, 
I configured a Horizontal Pod Autoscaler (HPA) together with scheduled scaling using Kubernetes CronJobs. 
The CronJobs proactively increase the number of replicas shortly before the peak and scale them back down afterward, 
ensuring zero downtime during high load periods.

Although the HPA can downscale replicas automatically, when traffic patterns are predictable, 
it’s a good practice to reset the minimum replica count back to its baseline to avoid unnecessary resource waste. 

---

## ✅ How to Test

- **Terraform** → plan/apply
- **CI/CD:** Push to `main` → check Actions log → check ECR → check ArgoCD UI → check `kubectl get pods`
- **Logs:** Access Grafana dashboard or query Loki API
- **HPA:** Simulate load → watch pods auto-scale
- **CronJobs:** Temporarily adjust `schedule:` to run every few minutes for testing

Example:

```bash
kubectl get deployment
kubectl get hpa
kubectl get cronjobs
kubectl logs <pod-name>
```

---

## 🔒 RBAC Notes

- The CronJobs are restricted to patching only the `hello-world-node` Deployment.
- ServiceAccount `scale-jobs-sa` bound to `Role` with `get`, `list`, `update`, `patch`

---

## 🗑️ Clean Up

- Destroy infra:
  ```bash
  terraform destroy
  ```
- Uninstall Loki & Grafana:
  ```bash
  helm uninstall loki-stack --namespace logging
  ```
- Manually clean ECR images if needed.
- Terminate unused EKS nodes/volumes.

---

📘 **Good luck!**

