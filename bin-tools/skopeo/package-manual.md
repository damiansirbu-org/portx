# Skopeo Package Manual

## Package Information
- **Package Name**: skopeo
- **Category**: Containers
- **Type**: Container Image Utility
- **License**: Apache 2.0

## Description
Command-line utility for container image operations without requiring a container runtime.

Skopeo enables inspection, copying, deletion, and signing of container images across different storage mechanisms and registries.
Provides direct image manipulation capabilities for CI/CD pipelines, image management, and registry operations without Docker daemon dependency.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| skopeo.exe | Container image utility | Inspect, copy, and manage container images |
| gpgme-w32spawn.exe | GPG signing helper | Digital signature operations for images |

## Supported Image Formats and Transports

### Container Registries
- **docker://** - Docker Registry (Docker Hub, ECR, GCR, ACR)
- **docker-archive://** - Docker archive tar files
- **docker-daemon://** - Docker daemon storage
- **oci://** - OCI image layout directories
- **oci-archive://** - OCI archive tar files

### Local Storage
- **dir://** - Local directory with OCI layout
- **containers-storage://** - Container storage (Podman/Buildah)
- **ostree://** - OSTree repository storage

### Special Transports
- **atomic://** - Atomic registry
- **tarball://** - Raw tar archive files

## Common Usage Examples

### Image Inspection
```bash
# Inspect image metadata
skopeo inspect docker://docker.io/nginx:latest

# Inspect with authentication
skopeo inspect --creds username:password docker://registry.company.com/app:v1.0

# Inspect local image
skopeo inspect docker-daemon:ubuntu:20.04

# Get image configuration
skopeo inspect --config docker://alpine:latest

# Show image layers
skopeo inspect --raw docker://redis:alpine | jq '.layers'
```

### Image Copying and Migration
```bash
# Copy image between registries
skopeo copy docker://docker.io/nginx:latest docker://registry.company.com/nginx:latest

# Copy with different tag
skopeo copy docker://alpine:3.18 docker://registry.local/alpine:production

# Copy to local directory
skopeo copy docker://ubuntu:22.04 dir:/tmp/ubuntu-image

# Copy from archive
skopeo copy docker-archive:image.tar docker://registry.company.com/app:v2.0

# Copy with compression
skopeo copy --compress docker://large-image:latest docker://registry.company.com/large-image:compressed
```

### Authentication and Credentials
```bash
# Login to registry
skopeo login registry.company.com

# Login with specific credentials
skopeo login --username myuser --password mypass registry.company.com

# Copy with inline credentials
skopeo copy --src-creds user1:pass1 --dest-creds user2:pass2 \
  docker://registry1.com/image:tag docker://registry2.com/image:tag

# Use credential helpers
skopeo copy --authfile /path/to/auth.json \
  docker://source/image:tag docker://dest/image:tag

# Logout from registry
skopeo logout registry.company.com
```

## Advanced Operations

### Image Signing and Verification
```bash
# Sign image during copy
skopeo copy --sign-by key@company.com \
  docker://unsigned-image:latest docker://signed-image:latest

# Copy with signature verification
skopeo copy --policy /path/to/policy.json \
  docker://signed-image:latest docker://verified-image:latest

# Inspect image signatures
skopeo inspect --show-signature docker://signed-image:latest
```

### Multi-Architecture Support
```bash
# Inspect multi-arch manifest
skopeo inspect --raw docker://golang:latest

# Copy specific architecture
skopeo copy --override-arch amd64 \
  docker://multiarch/qemu-user-static:latest docker://registry.local/qemu:amd64

# Copy all architectures
skopeo copy --all docker://multiarch-image:latest docker://registry.company.com/multiarch-image:latest

# List available architectures
skopeo inspect docker://node:latest | jq '.RepoTags, .Architecture'
```

### Registry Management
```bash
# List repository tags
skopeo list-tags docker://docker.io/library/python

# Delete image from registry
skopeo delete docker://registry.company.com/old-image:v1.0

# Sync images between registries
skopeo sync --src docker --dest docker \
  registry1.com/namespace registry2.com/namespace

# Copy image with retries
skopeo copy --retry-times 3 \
  docker://unstable-registry.com/image:latest docker://stable-registry.com/image:latest
```

## Batch Operations and Automation

### Image Migration Script
```bash
#!/bin/bash
# Bulk image migration between registries

SOURCE_REGISTRY="old-registry.company.com"
DEST_REGISTRY="new-registry.company.com"
NAMESPACE="production"
IMAGES_FILE="images_to_migrate.txt"

# Authentication
echo "Authenticating to registries..."
skopeo login $SOURCE_REGISTRY
skopeo login $DEST_REGISTRY

echo "Starting image migration..."

while IFS= read -r image_tag; do
    echo "Migrating: $image_tag"
    
    source_image="docker://${SOURCE_REGISTRY}/${NAMESPACE}/${image_tag}"
    dest_image="docker://${DEST_REGISTRY}/${NAMESPACE}/${image_tag}"
    
    # Copy with verification
    if skopeo copy --retry-times 3 "$source_image" "$dest_image"; then
        echo "✓ Successfully migrated: $image_tag"
        
        # Verify migration
        source_digest=$(skopeo inspect "$source_image" | jq -r '.Digest')
        dest_digest=$(skopeo inspect "$dest_image" | jq -r '.Digest')
        
        if [ "$source_digest" = "$dest_digest" ]; then
            echo "✓ Verification passed: $image_tag"
        else
            echo "✗ Verification failed: $image_tag"
        fi
    else
        echo "✗ Failed to migrate: $image_tag"
    fi
    
    sleep 1
done < "$IMAGES_FILE"

echo "Migration complete."
```

### Registry Synchronization
```bash
#!/bin/bash
# Synchronize images between development and production registries

DEV_REGISTRY="dev-registry.company.com"
PROD_REGISTRY="prod-registry.company.com"
NAMESPACE="applications"
SYNC_LOG="sync_$(date +%Y%m%d_%H%M%S).log"

function sync_repository() {
    local repo_name=$1
    local tag_filter=${2:-"latest"}
    
    echo "Syncing repository: $repo_name" | tee -a $SYNC_LOG
    
    # Get list of tags
    tags=$(skopeo list-tags docker://${DEV_REGISTRY}/${NAMESPACE}/${repo_name} | jq -r '.Tags[]' | grep "$tag_filter")
    
    for tag in $tags; do
        echo "Syncing tag: $repo_name:$tag" | tee -a $SYNC_LOG
        
        dev_image="docker://${DEV_REGISTRY}/${NAMESPACE}/${repo_name}:${tag}"
        prod_image="docker://${PROD_REGISTRY}/${NAMESPACE}/${repo_name}:${tag}"
        
        # Check if image already exists in production
        if skopeo inspect "$prod_image" &>/dev/null; then
            dev_digest=$(skopeo inspect "$dev_image" | jq -r '.Digest')
            prod_digest=$(skopeo inspect "$prod_image" | jq -r '.Digest')
            
            if [ "$dev_digest" = "$prod_digest" ]; then
                echo "  ↷ Already in sync: $repo_name:$tag" | tee -a $SYNC_LOG
                continue
            fi
        fi
        
        # Copy image
        if skopeo copy "$dev_image" "$prod_image"; then
            echo "  ✓ Synced: $repo_name:$tag" | tee -a $SYNC_LOG
        else
            echo "  ✗ Failed: $repo_name:$tag" | tee -a $SYNC_LOG
        fi
    done
}

# List of repositories to sync
REPOSITORIES=(
    "web-frontend"
    "api-backend"
    "worker-service"
    "database-migration"
)

echo "Starting registry synchronization..." | tee $SYNC_LOG

for repo in "${REPOSITORIES[@]}"; do
    sync_repository "$repo" "v[0-9]+"
done

echo "Synchronization complete. Log: $SYNC_LOG" | tee -a $SYNC_LOG
```

### Image Security Scanning Integration
```bash
#!/bin/bash
# Security scanning workflow with Skopeo

IMAGE_REF=$1
SCAN_RESULTS_DIR="/tmp/security_scans"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $SCAN_RESULTS_DIR

echo "Security scanning for image: $IMAGE_REF"

# Extract image to temporary directory for scanning
TEMP_DIR="/tmp/image_scan_$TIMESTAMP"
mkdir -p $TEMP_DIR

echo "Extracting image for analysis..."
skopeo copy "$IMAGE_REF" dir:$TEMP_DIR

# Inspect image metadata
echo "Analyzing image metadata..."
skopeo inspect "$IMAGE_REF" > "$SCAN_RESULTS_DIR/metadata_$TIMESTAMP.json"

# Extract configuration
CONFIG_DIGEST=$(jq -r '.config.digest' "$TEMP_DIR/manifest.json")
CONFIG_FILE="$TEMP_DIR/blobs/sha256/${CONFIG_DIGEST#sha256:}"

if [ -f "$CONFIG_FILE" ]; then
    echo "Extracting image configuration..."
    jq '.' "$CONFIG_FILE" > "$SCAN_RESULTS_DIR/config_$TIMESTAMP.json"
    
    # Check for security issues in configuration
    echo "Checking for security misconfigurations..."
    
    # Check for root user
    if jq -e '.config.User == "" or .config.User == "root" or .config.User == "0"' "$CONFIG_FILE" > /dev/null; then
        echo "WARNING: Image runs as root user" | tee -a "$SCAN_RESULTS_DIR/security_issues_$TIMESTAMP.txt"
    fi
    
    # Check for exposed ports
    exposed_ports=$(jq -r '.config.ExposedPorts // {} | keys[]' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$exposed_ports" ]; then
        echo "INFO: Exposed ports found: $exposed_ports" | tee -a "$SCAN_RESULTS_DIR/security_issues_$TIMESTAMP.txt"
    fi
    
    # Check environment variables for secrets
    secrets_found=$(jq -r '.config.Env[]? // empty' "$CONFIG_FILE" | grep -iE "(password|secret|key|token)" || true)
    if [ -n "$secrets_found" ]; then
        echo "WARNING: Potential secrets in environment variables" | tee -a "$SCAN_RESULTS_DIR/security_issues_$TIMESTAMP.txt"
        echo "$secrets_found" | tee -a "$SCAN_RESULTS_DIR/security_issues_$TIMESTAMP.txt"
    fi
fi

# Cleanup
rm -rf $TEMP_DIR

echo "Security scan complete. Results in: $SCAN_RESULTS_DIR/"
```

## CI/CD Integration Examples

### GitLab CI Pipeline
```yaml
# .gitlab-ci.yml - Container image promotion pipeline
stages:
  - build
  - test
  - security
  - promote

variables:
  DEV_REGISTRY: "dev-registry.company.com"
  PROD_REGISTRY: "prod-registry.company.com"
  IMAGE_NAME: "myapp"

image_security_scan:
  stage: security
  image: quay.io/skopeo/stable:latest
  script:
    - skopeo inspect docker://${DEV_REGISTRY}/${IMAGE_NAME}:${CI_COMMIT_SHA}
    - skopeo copy docker://${DEV_REGISTRY}/${IMAGE_NAME}:${CI_COMMIT_SHA} dir:/tmp/scan-image
    # Add security scanning tools here
  artifacts:
    reports:
      junit: security-scan-results.xml

promote_to_production:
  stage: promote
  image: quay.io/skopeo/stable:latest
  script:
    - skopeo login ${DEV_REGISTRY}
    - skopeo login ${PROD_REGISTRY}
    - skopeo copy docker://${DEV_REGISTRY}/${IMAGE_NAME}:${CI_COMMIT_SHA} 
                   docker://${PROD_REGISTRY}/${IMAGE_NAME}:${CI_COMMIT_TAG}
    - skopeo copy docker://${PROD_REGISTRY}/${IMAGE_NAME}:${CI_COMMIT_TAG}
                   docker://${PROD_REGISTRY}/${IMAGE_NAME}:latest
  only:
    - tags
  when: manual
```

### GitHub Actions Workflow
```yaml
# .github/workflows/image-promotion.yml
name: Container Image Promotion

on:
  release:
    types: [published]

jobs:
  promote-image:
    runs-on: ubuntu-latest
    steps:
    - name: Install Skopeo
      run: |
        sudo apt-get update
        sudo apt-get install -y skopeo

    - name: Login to Development Registry
      run: |
        echo "${{ secrets.DEV_REGISTRY_PASSWORD }}" | skopeo login --username "${{ secrets.DEV_REGISTRY_USERNAME }}" --password-stdin dev-registry.company.com

    - name: Login to Production Registry
      run: |
        echo "${{ secrets.PROD_REGISTRY_PASSWORD }}" | skopeo login --username "${{ secrets.PROD_REGISTRY_USERNAME }}" --password-stdin prod-registry.company.com

    - name: Promote Image
      run: |
        skopeo copy docker://dev-registry.company.com/myapp:${{ github.sha }} \
                    docker://prod-registry.company.com/myapp:${{ github.event.release.tag_name }}
        
        skopeo copy docker://prod-registry.company.com/myapp:${{ github.event.release.tag_name }} \
                    docker://prod-registry.company.com/myapp:latest

    - name: Verify Promotion
      run: |
        skopeo inspect docker://prod-registry.company.com/myapp:${{ github.event.release.tag_name }}
        skopeo inspect docker://prod-registry.company.com/myapp:latest
```

### Jenkins Pipeline
```groovy
// Jenkinsfile for container image operations
pipeline {
    agent any
    
    environment {
        DEV_REGISTRY = 'dev-registry.company.com'
        PROD_REGISTRY = 'prod-registry.company.com'
        IMAGE_NAME = 'myapp'
    }
    
    stages {
        stage('Image Security Scan') {
            steps {
                script {
                    def imageRef = "${DEV_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    
                    sh """
                        skopeo inspect ${imageRef}
                        skopeo copy ${imageRef} dir:/tmp/security-scan/
                    """
                    
                    // Run security scanning tools here
                }
            }
        }
        
        stage('Promote to Staging') {
            steps {
                script {
                    sh """
                        skopeo copy docker://${DEV_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} \\
                                    docker://${DEV_REGISTRY}/${IMAGE_NAME}:staging
                    """
                }
            }
        }
        
        stage('Promote to Production') {
            when {
                tag "v*"
            }
            steps {
                script {
                    sh """
                        skopeo copy docker://${DEV_REGISTRY}/${IMAGE_NAME}:${TAG_NAME} \\
                                    docker://${PROD_REGISTRY}/${IMAGE_NAME}:${TAG_NAME}
                        
                        skopeo copy docker://${PROD_REGISTRY}/${IMAGE_NAME}:${TAG_NAME} \\
                                    docker://${PROD_REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'skopeo logout ${DEV_REGISTRY} || true'
            sh 'skopeo logout ${PROD_REGISTRY} || true'
        }
    }
}
```

## Configuration and Policy Management

### Registry Policies Configuration
```json
{
  "default": [
    {
      "type": "insecureAcceptAnything"
    }
  ],
  "transports": {
    "docker": {
      "registry.company.com": [
        {
          "type": "signedBy",
          "keyType": "GPGKeys",
          "keyPath": "/etc/pki/containers/company-key.gpg"
        }
      ],
      "docker.io": [
        {
          "type": "signedBy",
          "keyType": "GPGKeys",
          "keyPath": "/etc/pki/containers/docker-official.gpg"
        }
      ]
    }
  }
}
```

### Authentication Configuration
```json
{
  "auths": {
    "registry.company.com": {
      "auth": "dXNlcm5hbWU6cGFzc3dvcmQ="
    },
    "dev-registry.company.com": {
      "auth": "ZGV2dXNlcjpkZXZwYXNz"
    }
  },
  "credHelpers": {
    "gcr.io": "gcr",
    "123456789012.dkr.ecr.us-west-2.amazonaws.com": "ecr-login"
  }
}
```

## Performance Optimization and Troubleshooting

### Performance Tuning
```bash
# Parallel copying for better performance
skopeo copy --parallel 4 docker://large-image:latest docker://registry.company.com/large-image:latest

# Compression optimization
skopeo copy --compress-format gzip --compress-level 6 \
  docker://source-image:latest docker://dest-image:latest

# Retry configuration for unreliable networks
skopeo copy --retry-times 5 --retry-delay 10s \
  docker://unstable-registry.com/image:latest docker://stable-registry.com/image:latest
```

### Debugging and Troubleshooting
```bash
# Verbose output for debugging
skopeo --debug copy docker://source:latest docker://dest:latest

# Check registry connectivity
skopeo inspect --tls-verify=false docker://registry.company.com/test:latest

# Test authentication
skopeo inspect --creds username:password docker://private-registry.com/image:latest

# Bypass TLS verification (for testing only)
skopeo copy --src-tls-verify=false --dest-tls-verify=false \
  docker://insecure-registry.com/image:latest docker://secure-registry.com/image:latest
```

## Use Cases

### Container Registry Management
- Image migration between different registry platforms
- Multi-cloud image distribution and synchronization
- Registry consolidation and decommissioning
- Backup and disaster recovery for container images

### CI/CD Pipeline Operations
- Image promotion across development environments
- Security scanning and vulnerability assessment
- Automated image signing and verification
- Container image lifecycle management

### DevOps and Infrastructure
- Airgapped environment image management
- Bandwidth-efficient image distribution
- Registry maintenance and cleanup operations
- Container image compliance and governance

### Security and Compliance
- Image signature verification and trust policies
- Container image vulnerability scanning
- Secure image distribution and access control
- Audit trail and compliance reporting

## Installation
Container image utility for registry operations without Docker daemon dependency.
Essential tool for CI/CD pipelines, registry management, and container operations.

## Dependencies
- Network connectivity to container registries
- Authentication credentials for private registries
- GPG keys for image signing operations (optional)
- Sufficient disk space for temporary image storage

## Security Considerations
- Secure credential storage and management
- TLS certificate verification for registry connections
- Image signature verification for trusted content
- Network security for registry communications

---
*Part of PORTX Portable Development Environment*