# Helmfile Package Manual

## Package Information
- **Package Name**: helmfile
- **Category**: Containers
- **Type**: Helm Charts Orchestrator
- **License**: MIT

## Description
Deploy and manage Helm charts with declarative configuration files.

Declarative configuration management for Helm charts with templating, environment management, and deployment orchestration.
Essential for managing complex Kubernetes applications across multiple environments.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| helmfile.exe | Helm charts deployment orchestrator | Manage multiple Helm releases declaratively |

## Common Usage Examples

### Basic Helmfile Operations
```bash
# Deploy all charts
helmfile apply

# Show what would be deployed
helmfile diff

# Sync releases (apply with force)
helmfile sync

# Destroy all releases
helmfile destroy
```

### Environment Management
```bash
# Deploy to specific environment
helmfile -e production apply

# List available environments
helmfile list

# Deploy to multiple environments
helmfile -e staging,production apply

# Template with environment values
helmfile -e dev template
```

### Release Management
```bash
# Deploy specific release
helmfile -l name=redis apply

# Deploy releases with specific labels
helmfile -l tier=backend apply

# Skip specific releases
helmfile apply --skip-deps

# Force update releases
helmfile apply --force
```

## Helmfile Configuration

### Basic helmfile.yaml
```yaml
releases:
- name: redis
  namespace: default
  chart: bitnami/redis
  version: 17.3.7
  values:
  - auth:
      enabled: false
  - persistence:
      enabled: true
      size: 8Gi

- name: postgres
  namespace: default
  chart: bitnami/postgresql
  version: 11.9.13
  values:
  - auth:
      postgresPassword: "secretpassword"
  - persistence:
      size: 20Gi
```

### Advanced Configuration
```yaml
repositories:
- name: bitnami
  url: https://charts.bitnami.com/bitnami
- name: prometheus-community
  url: https://prometheus-community.github.io/helm-charts

environments:
  default:
    values:
    - environments/default/values.yaml
  staging:
    values:
    - environments/staging/values.yaml
  production:
    values:
    - environments/production/values.yaml

releases:
- name: app
  namespace: '{{ .Environment.Name }}'
  chart: ./charts/myapp
  values:
  - values/{{ .Environment.Name }}.yaml
  - image:
      tag: '{{ env "IMAGE_TAG" | default "latest" }}'
  
- name: monitoring
  namespace: monitoring
  chart: prometheus-community/kube-prometheus-stack
  condition: monitoring.enabled
  values:
  - monitoring/values.yaml
```

### Templating with Go Templates
```yaml
releases:
- name: '{{ .Environment.Name }}-redis'
  namespace: '{{ .Environment.Name }}'
  chart: bitnami/redis
  values:
  - replicaCount: '{{ env "REDIS_REPLICAS" | default "1" }}'
  - resources:
      requests:
        memory: '{{ env "REDIS_MEMORY" | default "256Mi" }}'

- name: app-{{ .Environment.Name }}
  namespace: '{{ .Environment.Name }}'
  chart: ./charts/app
  values:
  - image:
      repository: '{{ requiredEnv "IMAGE_REPOSITORY" }}'
      tag: '{{ requiredEnv "IMAGE_TAG" }}'
  - ingress:
      hosts:
      - host: '{{ .Environment.Name }}.example.com'
```

## Environment-Specific Configurations

### Directory Structure
```
helmfile.yaml
environments/
  default/
    values.yaml
  staging/
    values.yaml
  production/
    values.yaml
charts/
  myapp/
    Chart.yaml
    values.yaml
    templates/
values/
  default.yaml
  staging.yaml
  production.yaml
```

### Environment Values
```yaml
# environments/production/values.yaml
environment: production
domain: prod.example.com
replicas:
  app: 3
  redis: 2
resources:
  app:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
```

### Conditional Deployments
```yaml
releases:
- name: redis
  chart: bitnami/redis
  condition: redis.enabled

- name: monitoring
  chart: prometheus-community/kube-prometheus-stack
  condition: '{{ eq .Environment.Name "production" }}'

- name: debug-tools
  chart: ./charts/debug
  condition: '{{ ne .Environment.Name "production" }}'
```

## Advanced Features

### Hooks and Lifecycle
```yaml
releases:
- name: database-migrations
  chart: ./charts/migrations
  hooks:
  - events: ["preapply"]
    command: "kubectl"
    args: ["apply", "-f", "migrations/"]
  - events: ["postapply"]
    command: "echo"
    args: ["Migration completed"]

- name: app
  chart: ./charts/app
  needs:
  - database-migrations
```

### Secrets Management
```yaml
releases:
- name: app
  chart: ./charts/app
  values:
  - secrets:
      database:
        password: '{{ exec "kubectl" (list "get" "secret" "db-secret" "-o" "jsonpath={.data.password}") | b64dec }}'
  - configFromSecret:
      name: app-config
      key: config.yaml
```

### Multi-Cluster Deployment
```yaml
environments:
  staging:
    kubeContext: staging-cluster
    values:
    - staging.yaml
  production:
    kubeContext: production-cluster
    values:
    - production.yaml

releases:
- name: app
  namespace: '{{ .Environment.Name }}'
  chart: ./charts/app
  kubeContext: '{{ .Environment.Values.kubeContext }}'
```

## Complex Deployment Scenarios

### Blue-Green Deployments
```yaml
environments:
  blue:
    values:
    - color: blue
    - weight: 100
  green:
    values:
    - color: green
    - weight: 0

releases:
- name: 'app-{{ .Environment.Values.color }}'
  chart: ./charts/app
  values:
  - image:
      tag: '{{ env "IMAGE_TAG" }}'
  - service:
      weight: '{{ .Environment.Values.weight }}'
```

### Canary Deployments
```yaml
releases:
- name: app-stable
  chart: ./charts/app
  values:
  - image:
      tag: '{{ env "STABLE_TAG" }}'
  - replicaCount: 3
  - canary:
      enabled: false

- name: app-canary
  chart: ./charts/app
  condition: '{{ env "ENABLE_CANARY" | default "false" }}'
  values:
  - image:
      tag: '{{ env "CANARY_TAG" }}'
  - replicaCount: 1
  - canary:
      enabled: true
      weight: 10
```

### Dependency Management
```yaml
releases:
- name: postgres
  chart: bitnami/postgresql
  values:
  - auth:
      database: myapp

- name: redis
  chart: bitnami/redis

- name: app
  chart: ./charts/app
  needs:
  - postgres
  - redis
  values:
  - dependencies:
      postgres:
        host: postgres-postgresql
      redis:
        host: redis-master
```

## CI/CD Integration

### GitLab CI
```yaml
deploy:
  stage: deploy
  script:
    - helmfile -e $ENVIRONMENT diff
    - helmfile -e $ENVIRONMENT apply
  only:
    - main
  environment:
    name: $ENVIRONMENT
```

### GitHub Actions
```yaml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Deploy with Helmfile
      run: |
        helmfile -e production diff
        helmfile -e production apply
```

### Jenkins Pipeline
```groovy
pipeline {
  stages {
    stage('Deploy') {
      steps {
        sh 'helmfile -e ${ENVIRONMENT} diff'
        sh 'helmfile -e ${ENVIRONMENT} apply'
      }
    }
  }
}
```

## Monitoring and Validation

### Deployment Validation
```bash
# Validate configuration
helmfile lint

# Check what will be deployed
helmfile -e production diff

# Test deployment
helmfile -e staging test

# Rollback if needed
helmfile -e production delete
```

### Status Monitoring
```bash
# Check release status
helmfile status

# List all releases
helmfile list

# Show release history
helmfile history

# Get release values
helmfile get values redis
```

## Use Cases

### Multi-Environment Management
- Consistent deployments across dev/staging/production
- Environment-specific configurations
- Progressive deployment strategies
- Configuration drift prevention

### Complex Application Orchestration
- Multi-chart application stacks
- Service dependency management
- Microservices coordination
- Infrastructure and application coupling

### GitOps Workflows
- Declarative infrastructure management
- Version-controlled deployments
- Automated deployment pipelines
- Rollback and recovery procedures

## Installation
Declarative Helm chart orchestration tool for complex Kubernetes deployments.
Enables consistent multi-environment deployments with advanced templating and lifecycle management.

## Dependencies
- Helm 3.x installed and configured
- kubectl configured with cluster access
- Kubernetes cluster with appropriate permissions
- Chart repositories configured

## Best Practices
- Use environment-specific value files
- Implement proper secret management
- Define clear dependency relationships
- Validate configurations before deployment
- Monitor deployment status and health

---
*Part of PORTX Portable Development Environment*