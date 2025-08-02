# Monitoring Package Manual

## Package Information
- **Package Name**: monitoring
- **Category**: System Analysis
- **Type**: Monitoring Tools Suite
- **License**: Apache 2.0

## Description
Comprehensive monitoring tools for system metrics, infrastructure monitoring, and observability.

Collection of professional monitoring tools including Prometheus utilities and Telegraf for comprehensive system and application monitoring.
Essential for infrastructure monitoring, alerting, and observability in production environments.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| promtool.exe | Prometheus configuration and query tool | Validate Prometheus configs and test queries |
| telegraf.exe | Metrics collection agent | Collect and forward system and application metrics |

## Prometheus Tools (promtool)

### Configuration Validation
```bash
# Validate Prometheus configuration
promtool check config prometheus.yml

# Validate recording rules
promtool check rules recording-rules.yml

# Validate alerting rules
promtool check rules alerting-rules.yml

# Check web configuration
promtool check web-config web.yml
```

### Query Operations
```bash
# Test PromQL queries
promtool query instant 'up'
promtool query instant 'rate(http_requests_total[5m])'

# Query with timestamp
promtool query instant 'cpu_usage' --time="2023-01-01T12:00:00Z"

# Range queries
promtool query range 'cpu_usage' --start="2023-01-01T00:00:00Z" --end="2023-01-01T23:59:59Z" --step=1m
```

### TSDB Operations
```bash
# Analyze TSDB
promtool tsdb analyze /path/to/prometheus/data

# List TSDB blocks
promtool tsdb list /path/to/prometheus/data

# Dump TSDB samples
promtool tsdb dump /path/to/prometheus/data

# Create blocks from OpenMetrics
promtool tsdb create-blocks-from openmetrics metrics.txt /output/path
```

### Testing and Debugging
```bash
# Test alerting rules
promtool test rules test.yml

# Debug Prometheus configuration
promtool check config --syntax-only prometheus.yml

# Query label values
promtool query labels __name__
promtool query label-values job
```

## Telegraf Monitoring

### Basic Configuration
```bash
# Generate default configuration
telegraf config > telegraf.conf

# Run with specific config
telegraf --config telegraf.conf

# Test configuration
telegraf --config telegraf.conf --test

# Run once and exit
telegraf --config telegraf.conf --once
```

### Input Plugin Examples
```toml
# telegraf.conf

# System metrics
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false

[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

[[inputs.diskio]]

[[inputs.mem]]

[[inputs.net]]

[[inputs.processes]]

[[inputs.swap]]

[[inputs.system]]
```

### Application Monitoring
```toml
# HTTP response monitoring
[[inputs.http_response]]
  urls = [
    "http://localhost:8080/health",
    "https://api.example.com/status"
  ]
  response_timeout = "5s"
  method = "GET"

# Database monitoring
[[inputs.postgresql]]
  address = "postgres://user:pass@localhost/db?sslmode=disable"
  databases = ["app_db"]

# Docker monitoring
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
  gather_services = false
  container_names = []
```

### Custom Metrics Collection
```toml
# Log parsing
[[inputs.logparser]]
  files = ["/var/log/apache/access.log"]
  from_beginning = false
  [inputs.logparser.grok]
    patterns = ["%{COMMON_LOG_FORMAT}"]

# Command execution
[[inputs.exec]]
  commands = [
    "sensors",
    "iostat -x 1 1 | tail -n +4"
  ]
  timeout = "5s"
  data_format = "influx"

# SNMP monitoring
[[inputs.snmp]]
  agents = ["192.168.1.1:161"]
  version = 2
  community = "public"
  [[inputs.snmp.field]]
    name = "hostname"
    oid = "1.3.6.1.2.1.1.5.0"
```

## Output Configurations

### Time Series Databases
```toml
# InfluxDB output
[[outputs.influxdb]]
  urls = ["http://localhost:8086"]
  database = "telegraf"
  username = "admin"
  password = "password"

# Prometheus output
[[outputs.prometheus_client]]
  listen = ":9273"
  metric_version = 2

# CloudWatch output
[[outputs.cloudwatch]]
  region = "us-east-1"
  namespace = "MyApplication"
```

### Monitoring Platforms
```toml
# Datadog output
[[outputs.datadog]]
  apikey = "your-api-key"

# New Relic output
[[outputs.newrelic]]
  insights_key = "your-insights-key"
  account_id = "your-account-id"

# Grafana Cloud
[[outputs.influxdb]]
  urls = ["https://influx-prod-us-central1.grafana.net:8086"]
  database = "your-database"
  username = "your-username"
  password = "your-password"
```

## Advanced Monitoring Setups

### Multi-Environment Configuration
```toml
# Production environment
[global_tags]
  environment = "production"
  datacenter = "us-east-1"
  team = "platform"

[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
```

### Service Discovery
```toml
# Consul service discovery
[[inputs.consul]]
  address = "localhost:8500"
  scheme = "http"

# Kubernetes monitoring
[[inputs.kubernetes]]
  url = "https://kubernetes.default.svc:443"
  bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
  insecure_skip_verify = true
```

### Security and Authentication
```toml
# TLS configuration
[[outputs.influxdb]]
  urls = ["https://influxdb.example.com:8086"]
  tls_ca = "/path/to/ca.pem"
  tls_cert = "/path/to/cert.pem"
  tls_key = "/path/to/key.pem"

# Token authentication
[[outputs.prometheus_client]]
  listen = ":9273"
  tls_cert = "/path/to/cert.pem"
  tls_key = "/path/to/key.pem"
```

## Monitoring Workflows

### Infrastructure Monitoring
```bash
# 1. Configure Telegraf for system metrics
telegraf --config system-monitoring.conf

# 2. Validate Prometheus configuration
promtool check config prometheus.yml

# 3. Test alerting rules
promtool test rules infrastructure-alerts.yml

# 4. Deploy and monitor
telegraf --config telegraf.conf &
prometheus --config.file=prometheus.yml &
```

### Application Performance Monitoring
```toml
# APM configuration
[[inputs.statsd]]
  service_address = ":8125"
  metric_separator = "."

[[inputs.http_listener_v2]]
  service_address = ":8080"
  path = "/metrics"
  methods = ["POST"]

[[outputs.prometheus_client]]
  listen = ":9273"
  path = "/metrics"
```

### Log Aggregation
```toml
# Log monitoring
[[inputs.tail]]
  files = ["/var/log/app/*.log"]
  from_beginning = false
  data_format = "grok"
  grok_patterns = ["%{COMBINED_LOG_FORMAT}"]

[[processors.regex]]
  [[processors.regex.tags]]
    key = "path"
    pattern = "/var/log/app/(.*).log"
    replacement = "${1}"
    result_key = "service"
```

## Integration Examples

### Prometheus + Grafana Stack
```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      
  telegraf:
    image: telegraf:latest
    volumes:
      - ./telegraf.conf:/etc/telegraf/telegraf.conf:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

### Kubernetes Monitoring
```yaml
# telegraf-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: telegraf
spec:
  selector:
    matchLabels:
      app: telegraf
  template:
    metadata:
      labels:
        app: telegraf
    spec:
      containers:
      - name: telegraf
        image: telegraf:latest
        volumeMounts:
        - name: config
          mountPath: /etc/telegraf
        - name: docker-sock
          mountPath: /var/run/docker.sock
      volumes:
      - name: config
        configMap:
          name: telegraf-config
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
```

## Alert Configuration

### Prometheus Alerting Rules
```yaml
# alerts.yml
groups:
- name: infrastructure
  rules:
  - alert: HighCPUUsage
    expr: cpu_usage_active > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 5 minutes"

  - alert: DiskSpaceLow
    expr: disk_free / disk_total * 100 < 10
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "Low disk space"
      description: "Disk space is below 10%"
```

### Telegraf Alerting
```toml
# Threshold-based alerting
[[processors.starlark]]
  source = '''
def apply(metric):
    if metric.fields.get("usage_percent", 0) > 90:
        metric.tags["alert"] = "high_disk_usage"
    return metric
'''
```

## Use Cases

### Infrastructure Monitoring
- Server and network monitoring
- Container and orchestration monitoring
- Cloud infrastructure observability
- Performance optimization

### Application Monitoring
- APM and distributed tracing
- Business metrics collection
- User experience monitoring
- SLA/SLO tracking

### DevOps and SRE
- CI/CD pipeline monitoring
- Deployment tracking
- Incident response automation
- Capacity planning

### Security Monitoring
- System security metrics
- Access pattern analysis
- Anomaly detection
- Compliance monitoring

## Installation
Comprehensive monitoring tools suite for infrastructure and application observability.
Essential for production monitoring, alerting, and performance optimization.

## Dependencies
- Network connectivity to monitoring targets
- Appropriate system permissions for metric collection
- Storage backend for time-series data (InfluxDB, Prometheus, etc.)
- Alert manager for notification delivery

## Performance Features
- Efficient metric collection and aggregation
- Scalable time-series data handling
- Low-overhead monitoring agents
- Real-time alerting capabilities
- Flexible output and routing options

---
*Part of PORTX Portable Development Environment*