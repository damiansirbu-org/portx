# Helm Package Manual

## Package Information
- **Package Name**: helm
- **Category**: Containers
- **Type**: Kubernetes Package Manager
- **License**: Apache 2.0

## Description
Kubernetes package manager for deploying and managing applications.

Helm helps you manage Kubernetes applications through charts, which are pre-configured Kubernetes resources.
Essential for deploying, upgrading, and managing complex applications in Kubernetes clusters.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| helm.exe | Kubernetes package manager | Deploy and manage Kubernetes applications |

## Common Usage Examples

### Chart Management
```bash
# Search for charts
helm search repo prometheus

# Install chart
helm install my-release stable/nginx

# Upgrade release
helm upgrade my-release stable/nginx

# Uninstall release
helm uninstall my-release
```

### Repository Management
```bash
# Add chart repository
helm repo add stable https://charts.helm.sh/stable

# Update repositories
helm repo update

# List repositories
helm repo list

# Search repositories
helm search repo nginx
```

### Release Management
```bash
# List releases
helm list

# Get release status
helm status my-release

# Get release history
helm history my-release

# Rollback release
helm rollback my-release 1
```

### Chart Development
```bash
# Create new chart
helm create mychart

# Validate chart
helm lint mychart

# Package chart
helm package mychart

# Install local chart
helm install my-release ./mychart
```

## Installation
Kubernetes package manager for application deployment and lifecycle management.

## Dependencies
- Kubernetes cluster access
- kubectl configured
- Chart repositories configured

---
*Part of PORTX Portable Development Environment*