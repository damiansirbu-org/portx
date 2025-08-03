# YQ Package Manual

## Package Information
- **Package Name**: yq
- **Category**: Text Processing
- **Type**: YAML/JSON Processor
- **License**: MIT

## Description
Lightweight and portable command-line YAML and JSON processor.

YQ provides powerful querying, filtering, and manipulation capabilities for YAML and JSON documents using jq-like syntax.
Features include format conversion, deep merging, path-based updates, and comprehensive data transformation operations.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| yq.exe | YAML/JSON processor | Query, filter, and manipulate structured data |

## Basic Usage Examples

### Reading and Displaying Data
```bash
# Display entire YAML file
yq '.' config.yaml

# Pretty print JSON
yq '.' data.json

# Convert YAML to JSON
yq -o json '.' config.yaml

# Convert JSON to YAML
yq -o yaml '.' data.json

# Read from stdin
cat config.yaml | yq '.database.host'
```

### Basic Queries and Filtering
```bash
# Get specific field
yq '.database.host' config.yaml

# Get array element
yq '.servers[0]' config.yaml

# Get all items in array
yq '.servers[]' config.yaml

# Get array length
yq '.servers | length' config.yaml

# Check if key exists
yq 'has("database")' config.yaml
```

### Path Navigation
```bash
# Nested field access
yq '.app.database.credentials.username' config.yaml

# Array index access
yq '.environments[2].name' deployment.yaml

# Dynamic key access
yq '.["complex-key-name"]' config.yaml

# Multiple path queries
yq '.database.host, .database.port' config.yaml

# Recursive descent
yq '.. | select(. == "production")' config.yaml
```

## Data Manipulation and Updates

### Modifying Values
```bash
# Update single value
yq '.database.host = "new-host.com"' -i config.yaml

# Update multiple values
yq '.database.host = "new-host" | .database.port = 3306' -i config.yaml

# Add new field
yq '.new_field = "new_value"' -i config.yaml

# Delete field
yq 'del(.old_field)' -i config.yaml

# Update array element
yq '.servers[0].name = "web-server-1"' -i config.yaml
```

### Array Operations
```bash
# Add item to array
yq '.servers += ["new-server"]' -i config.yaml

# Add object to array
yq '.servers += [{"name": "web-3", "ip": "192.168.1.3"}]' -i config.yaml

# Remove array element by index
yq 'del(.servers[1])' -i config.yaml

# Remove array element by value
yq '.servers |= map(select(.name != "old-server"))' -i config.yaml

# Sort array by field
yq '.servers |= sort_by(.name)' -i config.yaml
```

### Complex Transformations
```bash
# Map over array
yq '.servers |= map(.ip = "192.168.1." + (.id | tostring))' -i config.yaml

# Filter array
yq '.servers |= map(select(.status == "active"))' -i config.yaml

# Group by field
yq '.servers | group_by(.environment)' config.yaml

# Merge objects
yq '. *= {"new_config": {"enabled": true}}' -i config.yaml

# Conditional updates
yq '(.servers[] | select(.name == "web-1")).status = "maintenance"' -i config.yaml
```

## Configuration Management

### Environment-Specific Configurations
```bash
#!/bin/bash
# Manage environment-specific configurations

BASE_CONFIG="config.base.yaml"
ENV=$1  # development, staging, production
OUTPUT_CONFIG="config.${ENV}.yaml"

echo "Generating configuration for environment: $ENV"

# Start with base configuration
cp "$BASE_CONFIG" "$OUTPUT_CONFIG"

case $ENV in
    "development")
        yq '.database.host = "localhost"' -i "$OUTPUT_CONFIG"
        yq '.database.port = 5432' -i "$OUTPUT_CONFIG"
        yq '.debug = true' -i "$OUTPUT_CONFIG"
        yq '.log_level = "DEBUG"' -i "$OUTPUT_CONFIG"
        ;;
    "staging")
        yq '.database.host = "staging-db.company.com"' -i "$OUTPUT_CONFIG"
        yq '.database.port = 5432' -i "$OUTPUT_CONFIG"
        yq '.debug = false' -i "$OUTPUT_CONFIG"
        yq '.log_level = "INFO"' -i "$OUTPUT_CONFIG"
        ;;
    "production")
        yq '.database.host = "prod-db.company.com"' -i "$OUTPUT_CONFIG"
        yq '.database.port = 5432' -i "$OUTPUT_CONFIG"
        yq '.debug = false' -i "$OUTPUT_CONFIG"
        yq '.log_level = "WARN"' -i "$OUTPUT_CONFIG"
        yq '.monitoring.enabled = true' -i "$OUTPUT_CONFIG"
        ;;
esac

echo "Configuration generated: $OUTPUT_CONFIG"
```

### Kubernetes Configuration Management
```bash
#!/bin/bash
# Kubernetes YAML configuration management

TEMPLATE_DIR="k8s/templates"
OUTPUT_DIR="k8s/manifests"
NAMESPACE=${1:-default}
ENVIRONMENT=${2:-development}

mkdir -p "$OUTPUT_DIR"

echo "Generating Kubernetes manifests for namespace: $NAMESPACE, environment: $ENVIRONMENT"

# Process deployment template
yq '.metadata.namespace = "'"$NAMESPACE"'"' "$TEMPLATE_DIR/deployment.yaml" > "$OUTPUT_DIR/deployment.yaml"
yq '.metadata.labels.environment = "'"$ENVIRONMENT"'"' -i "$OUTPUT_DIR/deployment.yaml"

# Update image tags based on environment
case $ENVIRONMENT in
    "development")
        yq '.spec.template.spec.containers[0].image = "myapp:latest"' -i "$OUTPUT_DIR/deployment.yaml"
        yq '.spec.replicas = 1' -i "$OUTPUT_DIR/deployment.yaml"
        ;;
    "staging")
        yq '.spec.template.spec.containers[0].image = "myapp:staging"' -i "$OUTPUT_DIR/deployment.yaml"
        yq '.spec.replicas = 2' -i "$OUTPUT_DIR/deployment.yaml"
        ;;
    "production")
        yq '.spec.template.spec.containers[0].image = "myapp:v1.0.0"' -i "$OUTPUT_DIR/deployment.yaml"
        yq '.spec.replicas = 3' -i "$OUTPUT_DIR/deployment.yaml"
        ;;
esac

# Process service template
yq '.metadata.namespace = "'"$NAMESPACE"'"' "$TEMPLATE_DIR/service.yaml" > "$OUTPUT_DIR/service.yaml"
yq '.metadata.labels.environment = "'"$ENVIRONMENT"'"' -i "$OUTPUT_DIR/service.yaml"

# Process configmap with environment-specific values
yq '.metadata.namespace = "'"$NAMESPACE"'"' "$TEMPLATE_DIR/configmap.yaml" > "$OUTPUT_DIR/configmap.yaml"
yq '.data.ENVIRONMENT = "'"$ENVIRONMENT"'"' -i "$OUTPUT_DIR/configmap.yaml"

echo "Kubernetes manifests generated in: $OUTPUT_DIR"
```

### Docker Compose Configuration
```bash
#!/bin/bash
# Docker Compose configuration management

BASE_COMPOSE="docker-compose.base.yaml"
ENV_COMPOSE="docker-compose.${1:-development}.yaml"
FINAL_COMPOSE="docker-compose.yaml"

echo "Generating Docker Compose configuration for environment: ${1:-development}"

# Start with base configuration
cp "$BASE_COMPOSE" "$FINAL_COMPOSE"

# Apply environment-specific overrides
if [ -f "$ENV_COMPOSE" ]; then
    # Merge environment-specific configuration
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$FINAL_COMPOSE" "$ENV_COMPOSE" > temp.yaml
    mv temp.yaml "$FINAL_COMPOSE"
fi

# Set environment-specific values
case ${1:-development} in
    "development")
        yq '.services.web.ports[0] = "3000:3000"' -i "$FINAL_COMPOSE"
        yq '.services.database.environment.POSTGRES_DB = "myapp_dev"' -i "$FINAL_COMPOSE"
        ;;
    "production")
        yq '.services.web.ports[0] = "80:3000"' -i "$FINAL_COMPOSE"
        yq '.services.database.environment.POSTGRES_DB = "myapp_prod"' -i "$FINAL_COMPOSE"
        yq '.services.web.restart = "always"' -i "$FINAL_COMPOSE"
        ;;
esac

echo "Docker Compose configuration generated: $FINAL_COMPOSE"
```

## Data Processing and Transformation

### JSON to YAML Conversion Pipeline
```bash
#!/bin/bash
# Convert JSON configuration files to YAML

JSON_DIR=$1
YAML_DIR=${2:-"yaml_configs"}

mkdir -p "$YAML_DIR"

echo "Converting JSON files to YAML..."

find "$JSON_DIR" -name "*.json" | while read json_file; do
    filename=$(basename "$json_file" .json)
    yaml_file="$YAML_DIR/${filename}.yaml"
    
    echo "Converting: $json_file -> $yaml_file"
    
    # Convert JSON to YAML with proper formatting
    yq -o yaml '.' "$json_file" > "$yaml_file"
    
    # Add header comment
    echo "# Converted from $json_file on $(date)" | cat - "$yaml_file" > temp && mv temp "$yaml_file"
done

echo "Conversion complete. YAML files in: $YAML_DIR"
```

### Configuration Validation and Linting
```bash
#!/bin/bash
# Validate and lint YAML configuration files

CONFIG_DIR=$1
VALIDATION_REPORT="/tmp/yaml_validation_$(date +%Y%m%d_%H%M%S).txt"

echo "YAML Configuration Validation Report" > "$VALIDATION_REPORT"
echo "Generated: $(date)" >> "$VALIDATION_REPORT"
echo "=======================================" >> "$VALIDATION_REPORT"

find "$CONFIG_DIR" -name "*.yaml" -o -name "*.yml" | while read yaml_file; do
    echo "Validating: $yaml_file" | tee -a "$VALIDATION_REPORT"
    
    # Check YAML syntax
    if yq '.' "$yaml_file" > /dev/null 2>&1; then
        echo "  ✓ Syntax: Valid" | tee -a "$VALIDATION_REPORT"
    else
        echo "  ✗ Syntax: Invalid" | tee -a "$VALIDATION_REPORT"
        yq '.' "$yaml_file" 2>&1 | sed 's/^/    /' | tee -a "$VALIDATION_REPORT"
        continue
    fi
    
    # Check for required fields (example)
    if yq 'has("name")' "$yaml_file" | grep -q "true"; then
        echo "  ✓ Required field 'name': Present" | tee -a "$VALIDATION_REPORT"
    else
        echo "  ✗ Required field 'name': Missing" | tee -a "$VALIDATION_REPORT"
    fi
    
    # Check for deprecated fields
    if yq 'has("deprecated_field")' "$yaml_file" | grep -q "true"; then
        echo "  ⚠ Deprecated field 'deprecated_field': Found" | tee -a "$VALIDATION_REPORT"
    fi
    
    # Validate data types
    if yq '.port | type' "$yaml_file" 2>/dev/null | grep -q "number"; then
        echo "  ✓ Port type: Number" | tee -a "$VALIDATION_REPORT"
    elif yq 'has("port")' "$yaml_file" | grep -q "true"; then
        echo "  ✗ Port type: Should be number" | tee -a "$VALIDATION_REPORT"
    fi
    
    echo "" >> "$VALIDATION_REPORT"
done

echo "Validation complete. Report: $VALIDATION_REPORT"
```

### Configuration Merging and Templating
```bash
#!/bin/bash
# Merge multiple YAML configurations with templating

TEMPLATE_FILE=$1
VALUES_FILE=$2
OUTPUT_FILE=${3:-"output.yaml"}

echo "Merging template with values..."
echo "Template: $TEMPLATE_FILE"
echo "Values: $VALUES_FILE"
echo "Output: $OUTPUT_FILE"

# Load values and apply to template
VALUES=$(yq '.' "$VALUES_FILE")

# Process template with value substitution
yq --argjson values "$VALUES" '
    # Replace template variables with actual values
    walk(
        if type == "string" and test("\\${\\{.*\\}}") then
            . as $template |
            $values | 
            to_entries |
            reduce .[] as $item ($template;
                gsub("\\${\\{" + $item.key + "\\}}"; $item.value | tostring)
            )
        else
            .
        end
    )
' "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Configuration merge complete: $OUTPUT_FILE"
```

## CI/CD Pipeline Integration

### GitHub Actions Configuration Generator
```bash
#!/bin/bash
# Generate GitHub Actions workflows from templates

TEMPLATE_DIR="ci/templates"
WORKFLOWS_DIR=".github/workflows"
PROJECT_CONFIG="project.yaml"

mkdir -p "$WORKFLOWS_DIR"

echo "Generating GitHub Actions workflows..."

# Read project configuration
PROJECT_NAME=$(yq '.project.name' "$PROJECT_CONFIG")
NODE_VERSION=$(yq '.project.node_version' "$PROJECT_CONFIG")
PYTHON_VERSION=$(yq '.project.python_version' "$PROJECT_CONFIG")

# Generate CI workflow
yq '.name = "CI - '"$PROJECT_NAME"'"' "$TEMPLATE_DIR/ci.template.yaml" > "$WORKFLOWS_DIR/ci.yaml"
yq '.jobs.test.steps[] |= if .uses == "actions/setup-node@v3" then .with.node-version = "'"$NODE_VERSION"'" else . end' -i "$WORKFLOWS_DIR/ci.yaml"

# Generate deployment workflow
yq '.name = "Deploy - '"$PROJECT_NAME"'"' "$TEMPLATE_DIR/deploy.template.yaml" > "$WORKFLOWS_DIR/deploy.yaml"

# Add environment-specific configurations
ENVIRONMENTS=$(yq '.environments | keys | .[]' "$PROJECT_CONFIG")

echo "$ENVIRONMENTS" | while read env; do
    ENV_CONFIG=$(yq '.environments.'"$env" "$PROJECT_CONFIG")
    
    # Add environment-specific job
    yq '.jobs.deploy_'"$env"' = {
        "name": "Deploy to '"$env"'",
        "runs-on": "ubuntu-latest",
        "environment": "'"$env"'",
        "steps": [
            {"uses": "actions/checkout@v3"},
            {"name": "Deploy", "run": "echo Deploying to '"$env"'"}
        ]
    }' -i "$WORKFLOWS_DIR/deploy.yaml"
done

echo "GitHub Actions workflows generated in: $WORKFLOWS_DIR"
```

### Helm Chart Value Management
```bash
#!/bin/bash
# Manage Helm chart values for different environments

CHART_DIR=$1
ENVIRONMENT=$2
NAMESPACE=${3:-default}

VALUES_DIR="$CHART_DIR/values"
BASE_VALUES="$VALUES_DIR/values.yaml"
ENV_VALUES="$VALUES_DIR/values-$ENVIRONMENT.yaml"
OUTPUT_VALUES="/tmp/helm-values-$ENVIRONMENT.yaml"

echo "Generating Helm values for environment: $ENVIRONMENT"

# Start with base values
cp "$BASE_VALUES" "$OUTPUT_VALUES"

# Merge environment-specific values
if [ -f "$ENV_VALUES" ]; then
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$OUTPUT_VALUES" "$ENV_VALUES" > temp.yaml
    mv temp.yaml "$OUTPUT_VALUES"
fi

# Set namespace
yq '.global.namespace = "'"$NAMESPACE"'"' -i "$OUTPUT_VALUES"

# Environment-specific configurations
case $ENVIRONMENT in
    "development")
        yq '.replicaCount = 1' -i "$OUTPUT_VALUES"
        yq '.resources.requests.memory = "128Mi"' -i "$OUTPUT_VALUES"
        yq '.autoscaling.enabled = false' -i "$OUTPUT_VALUES"
        ;;
    "staging")
        yq '.replicaCount = 2' -i "$OUTPUT_VALUES"
        yq '.resources.requests.memory = "256Mi"' -i "$OUTPUT_VALUES"
        yq '.autoscaling.enabled = true' -i "$OUTPUT_VALUES"
        yq '.autoscaling.minReplicas = 2' -i "$OUTPUT_VALUES"
        yq '.autoscaling.maxReplicas = 5' -i "$OUTPUT_VALUES"
        ;;
    "production")
        yq '.replicaCount = 3' -i "$OUTPUT_VALUES"
        yq '.resources.requests.memory = "512Mi"' -i "$OUTPUT_VALUES"
        yq '.autoscaling.enabled = true' -i "$OUTPUT_VALUES"
        yq '.autoscaling.minReplicas = 3' -i "$OUTPUT_VALUES"
        yq '.autoscaling.maxReplicas = 10' -i "$OUTPUT_VALUES"
        yq '.monitoring.enabled = true' -i "$OUTPUT_VALUES"
        ;;
esac

echo "Helm values generated: $OUTPUT_VALUES"
echo "Deploy with: helm upgrade --install myapp $CHART_DIR -f $OUTPUT_VALUES"
```

## Advanced Data Processing

### Multi-Document YAML Processing
```bash
#!/bin/bash
# Process multi-document YAML files

MULTI_DOC_YAML=$1
OUTPUT_DIR="/tmp/yaml_docs"

mkdir -p "$OUTPUT_DIR"

echo "Processing multi-document YAML file: $MULTI_DOC_YAML"

# Split multi-document YAML into individual files
yq -s '.metadata.name' "$MULTI_DOC_YAML" --output-dir "$OUTPUT_DIR"

# Process each document
for doc_file in "$OUTPUT_DIR"/*.yml; do
    if [ -f "$doc_file" ]; then
        doc_name=$(basename "$doc_file" .yml)
        echo "Processing document: $doc_name"
        
        # Add labels to each document
        yq '.metadata.labels.processed = "true"' -i "$doc_file"
        yq '.metadata.labels.timestamp = "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"' -i "$doc_file"
        
        # Validate document structure
        if yq 'has("apiVersion") and has("kind") and has("metadata")' "$doc_file" | grep -q "true"; then
            echo "  ✓ Valid Kubernetes resource"
        else
            echo "  ✗ Invalid Kubernetes resource structure"
        fi
    fi
done

# Recombine documents
echo "Recombining processed documents..."
cat "$OUTPUT_DIR"/*.yml > "${MULTI_DOC_YAML}.processed"

echo "Multi-document processing complete: ${MULTI_DOC_YAML}.processed"
```

### Configuration Diff and Merge
```bash
#!/bin/bash
# Compare and merge YAML configurations

CONFIG1=$1
CONFIG2=$2
MERGE_STRATEGY=${3:-"recursive"}  # recursive, shallow, or manual

echo "Comparing configurations:"
echo "  Config 1: $CONFIG1"
echo "  Config 2: $CONFIG2"

# Generate diff
yq --null-input '
    [
        (load("'"$CONFIG1"'") | [leaf_paths as $path | {"path": $path, "value": getpath($path), "source": "config1"}]),
        (load("'"$CONFIG2"'") | [leaf_paths as $path | {"path": $path, "value": getpath($path), "source": "config2"}])
    ] | flatten | group_by(.path) | map({
        "path": .[0].path,
        "values": [.[] | {source: .source, value: .value}]
    }) | map(select(.values | length > 1 or (.values | length == 1 and .values[0].source == "config2")))
' > config_diff.yaml

echo "Configuration differences found:"
yq '.[].path | join(".")' config_diff.yaml

# Merge configurations based on strategy
case $MERGE_STRATEGY in
    "recursive")
        echo "Performing recursive merge..."
        yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$CONFIG1" "$CONFIG2" > merged_config.yaml
        ;;
    "shallow")
        echo "Performing shallow merge..."
        yq eval-all 'select(fileIndex == 0) + select(fileIndex == 1)' "$CONFIG1" "$CONFIG2" > merged_config.yaml
        ;;
    "manual")
        echo "Manual merge required. Diff saved to: config_diff.yaml"
        cp "$CONFIG1" merged_config.yaml
        echo "Apply changes manually and run merge again with 'recursive' strategy"
        ;;
esac

if [ -f "merged_config.yaml" ]; then
    echo "Merged configuration saved: merged_config.yaml"
fi
```

### Data Validation and Schema Checking
```bash
#!/bin/bash
# Validate YAML against JSON schema

YAML_FILE=$1
SCHEMA_FILE=$2
VALIDATION_OUTPUT="/tmp/yaml_validation_$(date +%Y%m%d_%H%M%S).json"

echo "Validating YAML against schema..."
echo "  YAML: $YAML_FILE"
echo "  Schema: $SCHEMA_FILE"

# Convert YAML to JSON for validation
yq -o json '.' "$YAML_FILE" > "/tmp/yaml_as_json.json"

# Validate structure using yq
echo "Performing structural validation..."

# Check required fields from schema
REQUIRED_FIELDS=$(yq '.required[]' "$SCHEMA_FILE" 2>/dev/null)

if [ -n "$REQUIRED_FIELDS" ]; then
    echo "$REQUIRED_FIELDS" | while read field; do
        if yq 'has("'"$field"'")' "$YAML_FILE" | grep -q "true"; then
            echo "  ✓ Required field '$field': Present"
        else
            echo "  ✗ Required field '$field': Missing"
        fi
    done
fi

# Check data types
PROPERTIES=$(yq '.properties | keys | .[]' "$SCHEMA_FILE" 2>/dev/null)

if [ -n "$PROPERTIES" ]; then
    echo "$PROPERTIES" | while read prop; do
        EXPECTED_TYPE=$(yq '.properties.'"$prop"'.type' "$SCHEMA_FILE" 2>/dev/null)
        ACTUAL_TYPE=$(yq '.'"$prop"' | type' "$YAML_FILE" 2>/dev/null)
        
        if [ "$EXPECTED_TYPE" != "null" ] && [ "$ACTUAL_TYPE" != "null" ]; then
            if [ "$EXPECTED_TYPE" = "$ACTUAL_TYPE" ]; then
                echo "  ✓ Property '$prop': Type matches ($EXPECTED_TYPE)"
            else
                echo "  ✗ Property '$prop': Type mismatch (expected: $EXPECTED_TYPE, actual: $ACTUAL_TYPE)"
            fi
        fi
    done
fi

echo "Validation complete"
```

## Use Cases

### Configuration Management
- Environment-specific configuration generation
- Kubernetes and Docker Compose file management
- Application settings and secrets management
- Multi-environment deployment configuration

### CI/CD Pipeline Automation
- GitHub Actions and GitLab CI configuration
- Helm chart value management
- Automated deployment scripts
- Pipeline configuration templating

### Data Processing and ETL
- JSON to YAML conversion and vice versa
- Configuration file validation and linting
- Data transformation and normalization
- Multi-format data processing

### DevOps and Infrastructure
- Infrastructure as Code configuration
- Container orchestration setup
- Monitoring and logging configuration
- Service mesh and networking setup

## Installation
Lightweight YAML and JSON processor with powerful querying capabilities.
Essential tool for configuration management, data processing, and DevOps workflows.

## Dependencies
- None (static binary)
- Cross-platform compatibility
- Built-in JSON and YAML parsing
- jq-compatible query syntax

## Performance Features
- Fast YAML/JSON parsing and generation
- Memory-efficient processing for large files
- Stream processing capabilities
- Concurrent processing support for batch operations

---
*Part of PORTX Portable Development Environment*