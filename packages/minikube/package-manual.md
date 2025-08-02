# Minikube Package Manual

## Package Information
- **Package Name**: minikube
- **Category**: Containers
- **Type**: Local Kubernetes Cluster
- **License**: Apache 2.0

## Description
Local Kubernetes cluster for development and testing on single machine.

Runs a single-node Kubernetes cluster locally for development, testing, and learning purposes.
Essential tool for Kubernetes development workflows and application testing.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| minikube.exe | Local Kubernetes cluster manager | Create and manage local Kubernetes clusters |

## Common Usage Examples

### Cluster Management
```bash
# Start minikube cluster
minikube start

# Start with specific Kubernetes version
minikube start --kubernetes-version=v1.28.0

# Start with specific driver
minikube start --driver=docker
minikube start --driver=virtualbox

# Stop cluster
minikube stop

# Delete cluster
minikube delete
```

### Cluster Configuration
```bash
# Start with custom resources
minikube start --memory=8192 --cpus=4

# Start with specific container runtime
minikube start --container-runtime=docker
minikube start --container-runtime=containerd

# Enable addons during start
minikube start --addons=ingress,dashboard

# Multiple node cluster
minikube start --nodes=3
```

### Cluster Status and Information
```bash
# Check cluster status
minikube status

# Get cluster info
minikube profile list

# View cluster IP
minikube ip

# SSH into cluster
minikube ssh

# Get kubectl context
minikube update-context
```

## Addon Management

### Enable and Disable Addons
```bash
# List available addons
minikube addons list

# Enable specific addons
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable registry

# Disable addons
minikube addons disable dashboard

# Configure addon
minikube addons configure registry
```

### Popular Addons
```bash
# Essential development addons
minikube addons enable dashboard        # Kubernetes dashboard
minikube addons enable ingress         # Ingress controller
minikube addons enable metrics-server  # Resource metrics
minikube addons enable storage-provisioner # Persistent volumes

# Monitoring and logging
minikube addons enable efk            # Elasticsearch, Fluentd, Kibana
minikube addons enable prometheus     # Prometheus monitoring

# Service mesh
minikube addons enable istio          # Istio service mesh
```

## Service Access

### Service Exposure
```bash
# Expose service via NodePort
minikube service my-service

# List services with URLs
minikube service list

# Get service URL
minikube service my-service --url

# Forward port to service
minikube service my-service --url --port=8080
```

### Dashboard Access
```bash
# Open Kubernetes dashboard
minikube dashboard

# Get dashboard URL only
minikube dashboard --url

# Access dashboard remotely
minikube dashboard --port=9090 --host=0.0.0.0
```

### Ingress Testing
```bash
# Enable ingress addon
minikube addons enable ingress

# Get ingress IP
minikube ip

# Test ingress
curl http://$(minikube ip)/api/health
```

## Docker Integration

### Docker Environment
```bash
# Configure shell to use minikube Docker
minikube docker-env
eval $(minikube docker-env)

# Build images directly in minikube
docker build -t my-app .

# Use local images in Kubernetes
kubectl run my-app --image=my-app:latest --image-pull-policy=Never
```

### Registry Operations
```bash
# Enable registry addon
minikube addons enable registry

# Push to minikube registry
docker tag my-app localhost:5000/my-app
docker push localhost:5000/my-app

# Use registry in deployments
kubectl create deployment my-app --image=localhost:5000/my-app
```

## Development Workflows

### Application Development
```bash
# Start development cluster
minikube start --memory=4096 --cpus=2

# Enable development addons
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server

# Configure Docker environment
eval $(minikube docker-env)

# Build and deploy
docker build -t my-app .
kubectl create deployment my-app --image=my-app:latest --image-pull-policy=Never
kubectl expose deployment my-app --port=8080 --type=NodePort

# Access application
minikube service my-app
```

### Testing Workflow
```bash
# Start test cluster
minikube start --profile=testing

# Deploy test application
kubectl apply -f test-deployment.yaml

# Run tests
kubectl apply -f test-job.yaml

# Check results
kubectl logs job/test-job

# Cleanup
minikube delete --profile=testing
```

## Multi-Profile Management

### Profile Operations
```bash
# Create named profile
minikube start --profile=development
minikube start --profile=testing

# List profiles
minikube profile list

# Switch profiles
minikube profile development

# Delete specific profile
minikube delete --profile=testing
```

### Profile Configuration
```bash
# Different profiles for different purposes
minikube start --profile=dev --memory=2048 --cpus=2
minikube start --profile=test --memory=4096 --cpus=4 --nodes=2
minikube start --profile=staging --memory=8192 --cpus=6 --kubernetes-version=v1.27.0
```

## Advanced Configuration

### Custom VM Settings
```bash
# Advanced cluster configuration
minikube start \
  --memory=8192 \
  --cpus=4 \
  --disk-size=50g \
  --driver=virtualbox \
  --kubernetes-version=v1.28.0 \
  --container-runtime=containerd
```

### Networking Configuration
```bash
# Custom networking
minikube start --service-cluster-ip-range=10.96.0.0/12
minikube start --dns-domain=cluster.local

# Host access
minikube start --host-only-cidr=192.168.99.1/24
```

### Storage Configuration
```bash
# Mount host directories
minikube mount /host/path:/minikube/path

# Persistent volume configuration
minikube start --extra-config=kubelet.max-pods=110
```

## Troubleshooting

### Common Issues
```bash
# Check logs
minikube logs

# System information
minikube version
minikube config view

# Reset cluster
minikube delete
minikube start

# Update minikube
minikube update-check
```

### Performance Tuning
```bash
# Optimize for development
minikube start \
  --memory=6144 \
  --cpus=4 \
  --disk-size=40g \
  --cache-images=true

# Enable caching
minikube config set WantUpdateNotification false
minikube config set vm-driver docker
```

### Resource Monitoring
```bash
# Monitor resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Check cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

# Cluster diagnostics
minikube status
kubectl cluster-info
```

## Integration with CI/CD

### GitHub Actions
```yaml
name: Test with Minikube
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Start minikube
      uses: medyagh/setup-minikube@master
    - name: Deploy and test
      run: |
        kubectl apply -f k8s/
        kubectl wait --for=condition=ready pod -l app=myapp
        kubectl port-forward svc/myapp 8080:80 &
        curl http://localhost:8080/health
```

### Local Development Scripts
```bash
#!/bin/bash
# dev-setup.sh
echo "Starting development environment..."
minikube start --profile=dev --memory=4096
minikube addons enable dashboard ingress
eval $(minikube docker-env)
docker build -t myapp .
kubectl apply -f k8s/dev/
echo "Environment ready at $(minikube service myapp --url)"
```

## Kubernetes Learning

### Tutorial Examples
```bash
# Basic deployment
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-minikube --type=NodePort --port=8080
minikube service hello-minikube

# Ingress example
minikube addons enable ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
  - host: hello-world.info
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-minikube
            port:
              number: 8080
EOF
```

### Educational Workflows
```bash
# Explore Kubernetes concepts
kubectl get all --all-namespaces
kubectl describe nodes
kubectl get events
minikube dashboard

# Practice with resources
kubectl apply -f examples/
kubectl get pods -w
kubectl logs -f deployment/myapp
```

## Use Cases

### Local Development
- Application development and testing
- Kubernetes manifest validation
- Local CI/CD pipeline testing
- Multi-service application debugging

### Learning and Training
- Kubernetes concept exploration
- Hands-on practice environment
- Workshop and tutorial platform
- Certification exam preparation

### Testing and QA
- Integration testing environment
- Performance testing setup
- Regression testing platform
- Staging environment simulation

## Installation
Local Kubernetes cluster for development and testing purposes.
Essential tool for Kubernetes application development and learning workflows.

## Dependencies
- Virtualization support (VT-x/AMD-v)
- Docker or VirtualBox (driver dependent)
- kubectl (automatically installed or use existing)
- Sufficient system resources (minimum 2GB RAM)

## Performance Features
- Fast cluster startup and shutdown
- Efficient resource usage
- Built-in load balancer
- Automatic kubectl configuration
- Integrated Docker registry

---
*Part of PORTX Portable Development Environment*