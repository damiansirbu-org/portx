# OpenShift Package Manual

## Package Information
- **Package Name**: openshift
- **Category**: Containers
- **Type**: OpenShift CLI
- **License**: Apache 2.0

## Description
OpenShift command-line interface for container platform management and development.

Command-line tool for managing OpenShift clusters, applications, and development workflows.
Provides comprehensive functionality for container orchestration and enterprise Kubernetes operations.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| oc.exe | OpenShift command-line interface | Manage OpenShift clusters and applications |

## Common Usage Examples

### Cluster Authentication
```bash
# Login to OpenShift cluster
oc login https://api.cluster.example.com:6443

# Login with username and password
oc login -u developer -p password https://api.cluster.example.com:6443

# Login with token
oc login --token=sha256~abcd1234... --server=https://api.cluster.example.com:6443

# Switch between contexts
oc config get-contexts
oc config use-context production
```

### Project Management
```bash
# List projects
oc get projects

# Create new project
oc new-project myapp

# Switch to project
oc project myapp

# Delete project
oc delete project oldproject

# Get current project
oc project
```

### Application Deployment
```bash
# Deploy from source code
oc new-app https://github.com/user/myapp.git

# Deploy from Docker image
oc new-app nginx:latest

# Deploy with specific name
oc new-app https://github.com/user/myapp.git --name=webapp

# Deploy with environment variables
oc new-app myapp --env DATABASE_URL=postgresql://...
```

## Resource Management

### Pod Operations
```bash
# List pods
oc get pods

# Describe pod
oc describe pod mypod

# Get pod logs
oc logs mypod

# Follow pod logs
oc logs -f mypod

# Execute commands in pod
oc exec mypod -- ls /app
oc exec -it mypod -- /bin/bash
```

### Service and Route Management
```bash
# List services
oc get services

# Expose service as route
oc expose svc/myapp

# Create route with custom hostname
oc expose svc/myapp --hostname=myapp.example.com

# List routes
oc get routes

# Delete route
oc delete route myapp
```

### Deployment Management
```bash
# List deployments
oc get deployments

# Scale deployment
oc scale deployment myapp --replicas=3

# Rollout new deployment
oc rollout latest myapp

# Check rollout status
oc rollout status deployment/myapp

# Rollback deployment
oc rollout undo deployment/myapp
```

## Build and Image Management

### Build Configurations
```bash
# List build configurations
oc get bc

# Start new build
oc start-build myapp

# Start build from local directory
oc start-build myapp --from-dir=.

# Follow build logs
oc logs -f bc/myapp

# Cancel build
oc cancel-build myapp-1
```

### Image Streams
```bash
# List image streams
oc get is

# Describe image stream
oc describe is myapp

# Tag image
oc tag myapp:latest myapp:v1.0

# Import external image
oc import-image nginx:latest --confirm
```

### S2I (Source-to-Image) Builds
```bash
# Create S2I build
oc new-build nodejs:14~https://github.com/user/nodeapp.git

# List available S2I builders
oc new-build --search

# Create build with custom builder
oc new-build --image-stream=python:3.8 --code=https://github.com/user/pythonapp.git
```

## Configuration Management

### ConfigMaps and Secrets
```bash
# Create ConfigMap from file
oc create configmap myconfig --from-file=config.properties

# Create ConfigMap from literal
oc create configmap myconfig --from-literal=key1=value1

# Create Secret
oc create secret generic mysecret --from-literal=password=secret123

# Mount ConfigMap to deployment
oc set volumes deployment/myapp --add --configmap-name=myconfig --mount-path=/etc/config
```

### Environment Variables
```bash
# Set environment variable
oc set env deployment/myapp DATABASE_URL=postgresql://...

# Remove environment variable
oc set env deployment/myapp DATABASE_URL-

# List environment variables
oc set env deployment/myapp --list
```

### Resource Quotas and Limits
```bash
# View resource quotas
oc get resourcequota

# Set resource limits
oc set resources deployment myapp --limits=cpu=500m,memory=512Mi

# Set resource requests
oc set resources deployment myapp --requests=cpu=100m,memory=128Mi
```

## Storage Management

### Persistent Volumes
```bash
# List persistent volumes
oc get pv

# List persistent volume claims
oc get pvc

# Create PVC
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webapp-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

### Volume Management
```bash
# Add volume to deployment
oc set volumes deployment/myapp --add --type=persistentVolumeClaim --claim-name=webapp-storage --mount-path=/data

# Remove volume
oc set volumes deployment/myapp --remove --name=volume-name

# List volumes
oc set volumes deployment/myapp
```

## Advanced Operations

### Templates
```bash
# List templates
oc get templates -n openshift

# Process template
oc process -f template.yaml -p PARAM1=value1 | oc apply -f -

# Create application from template
oc new-app --template=mysql-persistent --param=MYSQL_USER=user
```

### Operators
```bash
# List operators
oc get operators

# List operator subscriptions
oc get subscriptions

# Install operator
oc apply -f operator-subscription.yaml

# List custom resources
oc get crd
```

### Jobs and CronJobs
```bash
# Create job
oc create job myjob --image=busybox -- /bin/sh -c "echo hello"

# Create cronjob
oc create cronjob mycron --image=busybox --schedule="*/5 * * * *" -- /bin/sh -c "date"

# List jobs
oc get jobs

# List cronjobs
oc get cronjobs
```

## Monitoring and Debugging

### Resource Monitoring
```bash
# Get resource usage
oc adm top nodes
oc adm top pods

# View cluster events
oc get events --sort-by=.metadata.creationTimestamp

# Monitor resource status
oc get pods -w
```

### Troubleshooting
```bash
# Debug pod issues
oc describe pod problematic-pod
oc logs problematic-pod --previous

# Debug service connectivity
oc get endpoints
oc describe service myservice

# Check resource limits
oc describe limitrange
oc describe resourcequota
```

### Cluster Administration
```bash
# View cluster nodes
oc get nodes

# View cluster operators
oc get clusteroperators

# Check cluster version
oc get clusterversion

# View machine configs
oc get machineconfigs
```

## Development Workflows

### Local Development
```bash
# Create development project
oc new-project dev-myapp

# Deploy from local source
oc new-build --binary --name=myapp --image-stream=nodejs:14
oc start-build myapp --from-dir=. --follow

# Create application
oc new-app myapp
oc expose svc/myapp
```

### CI/CD Integration
```bash
# Webhook triggers
oc set triggers bc/myapp --from-github
oc describe bc/myapp

# Manual deployment
oc tag myapp:latest myapp:production
oc import-image myapp:production
```

### Multi-Environment Management
```bash
# Promote between environments
oc tag dev/myapp:latest staging/myapp:latest
oc tag staging/myapp:latest production/myapp:latest

# Environment-specific configurations
oc process -f template.yaml -p ENV=production | oc apply -f -
```

## Security and RBAC

### Service Accounts
```bash
# Create service account
oc create serviceaccount myapp-sa

# Add policy to service account
oc policy add-role-to-user view system:serviceaccount:myproject:myapp-sa

# Use service account in deployment
oc patch deployment myapp -p '{"spec":{"template":{"spec":{"serviceAccount":"myapp-sa"}}}}'
```

### Security Context Constraints
```bash
# List SCCs
oc get scc

# Add SCC to service account
oc adm policy add-scc-to-user anyuid system:serviceaccount:myproject:myapp-sa

# View SCC details
oc describe scc restricted
```

### Network Policies
```bash
# Create network policy
oc apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```

## Administration Commands

### User Management
```bash
# List users
oc get users

# Create user
oc create user newuser

# Add cluster role to user
oc adm policy add-cluster-role-to-user cluster-admin admin-user

# Remove user
oc delete user olduser
```

### Project Administration
```bash
# Create project for user
oc adm new-project myproject --admin=developer

# Add user to project
oc policy add-role-to-user edit developer

# Remove user from project
oc policy remove-role-from-user edit developer
```

### Backup and Restore
```bash
# Export project resources
oc get all --export -o yaml > project-backup.yaml

# Export specific resources
oc get deployments --export -o yaml > deployments-backup.yaml

# Apply backup
oc apply -f project-backup.yaml
```

## Use Cases

### Application Development
- Container application deployment
- Source-to-image builds
- Development environment management
- Continuous integration workflows

### Enterprise Operations
- Multi-tenant cluster management
- Security policy enforcement
- Resource quota management
- Compliance and governance

### DevOps Automation
- CI/CD pipeline integration
- Infrastructure as code
- Automated deployments
- Environment promotion

### Microservices Management
- Service mesh integration
- Inter-service communication
- Distributed application deployment
- API gateway management

## Installation
OpenShift command-line interface for container platform management.
Essential tool for OpenShift development and operations workflows.

## Dependencies
- Access to OpenShift cluster
- Valid authentication credentials
- Network connectivity to cluster API
- Compatible with OpenShift 4.x clusters

## Performance Features
- Efficient cluster communication
- Optimized resource operations
- Batch command execution
- Streaming log support
- Concurrent operation handling

---
*Part of PORTX Portable Development Environment*