# Kubernetes Tools Package Manual

## Package Information
- **Package Name**: k8
- **Category**: Containers
- **Type**: Kubernetes Management
- **License**: Apache 2.0

## Description
Kubernetes command-line tools for container orchestration and cluster management.

Essential tools for deploying, managing, and troubleshooting Kubernetes clusters and applications.
Provides both core Kubernetes management and configuration customization capabilities.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| kubectl.exe | Kubernetes command-line interface | Manage Kubernetes clusters and resources |
| kustomize.exe | Kubernetes configuration customization | Template-free configuration management |

## Common Usage Examples

### Cluster Information
```bash
# Get cluster information
kubectl cluster-info

# Check cluster nodes
kubectl get nodes

# View cluster status
kubectl get componentstatuses
```

### Pod Management
```bash
# List all pods
kubectl get pods --all-namespaces

# Create pod from YAML
kubectl apply -f pod.yaml

# Delete pod
kubectl delete pod mypod

# Get pod logs
kubectl logs mypod

# Execute command in pod
kubectl exec -it mypod -- /bin/bash
```

### Service Management
```bash
# List services
kubectl get services

# Expose deployment as service
kubectl expose deployment myapp --type=LoadBalancer --port=80

# Port forward to local machine
kubectl port-forward service/myservice 8080:80
```

### Deployment Management
```bash
# Create deployment
kubectl create deployment myapp --image=nginx

# Scale deployment
kubectl scale deployment myapp --replicas=3

# Update deployment image
kubectl set image deployment/myapp container=nginx:latest

# Roll back deployment
kubectl rollout undo deployment/myapp
```

### Configuration Management with Kustomize
```bash
# Build kustomized configuration
kustomize build overlays/production

# Apply kustomized configuration
kubectl apply -k overlays/production

# Create kustomization.yaml
kustomize create --autodetect
```

### Namespace Management
```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace mynamespace

# Set default namespace
kubectl config set-context --current --namespace=mynamespace
```

### ConfigMaps and Secrets
```bash
# Create configmap
kubectl create configmap myconfig --from-file=config.properties

# Create secret
kubectl create secret generic mysecret --from-literal=password=secret123

# View secret (base64 encoded)
kubectl get secret mysecret -o yaml
```

### Resource Monitoring
```bash
# View resource usage
kubectl top nodes
kubectl top pods

# Describe resource details
kubectl describe pod mypod

# Get resource YAML
kubectl get pod mypod -o yaml
```

### Troubleshooting
```bash
# Get events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug pod issues
kubectl describe pod mypod

# Check pod logs
kubectl logs mypod --previous

# Get pod shell access
kubectl exec -it mypod -- sh
```

## Kustomize Features
- **Template-free**: No templating, just YAML manipulation
- **Layered configs**: Base + overlays for different environments
- **Resource patching**: Modify configurations without duplicating
- **Built-in transformers**: Add labels, annotations, name prefixes/suffixes

## Installation
Essential Kubernetes tools for container orchestration and cluster management.
Includes both kubectl for cluster operations and kustomize for configuration management.

## Dependencies
- Access to Kubernetes cluster
- Valid kubeconfig file (~/.kube/config)
- Network connectivity to cluster API server

## Configuration
Configure kubectl with:
```bash
# Set cluster credentials
kubectl config set-cluster mycluster --server=https://cluster-api-server

# Set user credentials  
kubectl config set-credentials myuser --token=token

# Set context
kubectl config set-context mycontext --cluster=mycluster --user=myuser

# Use context
kubectl config use-context mycontext
```

---
*Part of PORTX Portable Development Environment*