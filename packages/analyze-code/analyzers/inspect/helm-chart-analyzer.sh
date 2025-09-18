#!/bin/bash
# =============================================================================
# HELM CHART ARCHITECTURAL ANALYZER
# Analyzes Helm chart structure: dependencies, templates, services, and configuration
# Focus: Understanding microservice architecture through Chart.yaml, templates/, values.yaml
# =============================================================================

# Register this analyzer
AVAILABLE_ANALYZERS+=(analyze_helm_chart)

analyze_helm_chart() {
    local rg_path="$GIT_BASH_ROOT/home/portx/packages/ripgrep/rg.exe"
    local yq_path="$GIT_BASH_ROOT/home/portx/packages/yq/yq.exe"
    
    # Check if tools are available
    if [[ ! -f "$rg_path" ]]; then
        return_error '{"analyzer":"helm_chart","status":"unavailable","error":"ripgrep not found"}'
        return
    fi
    
    # Get file information and find Helm chart root
    local file_basename="$(basename "$FILE_PATH")"
    local file_dir="$(dirname "$FILE_PATH")"
    local chart_root=""
    
    # Find Helm chart root (look up 3 levels)
    for ((i=0; i<3; i++)); do
        if [[ -f "$file_dir/Chart.yaml" || -f "$file_dir/Chart.yml" ]]; then
            chart_root="$file_dir"
            break
        fi
        local parent_dir="$(dirname "$file_dir")"
        if [[ "$parent_dir" != "$file_dir" ]]; then
            file_dir="$parent_dir"
        else
            break
        fi
    done
    
    if [[ -z "$chart_root" ]]; then
        return_error '{"analyzer":"helm_chart","error":"Chart.yaml not found - not a Helm chart"}'
        return
    fi
    
    # Initialize analysis results
    local helm_dependencies=()
    local microservices=()
    local infrastructure_deps=()
    local values_config=()
    local template_analysis=()
    
    # Helper function for safe JSON creation
    create_finding() {
        local type="$1"
        local name="$2"
        local details="$3"
        local pattern="${4:-standard}"
        
        # Escape JSON strings safely
        local escaped_name escaped_details
        escaped_name=$(printf '%s' "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')
        escaped_details=$(printf '%s' "$details" | sed 's/\\/\\\\/g; s/"/\\"/g')
        
        printf '{"type":"%s","name":"%s","details":"%s","pattern":"%s"}' \
            "$type" "$escaped_name" "$escaped_details" "$pattern"
    }
    
    # =========================================================================
    # ANALYZE CHART.YAML - DEPENDENCIES AND METADATA
    # =========================================================================
    local chart_name="unknown"
    local chart_version="unknown"
    local chart_type="unknown"
    local total_dependencies=0
    
    if [[ -f "$chart_root/Chart.yaml" ]]; then
        local chart_file="$chart_root/Chart.yaml"
        
        # Extract basic chart metadata
        chart_name=$("$rg_path" -o "^name: .*" "$chart_file" | head -1 | cut -d: -f2 | tr -d ' "' || echo "unknown")
        chart_version=$("$rg_path" -o "^version: .*" "$chart_file" | head -1 | cut -d: -f2 | tr -d ' "' || echo "unknown")
        chart_type=$("$rg_path" -o "^type: .*" "$chart_file" | head -1 | cut -d: -f2 | tr -d ' "' || echo "unknown")
        
        # Analyze dependencies section
        local deps_section
        deps_section=$("$rg_path" -A 1000 "^dependencies:" "$chart_file" 2>/dev/null || true)
        
        if [[ -n "$deps_section" ]]; then
            # Count total dependencies
            total_dependencies=$(echo "$deps_section" | "$rg_path" -c "^ *- name:" 2>/dev/null || echo "0")
            
            # Categorize dependencies by type
            local db_deps infra_deps other_deps
            
            # Comprehensive database detection
            db_deps=$(echo "$deps_section" | "$rg_path" -o -i "alias: [a-zA-Z]*[Dd][Bb]" | head -20)
            if [[ -n "$db_deps" ]]; then
                local sql_dbs="" nosql_dbs="" cache_dbs=""
                
                while IFS= read -r db; do
                    local db_clean=$(echo "$db" | sed 's/alias: //' | tr '[:upper:]' '[:lower:]')
                    
                    if echo "$db_clean" | grep -qE "(postgres|postgresql|mysql|mariadb|oracle|mssql|sqlserver|ms-sql|db2|sqlite|cockroachdb|yugabytedb)"; then
                        sql_dbs+="$db_clean,"
                    elif echo "$db_clean" | grep -qE "(mongo|mongodb|cassandra|couchdb|dynamodb|cosmosdb|firestore|neo4j|arangodb|orientdb)"; then
                        nosql_dbs+="$db_clean,"
                    elif echo "$db_clean" | grep -qE "(redis|memcached|hazelcast|ignite|ehcache|infinispan)"; then
                        cache_dbs+="$db_clean,"
                    else
                        sql_dbs+="$db_clean,"
                    fi
                done <<< "$db_deps"
                
                local total_count=$(echo "$db_deps" | wc -l)
                [[ -n "$sql_dbs" ]] && helm_dependencies+=($(create_finding "sql_databases" "SQL Databases" "${sql_dbs%,}" "sql"))
                [[ -n "$nosql_dbs" ]] && helm_dependencies+=($(create_finding "nosql_databases" "NoSQL Databases" "${nosql_dbs%,}" "nosql"))
                [[ -n "$cache_dbs" ]] && helm_dependencies+=($(create_finding "cache_databases" "Cache Databases" "${cache_dbs%,}" "cache"))
                helm_dependencies+=($(create_finding "databases" "Database Summary" "$total_count total instances" "database-per-service"))
            fi
            
            # Comprehensive infrastructure detection
            infra_deps=$(echo "$deps_section" | "$rg_path" -o "name: [a-zA-Z-]*" | head -30)
            if [[ -n "$infra_deps" ]]; then
                local observability="" data_lakes="" kafka_ecosystem="" stream_processing="" message_buses="" cloud_messaging="" cloud_platform="" networking="" general=""
                
                while IFS= read -r infra; do
                    local infra_clean=$(echo "$infra" | sed 's/name: //' | tr '[:upper:]' '[:lower:]')
                    
                    # Observability: ELK, monitoring, tracing, logging
                    if echo "$infra_clean" | grep -qE "(elastic|kibana|logstash|opensearch|grafana|prometheus|jaeger|zipkin|datadog|newrelic|splunk|fluentd|fluent-bit|loki|tempo|cortex|metricbeat|filebeat|heartbeat|packetbeat|apm-server)"; then
                        observability+="$infra_clean,"
                    # Data Lakes: MinIO, object storage, data platforms, query engines
                    elif echo "$infra_clean" | grep -qE "(minio|s3|gcs|azure-storage|azure-blob|hdfs|delta|iceberg|hudi|ceph|gluster|zombo|lakefs|databricks|snowflake|spark|trino|presto|athena|hive|glue|unity-catalog|atlas|datahub)"; then
                        data_lakes+="$infra_clean,"
                    # Kafka Ecosystem: Kafka, operators, management, connectors
                    elif echo "$infra_clean" | grep -qE "(kafka|strimzi|confluent|debezium|kafka-connect|schema-registry|akhq|kafdrop|lenses|conduktor|cmak|kowl|redpanda|kpow|burrow|kafka-ui|kafka-exporter|zookeeper)"; then
                        kafka_ecosystem+="$infra_clean,"
                    # Stream Processing: Flink, Kafka Streams, KSQL
                    elif echo "$infra_clean" | grep -qE "(flink|kafka-streams|ksql|ksqldb|spark-streaming|storm|samza|beam|dataflow)"; then
                        stream_processing+="$infra_clean,"
                    # Message Buses: RabbitMQ, ActiveMQ, Pulsar, NATS, etc.
                    elif echo "$infra_clean" | grep -qE "(rabbitmq|activemq|artemis|pulsar|nats|qpid|ibm-mq|websphere-mq|rocketmq|zeromq|nanomsg)"; then
                        message_buses+="$infra_clean,"
                    # Cloud Messaging: SQS, Service Bus, Pub/Sub, Kinesis
                    elif echo "$infra_clean" | grep -qE "(sqs|sns|servicebus|pubsub|kinesis|eventhub|eventbridge|stepfunctions)"; then
                        cloud_messaging+="$infra_clean,"
                    # Cloud Platforms: AWS, GCP, Azure, OpenShift, K3s, Docker
                    elif echo "$infra_clean" | grep -qE "(aws-|gcp-|azure-|openshift|k3s|docker|docker-desktop|rancher|ebs|efs|gke|aks|eks|fargate|lambda|cloudrun)"; then
                        cloud_platform+="$infra_clean,"
                    # Networking: Load balancers, service mesh, ingress
                    elif echo "$infra_clean" | grep -qE "(traefik|nginx|haproxy|envoy|istio|linkerd|ingress|gateway|ambassador|consul|vault)"; then
                        networking+="$infra_clean,"
                    else
                        general+="$infra_clean,"
                    fi
                done <<< "$infra_deps"
                
                [[ -n "$observability" ]] && helm_dependencies+=($(create_finding "observability" "Observability Stack" "${observability%,}" "monitoring_logging_tracing"))
                [[ -n "$data_lakes" ]] && helm_dependencies+=($(create_finding "data_lakes" "Data Lakes & Analytics" "${data_lakes%,}" "data_lake_analytics"))
                [[ -n "$kafka_ecosystem" ]] && helm_dependencies+=($(create_finding "kafka_ecosystem" "Kafka Ecosystem" "${kafka_ecosystem%,}" "kafka_platform"))
                [[ -n "$stream_processing" ]] && helm_dependencies+=($(create_finding "stream_processing" "Stream Processing" "${stream_processing%,}" "stream_analytics"))
                [[ -n "$message_buses" ]] && helm_dependencies+=($(create_finding "message_buses" "Message Buses" "${message_buses%,}" "enterprise_messaging"))
                [[ -n "$cloud_messaging" ]] && helm_dependencies+=($(create_finding "cloud_messaging" "Cloud Messaging" "${cloud_messaging%,}" "cloud_events"))
                [[ -n "$cloud_platform" ]] && helm_dependencies+=($(create_finding "cloud_platform" "Cloud Platforms" "${cloud_platform%,}" "cloud_native"))
                [[ -n "$networking" ]] && helm_dependencies+=($(create_finding "networking" "Networking & Service Mesh" "${networking%,}" "service_mesh"))
                [[ -n "$general" ]] && helm_dependencies+=($(create_finding "infrastructure" "General Infrastructure" "${general%,}" "external_infrastructure"))
            fi
        fi
    fi
    
    # =========================================================================
    # ANALYZE TEMPLATES DIRECTORY - ACTUAL KUBERNETES ARCHITECTURE
    # =========================================================================
    local k8s_analysis=()
    if [[ -d "$chart_root/templates" ]]; then
        local templates_dir="$chart_root/templates"
        
        # Initialize Kubernetes resource counters
        local deployments=() statefulsets=() services=() configmaps=() secrets=() hpas=() ingresses=() pvcs=()
        local deployment_count=0 statefulset_count=0 service_count=0 configmap_count=0 secret_count=0 hpa_count=0 ingress_count=0 pvc_count=0
        
        # Find all microservice directories and analyze their Kubernetes resources
        local service_dirs=()
        while IFS= read -r -d '' dir; do
            local service_name=$(basename "$dir")
            # Skip common/shared directories 
            if [[ "$service_name" =~ ^(common|shared|config|_helpers|internet-ingress|db-config)$ ]]; then
                continue
            fi
            
            local workload_type="none"
            local has_hpa=false has_storage=false has_ingress=false
            local k8s_resources=()
            
            # Check for workload types (Deployment vs StatefulSet)
            if [[ -f "$dir/deployment.yaml" ]]; then
                # Verify it's actually a Deployment
                if grep -q "kind: Deployment" "$dir/deployment.yaml" 2>/dev/null; then
                    workload_type="Deployment"
                    deployment_count=$((deployment_count + 1))
                    deployments+=("$service_name")
                elif grep -q "kind: StatefulSet" "$dir/deployment.yaml" 2>/dev/null; then
                    workload_type="StatefulSet"  
                    statefulset_count=$((statefulset_count + 1))
                    statefulsets+=("$service_name")
                fi
                service_dirs+=("$service_name")
            fi
            
            # Only analyze if we found a workload
            if [[ "$workload_type" != "none" ]]; then
                # Check for standard Kubernetes resources
                [[ -f "$dir/service.yaml" ]] && k8s_resources+=("Service") && service_count=$((service_count + 1))
                [[ -f "$dir/configmap.yaml" ]] && k8s_resources+=("ConfigMap") && configmap_count=$((configmap_count + 1))
                [[ -f "$dir/secret.yaml" ]] && k8s_resources+=("Secret") && secret_count=$((secret_count + 1))
                
                # Check for HPA (autoscaling)
                if [[ -f "$dir/hpa.yaml" ]]; then
                    k8s_resources+=("HPA")
                    has_hpa=true
                    hpa_count=$((hpa_count + 1))
                    hpas+=("$service_name")
                fi
                
                # Check for storage (PVC)
                if [[ -f "$dir/storage.yaml" ]] || find "$dir" -name "*storage*.yaml" -o -name "*pvc*.yaml" -o -name "*pv*.yaml" 2>/dev/null | grep -q .; then
                    has_storage=true
                    pvc_count=$((pvc_count + 1))
                    pvcs+=("$service_name")
                fi
                
                # Check for ingress
                if [[ -f "$dir/ingress.yaml" ]] || find "$dir" -name "*ingress*.yaml" 2>/dev/null | grep -q .; then
                    has_ingress=true
                    ingress_count=$((ingress_count + 1))
                    ingresses+=("$service_name")
                fi
                
                # Build service analysis
                local resource_list=$(IFS=,; echo "${k8s_resources[*]}")
                local service_features=""
                [[ "$has_hpa" == true ]] && service_features+="autoscaling,"
                [[ "$has_storage" == true ]] && service_features+="persistent_storage,"
                [[ "$has_ingress" == true ]] && service_features+="external_access,"
                service_features=${service_features%,}  # Remove trailing comma
                
                microservices+=($(create_finding "microservice" "$service_name" "$workload_type with resources: $resource_list${service_features:+ | Features: $service_features}" "$workload_type"))
            fi
        done < <(find "$templates_dir" -maxdepth 1 -type d -not -path "$templates_dir" -print0 2>/dev/null)
        
        # Create Kubernetes architecture analysis
        if [[ $deployment_count -gt 0 ]]; then
            k8s_analysis+=($(create_finding "workloads" "Deployment Pattern" "$deployment_count services using Deployment (stateless workloads)" "stateless"))
        fi
        
        if [[ $statefulset_count -gt 0 ]]; then
            k8s_analysis+=($(create_finding "workloads" "StatefulSet Pattern" "$statefulset_count services using StatefulSet (stateful workloads)" "stateful"))
        fi
        
        if [[ $hpa_count -gt 0 ]]; then
            local hpa_services=$(IFS=,; echo "${hpas[*]}")
            k8s_analysis+=($(create_finding "autoscaling" "Horizontal Pod Autoscaling" "$hpa_count services with HPA: $hpa_services" "elastic_scaling"))
        fi
        
        if [[ $pvc_count -gt 0 ]]; then
            local storage_services=$(IFS=,; echo "${pvcs[*]}")
            k8s_analysis+=($(create_finding "storage" "Persistent Storage" "$pvc_count services with persistent volumes: $storage_services" "persistent_data"))
        fi
        
        if [[ $ingress_count -gt 0 ]]; then
            local ingress_services=$(IFS=,; echo "${ingresses[*]}")
            k8s_analysis+=($(create_finding "networking" "External Access" "$ingress_count services with ingress: $ingress_services" "public_endpoints"))
        fi
        
        # Global template analysis
        local total_yaml_files=0
        if command -v find >/dev/null 2>&1; then
            total_yaml_files=$(find "$templates_dir" -name "*.yaml" -o -name "*.yml" 2>/dev/null | wc -l)
        fi
        
        if [[ $total_yaml_files -gt 0 ]]; then
            template_analysis+=($(create_finding "templates" "Kubernetes Resource Distribution" "Total: $total_yaml_files YAML files | Services: $service_count | ConfigMaps: $configmap_count | Secrets: $secret_count | Storage: $pvc_count" "kubernetes_native"))
        fi
    fi
    
    # =========================================================================
    # ANALYZE VALUES.YAML - CONFIGURATION PATTERNS
    # =========================================================================
    local values_config_sections=0
    if [[ -f "$chart_root/values.yaml" ]]; then
        local values_file="$chart_root/values.yaml"
        
        # Count top-level configuration sections in values.yaml
        values_config_sections=$("$rg_path" -c "^[a-zA-Z][a-zA-Z0-9_-]*:" "$values_file" 2>/dev/null || echo "0")
        
        if [[ $values_config_sections -gt 0 ]]; then
            values_config+=($(create_finding "configuration" "Values Configuration Sections" "$values_config_sections top-level configuration sections in values.yaml" "configurable"))
        fi
        
        # Look for common configuration patterns
        local image_configs env_configs resource_configs
        image_configs=$("$rg_path" -c "image:" "$values_file" 2>/dev/null || echo "0")
        env_configs=$("$rg_path" -c "env:" "$values_file" 2>/dev/null || echo "0")
        resource_configs=$("$rg_path" -c "resources:" "$values_file" 2>/dev/null || echo "0")
        
        if [[ $image_configs -gt 0 ]]; then
            values_config+=($(create_finding "images" "Container Images" "$image_configs image configurations found" "containerized"))
        fi
        
        if [[ $resource_configs -gt 0 ]]; then
            values_config+=($(create_finding "resources" "Resource Management" "$resource_configs services with resource constraints" "resource_managed"))
        fi
    fi
    
    # =========================================================================
    # ARCHITECTURE ANALYSIS AND PATTERNS
    # =========================================================================
    local architecture_patterns=()
    local complexity="simple"
    
    local total_deps=$total_dependencies
    
    if [[ $total_deps -gt 20 ]]; then
        complexity="high"
        architecture_patterns+=($(create_finding "complexity" "Complex Architecture" "High dependency count with $total_deps external dependencies" "complex_distributed"))
    elif [[ $total_deps -gt 10 ]]; then
        complexity="medium"  
        architecture_patterns+=($(create_finding "complexity" "Multi-Dependency Architecture" "Moderate complexity with $total_deps dependencies" "service_oriented"))
    fi
    
    # Detect database-per-service pattern
    local db_deps_count=0
    for dep in "${helm_dependencies[@]}"; do
        if echo "$dep" | grep -q '"type":"databases"'; then
            db_deps_count=$(echo "$dep" | grep -o '[0-9]* database' | grep -o '[0-9]*')
            break
        fi
    done
    
    if [[ $db_deps_count -gt 3 ]]; then
        architecture_patterns+=($(create_finding "pattern" "Database-per-Service Pattern" "Each service has dedicated database instance" "microservice_isolation"))
    fi
    
    # Format JSON arrays
    local deps_json="[]" services_json="[]" infra_json="[]" values_json="[]" templates_json="[]" patterns_json="[]" k8s_json="[]"
    
    [[ ${#helm_dependencies[@]} -gt 0 ]] && deps_json="[$(IFS=,; echo "${helm_dependencies[*]}")]"
    [[ ${#microservices[@]} -gt 0 ]] && services_json="[$(IFS=,; echo "${microservices[*]}")]" 
    [[ ${#infrastructure_deps[@]} -gt 0 ]] && infra_json="[$(IFS=,; echo "${infrastructure_deps[*]}")]"
    [[ ${#values_config[@]} -gt 0 ]] && values_json="[$(IFS=,; echo "${values_config[*]}")]"
    [[ ${#template_analysis[@]} -gt 0 ]] && templates_json="[$(IFS=,; echo "${template_analysis[*]}")]"
    [[ ${#architecture_patterns[@]} -gt 0 ]] && patterns_json="[$(IFS=,; echo "${architecture_patterns[*]}")]"
    [[ ${#k8s_analysis[@]} -gt 0 ]] && k8s_json="[$(IFS=,; echo "${k8s_analysis[*]}")]"
    
    # Generate comprehensive architectural analysis
    local helm_result
    helm_result=$(printf '{"analyzer":"helm_chart","file":"%s","chart_metadata":{"name":"%s","version":"%s","type":"%s","chart_root":"%s"},"architecture":{"services":{"template_services":%s},"dependencies":{"count":%d,"external_deps":%s},"kubernetes":{"analysis":%s},"templates":{"analysis":%s},"configuration":{"values_sections":%d,"values_analysis":%s}},"patterns":{"detected":%s,"complexity":"%s"},"summary":{"values_config_sections":%d,"chart_dependencies":%d,"architecture_type":"%s"},"metadata":{"analyzed_at":"%s","note":"Comprehensive Helm chart analysis: services, dependencies, Kubernetes resources, templates, and configuration"}}' \
        "$FILE_PATH" \
        "$chart_name" \
        "$chart_version" \
        "$chart_type" \
        "$chart_root" \
        "$services_json" \
        "$total_dependencies" \
        "$deps_json" \
        "$k8s_json" \
        "$templates_json" \
        "$values_config_sections" \
        "$values_json" \
        "$patterns_json" \
        "$complexity" \
        "$values_config_sections" \
        "$total_dependencies" \
        "$([ $total_dependencies -gt 1 ] && echo "distributed" || echo "simple")" \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "unknown")")
    
    return_success "$helm_result"
}