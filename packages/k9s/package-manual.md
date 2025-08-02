# k9s Package Manual

## Package Information
- **Package Name**: k9s
- **Category**: Containers
- **Type**: Kubernetes Dashboard
- **License**: Apache 2.0

## Description
Kubernetes CLI and terminal UI for managing and monitoring clusters.

Interactive terminal-based Kubernetes dashboard providing real-time cluster monitoring, resource management, and debugging capabilities.
Essential tool for Kubernetes operators and developers working with container orchestration.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| k9s.exe | Interactive Kubernetes cluster management | Monitor and manage Kubernetes resources with terminal UI |

## Common Usage Examples

### Basic Cluster Navigation
```bash
# Launch k9s
k9s

# Connect to specific context
k9s --context my-cluster

# Start in specific namespace
k9s -n kube-system

# Read-only mode
k9s --readonly
```

### Resource Views
```bash
# In k9s interface:
# :pods       - View pods
# :deployments - View deployments
# :services   - View services
# :nodes      - View cluster nodes
# :namespaces - View namespaces
```

## Interface Navigation

### Basic Navigation
```bash
# Resource navigation
:pods           # Switch to pods view
:svc            # Switch to services view
:deploy         # Switch to deployments view
:ns             # Switch to namespaces view

# Quick access
0-9             # Switch to numbered views
Tab             # Cycle through sections
?               # Show help
```

### Resource Management
```bash
# Resource actions
Enter           # Describe resource
d               # Delete resource
e               # Edit resource
l               # View logs
s               # Shell into pod
y               # View YAML
Ctrl+d          # Delete resource

# Scaling
Ctrl+a          # Scale up
Ctrl+z          # Scale down
```

### Filtering and Search
```bash
# Filtering
/               # Filter resources
Ctrl+/          # Clear filter
f               # Port forwarding
n               # Change namespace

# Sorting
a               # Sort ascending
z               # Sort descending
```

## Pod Management

### Pod Operations
```bash
# Pod-specific actions
l               # View pod logs
s               # Shell into container
y               # View pod YAML
d               # Delete pod
Enter           # Describe pod

# Container selection (multi-container pods)
c               # Select container for logs/shell
```

### Log Viewing
```bash
# Log commands in k9s
l               # View logs
Ctrl+l          # Toggle log auto-scroll
t               # Toggle timestamp
w               # Toggle log wrap
p               # Previous log lines
f               # Follow logs
```

### Debugging
```bash
# Debug operations
s               # Open shell in pod
Ctrl+k          # Kill pod
r               # Restart pod
Enter           # Describe for troubleshooting
```

## Service and Networking

### Service Management
```bash
# Service operations
:svc            # View services
Enter           # Describe service
e               # Edit service
d               # Delete service
y               # View service YAML
```

### Port Forwarding
```bash
# Port forwarding in k9s
f               # Setup port forwarding
Shift+f         # View active port forwards
Ctrl+f          # Stop port forwarding

# Example: Forward local 8080 to pod 80
# Select pod -> press 'f' -> enter local:remote (8080:80)
```

### Network Policies
```bash
# Network policy management
:netpol         # View network policies
Enter           # Describe policy
y               # View policy YAML
e               # Edit policy
```

## Deployment and Workload Management

### Deployment Operations
```bash
# Deployment management
:deploy         # View deployments
s               # Scale deployment
r               # Restart deployment
Enter           # Describe deployment
y               # View deployment YAML
```

### StatefulSets and DaemonSets
```bash
# StatefulSet management
:sts            # View StatefulSets
s               # Scale StatefulSet
r               # Restart StatefulSet

# DaemonSet management
:ds             # View DaemonSets
r               # Restart DaemonSet
```

### Jobs and CronJobs
```bash
# Job management
:jobs           # View jobs
d               # Delete job
y               # View job YAML

# CronJob management
:cj             # View cronjobs
t               # Trigger job manually
```

## Configuration and Secrets

### ConfigMaps and Secrets
```bash
# ConfigMap management
:cm             # View ConfigMaps
e               # Edit ConfigMap
y               # View ConfigMap YAML
d               # Delete ConfigMap

# Secret management
:secrets        # View secrets
e               # Edit secret
y               # View secret YAML (encoded)
```

### Persistent Volumes
```bash
# Volume management
:pv             # View persistent volumes
:pvc            # View persistent volume claims
Enter           # Describe volume
y               # View volume YAML
```

## Monitoring and Metrics

### Resource Monitoring
```bash
# Node monitoring
:nodes          # View cluster nodes
Enter           # Describe node
t               # Toggle node metrics
Ctrl+t          # Top node consumers

# Resource usage
:top            # Resource usage view
:top pods       # Pod resource usage
:top nodes      # Node resource usage
```

### Events and Logs
```bash
# Cluster events
:events         # View cluster events
f               # Filter events
s               # Sort events by time

# Application logs
l               # View container logs
Ctrl+l          # Toggle auto-scroll
p               # Previous log entries
```

## Advanced Features

### Custom Resource Definitions
```bash
# CRD management
:crd            # View custom resource definitions
Enter           # Describe CRD
:custom-resource # View custom resources
```

### RBAC Management
```bash
# RBAC resources
:rb             # View role bindings
:crb            # View cluster role bindings
:roles          # View roles
:sa             # View service accounts
```

### Cluster Administration
```bash
# Admin operations
:nodes          # Cluster nodes
:ns             # Namespaces
:contexts       # Available contexts
:helm           # Helm releases (if available)
```

## Configuration Customization

### K9s Configuration (~/.k9s/config.yml)
```yaml
k9s:
  refreshRate: 2
  headless: false
  logoless: true
  crumbsless: false
  readOnly: false
  noExitOnCtrlC: false
  ui:
    enableMouse: false
    headless: false
    logoless: false
    crumbsless: false
    reactive: false
    noIcons: false
  skipLatestRevCheck: false
  disablePodCounting: false
  shellPod:
    image: busybox:1.35.0
    namespace: default
    limits:
      cpu: 100m
      memory: 100Mi
```

### Custom Key Bindings
```yaml
# ~/.k9s/hotkey.yml
hotKey:
  shift-0:
    shortCut: Shift-0
    description: Viewing pods
    command: pods
  shift-1:
    shortCut: Shift-1
    description: View deployments
    command: dp
```

### Skin Customization
```yaml
# ~/.k9s/skin.yml
k9s:
  body:
    fgColor: white
    bgColor: black
    logoColor: blue
  prompt:
    fgColor: green
    bgColor: black
  info:
    fgColor: lightyellow
    sectionColor: white
```

## Integration and Automation

### Multi-Cluster Management
```bash
# Switch between clusters
:contexts       # View available contexts
Enter           # Switch to selected context

# Cluster comparison
# Open multiple k9s instances for different clusters
k9s --context cluster1 &
k9s --context cluster2 &
```

### Workflow Integration
```bash
# Use with kubectl
kubectl config get-contexts  # Check available contexts
k9s --context production    # Connect to specific cluster

# Combine with other tools
kubectl get pods | grep Error  # Find problematic pods
k9s -n problematic-namespace  # Debug in k9s
```

## Troubleshooting Workflows

### Application Debugging
```bash
# Debug application issues
1. :pods                    # Find problematic pod
2. Enter                    # Describe pod
3. l                        # View logs
4. s                        # Shell into container
5. :events                  # Check cluster events
```

### Performance Investigation
```bash
# Investigate performance issues
1. :top pods               # Check resource usage
2. :nodes                  # Check node health
3. :events                 # Look for warnings
4. :pv                     # Check storage issues
```

### Network Troubleshooting
```bash
# Network debugging
1. :svc                    # Check services
2. :netpol                 # Review network policies
3. f                       # Test port forwarding
4. s                       # Shell for network tests
```

## Use Cases

### Development and Testing
- Local Kubernetes cluster management
- Application deployment monitoring
- Log analysis and debugging
- Resource usage optimization

### Production Operations
- Cluster health monitoring
- Incident response and troubleshooting
- Resource scaling and management
- Security and compliance checking

### DevOps and SRE
- Multi-cluster management
- Deployment pipeline monitoring
- Performance analysis
- Capacity planning

## Installation
Interactive Kubernetes cluster management tool with terminal-based dashboard.
Essential for Kubernetes operations, monitoring, and troubleshooting workflows.

## Dependencies
- kubectl configured with cluster access
- Valid Kubernetes configuration (~/.kube/config)
- Cluster connectivity and appropriate RBAC permissions
- Terminal with color support for optimal experience

## Performance Features
- Real-time cluster monitoring
- Efficient resource caching
- Responsive terminal interface
- Multi-threaded operations
- Minimal resource overhead

---
*Part of PORTX Portable Development Environment*