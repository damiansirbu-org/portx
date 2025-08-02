# Nuclei Package Manual

## Package Information
- **Package Name**: nuclei
- **Category**: Security Tools
- **Type**: Vulnerability Scanner
- **License**: MIT

## Description
Fast and customizable vulnerability scanner based on simple YAML templates.

Community-powered vulnerability scanner with extensible template system for security testing and bug bounty hunting.
Designed for modern security testing with fast execution and comprehensive coverage.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| nuclei.exe | Template-based vulnerability scanner | Scan for security vulnerabilities using YAML templates |

## Common Usage Examples

### Basic Vulnerability Scanning
```bash
# Scan single target
nuclei -u https://example.com

# Scan multiple targets from file
nuclei -l targets.txt

# Scan with specific templates
nuclei -u https://example.com -t cves/

# Scan with template tags
nuclei -u https://example.com -tags exposure,config
```

### Template Management
```bash
# Update templates
nuclei -update-templates

# List available templates
nuclei -tl

# List templates by severity
nuclei -tl -severity critical,high

# List templates by tags
nuclei -tl -tags cve,rce

# Validate template syntax
nuclei -validate -t /path/to/template.yaml
```

### Advanced Scanning Options
```bash
# Scan with rate limiting
nuclei -u https://example.com -rate-limit 10

# Parallel scanning
nuclei -l targets.txt -c 50

# Scan with custom headers
nuclei -u https://example.com -H "Authorization: Bearer token"

# Scan through proxy
nuclei -u https://example.com -proxy http://127.0.0.1:8080
```

## Template System

### Built-in Template Categories
```bash
# Scan by category
nuclei -u target.com -t cves/          # CVE templates
nuclei -u target.com -t exposures/     # Information disclosure
nuclei -u target.com -t misconfiguration/  # Configuration issues
nuclei -u target.com -t technologies/  # Technology detection
nuclei -u target.com -t takeovers/     # Subdomain takeovers
nuclei -u target.com -t vulnerabilities/   # General vulnerabilities
```

### Template Tags
```bash
# Common template tags
nuclei -u target.com -tags apache      # Apache-specific
nuclei -u target.com -tags aws         # AWS-related
nuclei -u target.com -tags config      # Configuration issues
nuclei -u target.com -tags exposure    # Information exposure
nuclei -u target.com -tags injection   # Injection vulnerabilities
nuclei -u target.com -tags iot         # IoT devices
nuclei -u target.com -tags misconfig   # Misconfigurations
nuclei -u target.com -tags panel       # Admin panels
nuclei -u target.com -tags rce         # Remote code execution
nuclei -u target.com -tags sqli        # SQL injection
nuclei -u target.com -tags xss         # Cross-site scripting
```

### Severity Filtering
```bash
# Scan by severity levels
nuclei -u target.com -severity critical
nuclei -u target.com -severity high,critical
nuclei -u target.com -severity medium,high,critical
nuclei -u target.com -severity low,medium,high,critical
```

## Output and Reporting

### Output Formats
```bash
# JSON output
nuclei -u target.com -json -o results.json

# Markdown report
nuclei -u target.com -markdown -o report.md

# SARIF output (for security tools)
nuclei -u target.com -sarif -o results.sarif

# Silent mode (only findings)
nuclei -u target.com -silent

# Verbose output
nuclei -u target.com -v
```

### Custom Output
```bash
# Custom output format
nuclei -u target.com -format '{{.TemplateID}} - {{.URL}} - {{.Info.Severity}}'

# Include metadata
nuclei -u target.com -include-tags -include-id

# Export matched templates
nuclei -u target.com -export-templates matched_templates/

# Save HTTP responses
nuclei -u target.com -store-resp -store-resp-dir responses/
```

## Custom Template Development

### Basic Template Structure
```yaml
# custom-template.yaml
id: custom-vulnerability-check

info:
  name: Custom Vulnerability Check
  author: security-team
  severity: medium
  description: Checks for custom vulnerability
  tags: custom,webapp

requests:
  - method: GET
    path:
      - "{{BaseURL}}/admin/config.php"
      - "{{BaseURL}}/config/database.yml"

    matchers:
      - type: word
        words:
          - "password"
          - "database_password"
        condition: and

      - type: status
        status:
          - 200
```

### Advanced Template Features
```yaml
# advanced-template.yaml
id: advanced-vulnerability-check

info:
  name: Advanced Vulnerability Check
  author: security-team
  severity: high
  description: Advanced template with multiple request types
  tags: advanced,custom

variables:
  username: "admin"
  
requests:
  - method: POST
    path:
      - "{{BaseURL}}/login"
    
    headers:
      Content-Type: "application/x-www-form-urlencoded"
    
    body: "username={{username}}&password=FUZZ"
    
    payloads:
      password:
        - admin
        - password
        - 123456
    
    matchers:
      - type: word
        words:
          - "Welcome"
          - "Dashboard"
        condition: or
      
      - type: status
        status:
          - 302

    extractors:
      - type: regex
        regex:
          - 'session=([a-zA-Z0-9]+)'
        group: 1
```

### Template with Network Requests
```yaml
# network-template.yaml
id: network-service-check

info:
  name: Network Service Check
  author: security-team
  severity: info
  description: Checks network services
  tags: network,discovery

network:
  - inputs:
      - data: "{{hex_decode('474554202f20485454502f312e310d0a486f73743a207b7b486f73747d7d0d0a0d0a')}}"
    
    host:
      - "{{Hostname}}"
    
    port: 80
    
    matchers:
      - type: word
        words:
          - "HTTP/1.1 200"
          - "Server:"
```

## Integration Workflows

### Bug Bounty Workflow
```bash
# Comprehensive bug bounty scan
echo "target.com" | \
  subfinder | \
  httpx -silent | \
  nuclei -t cves/ -t exposures/ -t vulnerabilities/ \
  -severity medium,high,critical \
  -json -o findings.json
```

### CI/CD Security Pipeline
```bash
# Security scan in CI/CD
nuclei -u $TARGET_URL \
  -t cves/ -t exposures/ \
  -severity high,critical \
  -json -o security-scan.json

# Check if critical vulnerabilities found
if grep -q '"severity":"critical"' security-scan.json; then
  echo "Critical vulnerabilities found!"
  exit 1
fi
```

### Continuous Security Monitoring
```bash
# Daily security scan
#!/bin/bash
DATE=$(date +%Y%m%d)
nuclei -l production-targets.txt \
  -t cves/ -t exposures/ \
  -severity high,critical \
  -json -o "scans/daily-scan-$DATE.json"

# Alert on new findings
if [ -s "scans/daily-scan-$DATE.json" ]; then
  echo "New security findings detected!" | mail -s "Security Alert" security@company.com
fi
```

## Advanced Configuration

### Configuration File (~/.config/nuclei/config.yaml)
```yaml
# Nuclei configuration
rate-limit: 150
bulk-size: 25
timeout: 5
retries: 1
max-host-error: 30

# Template settings
templates-directory: ~/.nuclei-templates
update-templates: true
template-url: https://github.com/projectdiscovery/nuclei-templates

# Output settings
silent: false
verbose: false
json: false
include-tags: false
include-id: false

# Network settings
proxy: ""
system-resolvers: false
resolvers: []

# HTTP settings
user-agent: "Nuclei - Open-source project (github.com/projectdiscovery/nuclei)"
header: []
follow-redirects: false
max-redirects: 10
disable-redirects: false
```

### Custom Template Directory
```bash
# Set custom template directory
nuclei -u target.com -t custom-templates/

# Use multiple template directories
nuclei -u target.com -t templates1/ -t templates2/ -t templates3/

# Include specific template files
nuclei -u target.com -t custom.yaml -t critical-checks.yaml
```

## Performance Optimization

### Scanning Performance
```bash
# High-performance scanning
nuclei -l targets.txt \
  -c 100 \
  -rate-limit 200 \
  -bulk-size 50 \
  -timeout 3 \
  -retries 1

# Memory-efficient scanning
nuclei -l large-targets.txt \
  -stream \
  -bs 10 \
  -c 25
```

### Template Optimization
```bash
# Fast vulnerability scanning
nuclei -u target.com \
  -t cves/ \
  -severity critical \
  -exclude-tags dos \
  -timeout 5

# Targeted scanning
nuclei -u target.com \
  -tags exposure,config \
  -exclude-severity info \
  -silent
```

## Security Testing Workflows

### Web Application Testing
```bash
# Comprehensive web app scan
nuclei -u https://webapp.com \
  -t exposures/ \
  -t vulnerabilities/ \
  -t misconfiguration/ \
  -severity medium,high,critical \
  -json -o webapp-scan.json
```

### Infrastructure Testing
```bash
# Infrastructure vulnerability scan
nuclei -l infrastructure-ips.txt \
  -t cves/ \
  -t network/ \
  -t ssl/ \
  -severity high,critical \
  -json -o infrastructure-scan.json
```

### API Security Testing
```bash
# API endpoint testing
nuclei -l api-endpoints.txt \
  -t exposures/apis/ \
  -t misconfiguration/apis/ \
  -H "Authorization: Bearer $API_TOKEN" \
  -json -o api-scan.json
```

## Use Cases

### Security Assessment
- Vulnerability discovery and validation
- Security configuration review
- Compliance checking
- Penetration testing automation

### Bug Bounty Hunting
- Large-scale target scanning
- Zero-day template development
- Automated reconnaissance
- Finding validation and reporting

### DevSecOps Integration
- CI/CD security gates
- Continuous security monitoring
- Security regression testing
- Automated vulnerability management

### Research and Development
- Security research automation
- Template development and testing
- Proof-of-concept validation
- Threat intelligence gathering

## Installation
Fast and customizable vulnerability scanner with community-powered templates.
Essential tool for modern security testing and vulnerability assessment.

## Dependencies
None - standalone executable with built-in HTTP client and template engine.

## Performance Features
- Fast concurrent scanning
- Efficient template matching
- Memory-optimized execution
- Rate limiting and throttling
- Scalable architecture

---
*Part of PORTX Portable Development Environment*