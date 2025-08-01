# ☁️ Cloud & Infrastructure (28 tools)
**Cloud providers, container orchestration, and infrastructure automation**

[🏠 Back to Wiki Home](../index.md) | [📚 All Categories](../index.md#-tool-categories)

---

## 🚀 Category Overview

Enterprise-grade cloud and infrastructure management tools:
- **Multi-cloud support** for AWS, Azure, GCP, and hybrid environments
- **Container orchestration** with Kubernetes ecosystem tools
- **Infrastructure as Code** with Terraform and configuration management
- **CI/CD integration** for modern DevOps workflows

---

## ☁️ Cloud Provider CLIs

### **AWS CLI** - v2.7.13 ⭐ **Industry Standard**
Official Amazon Web Services command-line interface.
- **Features**: Complete AWS API coverage, profiles, SSO integration
- **Authentication**: IAM roles, profiles, SSO, MFA support
- **Usage**: `aws s3 sync ./local s3://bucket --profile prod`
- **Advanced**: `aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name]'`
- **Location**: `bin-tools/aws/aws.exe`

### **Azure CLI (az)** - v2.61.0 ⭐ **Microsoft Cloud**
Microsoft Azure command-line interface with comprehensive cloud management.
- **Features**: Interactive mode, JMESPath queries, extension ecosystem
- **Authentication**: Service principals, managed identity, device flow
- **Usage**: `az vm create --resource-group myRG --name myVM --image Ubuntu2204`
- **Extensions**: `az extension add --name containerapp`
- **Location**: `bin-tools/azure/az.exe`

### **Google Cloud CLI (gcloud)** - Google Cloud Platform
Official Google Cloud Platform command-line tool.
- **Features**: Service management, authentication, configuration
- **Usage**: `gcloud compute instances list`, `gcloud auth login`
- **Location**: `bin-tools/gcloud/gcloud.exe` (if available)

---

## 🚢 Kubernetes Ecosystem

### **kubectl** - v1.33.0 ⭐ **Essential**
Official Kubernetes command-line tool for cluster management.
- **Features**: Resource management, debugging, port forwarding, logs
- **Contexts**: Multi-cluster management with context switching
- **Usage**: `kubectl get pods -n production --watch`
- **Advanced**: `kubectl top nodes && kubectl describe node worker-1`
- **Location**: `bin-tools/kubectl/kubectl.exe`

### **Helm** - v3.11.2 ⭐ **Package Manager**
Kubernetes package manager for application deployment.
- **Features**: Chart repositories, templating, rollbacks, hooks
- **Usage**: `helm install myapp stable/wordpress --set persistence.enabled=true`
- **Chart Management**: `helm repo add bitnami https://charts.bitnami.com/bitnami`
- **Location**: `bin-tools/helm/helm.exe`

### **k9s** - v0.50.3 ⭐ **Interactive TUI**
Terminal-based UI for Kubernetes cluster management.
- **Features**: Real-time cluster monitoring, resource navigation, log streaming
- **Interface**: Vim-like navigation, contextual actions, plugin support
- **Usage**: `k9s` (interactive mode with arrow key navigation)
- **Shortcuts**: `:pods` → Enter → `l` (logs), `:nodes` → `d` (describe)
- **Location**: `bin-tools/k9s/k9s.exe`

### **Minikube** - Local Kubernetes
Local Kubernetes cluster for development and testing.
- **Features**: Multi-driver support, addon ecosystem, dashboard
- **Usage**: `minikube start --driver=docker --kubernetes-version=v1.33.0`
- **Addons**: `minikube addons enable ingress dashboard`
- **Location**: `bin-tools/minikube/minikube.exe`

---

## 🏗️ Infrastructure as Code

### **Terraform** - v1.7.5 ⭐ **IaC Leader**
HashiCorp's infrastructure as code tool for multi-cloud provisioning.
- **Features**: Multi-cloud support, state management, plan/apply workflow
- **Providers**: AWS, Azure, GCP, Kubernetes, VMware, and 3000+ providers
- **Usage**: `terraform plan -var-file=prod.tfvars && terraform apply`
- **Advanced**: `terraform import aws_instance.web i-1234567890abcdef0`
- **Location**: `bin-tools/terraform/terraform.exe`

### **Consul** - Service discovery
HashiCorp Consul for service mesh and service discovery.
- **Features**: Service registry, health checking, KV store, Connect
- **Usage**: `consul catalog services && consul kv get config/app`
- **Location**: `bin-tools/consul/consul.exe`

---

## 🐳 Container Tools

### **Docker Compose** - v2.24.6 ⭐ **Multi-Container**
Tool for defining and running multi-container Docker applications.
- **Features**: YAML configuration, service dependencies, networking, volumes
- **Usage**: `docker-compose up -d && docker-compose logs -f web`
- **Scaling**: `docker-compose up --scale web=3 --scale worker=2`
- **Location**: `bin-tools/docker/docker-compose.exe`

### **Container Registry Tools**
Enterprise container registry management utilities.
- **Features**: Image scanning, vulnerability assessment, registry sync
- **Usage**: Manage private registries and artifact repositories
- **Location**: `bin-tools/containers/`

---

## 📊 Monitoring & Observability

### **Prometheus Tools (promtool)** - Monitoring toolkit
Prometheus configuration and query tools.
- **Features**: Config validation, query testing, TSDB inspection
- **Usage**: `promtool check config prometheus.yml`
- **Query**: `promtool query instant 'up{job="api"}'`
- **Location**: `bin-tools/prometheus/promtool.exe`

### **Telegraf** - Metrics collection
InfluxData's metrics collection and reporting agent.
- **Features**: 300+ input plugins, output to multiple backends
- **Usage**: `telegraf --config telegraf.conf --test`
- **Location**: `bin-tools/telegraf/telegraf.exe`

---

## 🔧 DevOps & CI/CD

### **GitHub CLI (gh)** - GitHub integration
Official GitHub command-line tool for repository management.
- **Features**: PR management, issue tracking, workflow automation
- **Usage**: `gh pr create --title "Feature X" --body "Description"`
- **Workflows**: `gh workflow run deploy.yml --ref main`
- **Location**: `bin-tools/github/gh.exe`

### **GitLab CLI (glab)** - GitLab integration
Command-line tool for GitLab repository and CI/CD management.
- **Features**: Merge requests, pipeline management, issue tracking
- **Usage**: `glab mr create --source-branch feature --target-branch main`
- **Location**: `bin-tools/gitlab/glab.exe`

---

## 🌐 Service Mesh & Networking

### **Istio Tools** - Service mesh management
Command-line tools for Istio service mesh configuration.
- **Features**: Traffic management, security policies, observability
- **Usage**: `istioctl analyze --namespace production`
- **Proxy**: `istioctl proxy-config cluster productpage-v1-123456`
- **Location**: `bin-tools/istio/istioctl.exe`

### **OpenShift CLI (oc)** - Enterprise Kubernetes
Red Hat OpenShift command-line interface for enterprise Kubernetes.
- **Features**: Developer workflows, build automation, route management
- **Usage**: `oc new-app nodejs~https://github.com/user/app.git`
- **Routes**: `oc expose service myapp --hostname=myapp.example.com`
- **Location**: `bin-tools/openshift/oc.exe`

---

## 🚀 Complete Cloud Workflows

### Multi-Cloud Infrastructure Management
```bash
# AWS: Create and manage EC2 instances
aws ec2 run-instances --image-id ami-12345 --instance-type t3.micro --key-name mykey
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'

# Azure: Create resource group and VM
az group create --name myResourceGroup --location eastus
az vm create --resource-group myResourceGroup --name myVM --image Ubuntu2204 --admin-username azureuser

# Terraform: Multi-cloud infrastructure
terraform init
terraform plan -var-file=environments/prod.tfvars
terraform apply -auto-approve
```

### Kubernetes Application Deployment
```bash
# Cluster management
kubectl config get-contexts
kubectl config use-context production-cluster
kubectl create namespace myapp

# Application deployment with Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install myapp bitnami/wordpress --namespace myapp --create-namespace

# Monitor deployment
kubectl get pods -n myapp --watch
kubectl logs -f deployment/myapp-wordpress -n myapp
k9s --namespace myapp
```

### Container Orchestration
```bash
# Docker Compose workflow
docker-compose -f docker-compose.prod.yml up -d
docker-compose logs -f --tail=100 web
docker-compose exec web bash

# Scale services
docker-compose up --scale web=3 --scale worker=2
docker-compose ps

# Health checks and maintenance
docker-compose exec db mysqldump -u root -p myapp > backup.sql
```

---

## 🔧 Advanced Configuration

### AWS CLI Configuration
```bash
# Modern SSO setup
aws configure sso --profile production
aws configure set region us-west-2 --profile production
aws configure set output json --profile production

# Use profiles
export AWS_PROFILE=production
aws s3 ls
aws sts get-caller-identity
```

### Kubectl Configuration
```bash
# Context management
kubectl config get-contexts
kubectl config use-context staging
kubectl config set-context --current --namespace=myapp

# Cluster information
kubectl cluster-info
kubectl get nodes -o wide
kubectl describe node worker-1
```

### Terraform Workspace Management
```bash
# Environment separation
terraform workspace list
terraform workspace new production
terraform workspace select production

# Apply with environment-specific variables
terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars

# State management
terraform state list
terraform state show aws_instance.web
```

---

## 📊 Cloud Cost Management

### Resource Monitoring
```bash
# AWS cost analysis
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# Azure cost analysis
az consumption usage list --top 10
az consumption budget list

# Resource inventory
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name]'
az vm list --output table
```

---

## 💡 Pro Tips

1. **Use Cloud Shell**: Leverage cloud providers' built-in terminals for authenticated access
2. **Profile Management**: Organize credentials with profiles for different environments
3. **Infrastructure Versioning**: Version control your Terraform and Helm configurations
4. **Cost Monitoring**: Set up billing alerts and regularly review resource usage
5. **Security Best Practices**: Use IAM roles and least-privilege access principles
6. **Automation**: Script common cloud operations for consistency and efficiency

---

## 🔗 Related Categories

- **[🛡️ Security & Cryptography](security.md)** - Cloud security and compliance tools
- **[📊 System Monitoring](monitoring.md)** - Infrastructure monitoring and alerting
- **[💻 Development Tools](development.md)** - CI/CD and development workflows

---

*Use `portx cloud` to view this category | `portx search <term>` to find specific tools*

**[⬆️ Back to Top](#️-cloud--infrastructure-28-tools)** | **[🏠 Wiki Home](../index.md)**