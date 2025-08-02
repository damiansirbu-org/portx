# httpx Package Manual

## Package Information
- **Package Name**: httpx
- **Category**: Network Tools
- **Type**: HTTP Toolkit
- **License**: MIT

## Description
Fast and multi-purpose HTTP toolkit for web reconnaissance and security testing.

High-performance HTTP client designed for web application security testing, reconnaissance, and automation.
Features advanced filtering, customizable output, and comprehensive HTTP protocol support.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| httpx.exe | Multi-purpose HTTP toolkit | Web reconnaissance and HTTP testing |

## Common Usage Examples

### Basic HTTP Probing
```bash
# Probe single URL
httpx -u https://example.com

# Probe multiple URLs from file
httpx -l urls.txt

# Probe from stdin
echo "https://example.com" | httpx

# Probe with different methods
httpx -u https://example.com -X POST
```

### Web Reconnaissance
```bash
# Probe multiple domains
httpx -l domains.txt -ports 80,443,8080,8443

# Check for specific technologies
httpx -l targets.txt -tech-detect

# Extract page titles
httpx -l urls.txt -title

# Get response headers
httpx -l targets.txt -include-response-header
```

### Status Code Filtering
```bash
# Show only specific status codes
httpx -l urls.txt -mc 200,301,302

# Exclude specific status codes
httpx -l urls.txt -fc 404,403

# Filter by status code ranges
httpx -l urls.txt -mc 2xx,3xx

# Show only error codes
httpx -l urls.txt -mc 4xx,5xx
```

### Advanced Filtering
```bash
# Filter by response size
httpx -l urls.txt -ms 1000  # Minimum size
httpx -l urls.txt -mxs 5000 # Maximum size

# Filter by response time
httpx -l urls.txt -rt 5     # Response time < 5 seconds

# Filter by specific strings in response
httpx -l urls.txt -mr "admin panel"

# Filter by regex patterns
httpx -l urls.txt -mr "(?i)(login|admin)"
```

### Output Customization
```bash
# JSON output
httpx -l urls.txt -json

# Custom output format
httpx -l urls.txt -o results.txt

# CSV output
httpx -l urls.txt -csv

# Include response body
httpx -l urls.txt -include-response

# Save response to files
httpx -l urls.txt -store-response -store-response-dir responses/
```

### Technology Detection
```bash
# Detect web technologies
httpx -l targets.txt -tech-detect

# Extract favicon hashes
httpx -l urls.txt -favicon

# Detect CDN
httpx -l targets.txt -cdn

# Extract page titles and tech
httpx -l urls.txt -title -tech-detect -server
```

## Advanced Features

### Custom Headers and Authentication
```bash
# Custom headers
httpx -l urls.txt -H "User-Agent: Custom-Agent"
httpx -l urls.txt -H "Authorization: Bearer token123"

# Multiple headers
httpx -l urls.txt -H "Header1: value1" -H "Header2: value2"

# Basic authentication
httpx -l urls.txt -auth username:password

# Custom request body
httpx -u https://api.example.com -X POST -d '{"key":"value"}'
```

### Proxy and Network Configuration
```bash
# Use HTTP proxy
httpx -l urls.txt -http-proxy http://127.0.0.1:8080

# Use SOCKS proxy
httpx -l urls.txt -socks-proxy socks5://127.0.0.1:1080

# Custom timeout
httpx -l urls.txt -timeout 10

# Rate limiting
httpx -l urls.txt -rate-limit 100

# Custom User-Agent
httpx -l urls.txt -random-agent
```

### SSL/TLS Configuration
```bash
# Skip SSL verification
httpx -l urls.txt -verify=false

# Custom SSL configuration
httpx -l urls.txt -tls-grab

# Extract SSL certificate info
httpx -l urls.txt -jarm

# Check for SSL/TLS vulnerabilities
httpx -l urls.txt -tls-probe
```

### Web Application Testing
```bash
# Check for common files
httpx -l domains.txt -path /admin,/login,/api

# Directory bruteforcing
httpx -l urls.txt -paths common-paths.txt

# Parameter discovery
httpx -l urls.txt -path "/?param=FUZZ"

# Check for backup files
httpx -l urls.txt -path "/.git/config,.env,.bak"
```

## Security Testing Workflows

### Subdomain Enumeration
```bash
# Probe discovered subdomains
subfinder -d example.com | httpx

# Combine with other tools
echo "example.com" | subfinder | httpx -title -tech-detect

# Mass virtual host discovery
echo "192.168.1.1" | httpx -vhost -wordlist vhosts.txt
```

### Vulnerability Assessment
```bash
# Check for common vulnerabilities
httpx -l targets.txt -path "/admin,/.git/config,/.env"

# Extract interesting files
httpx -l urls.txt -mr "password|secret|api_key"

# Check for default credentials
httpx -l urls.txt -path "/admin" -mc 200 -title
```

### Content Discovery
```bash
# Discover hidden endpoints
httpx -l domains.txt -paths wordlists/common.txt

# Extract URLs from responses
httpx -l urls.txt -extract-urls

# Find interesting files
httpx -l targets.txt -mr "\.pdf|\.doc|\.xls" -extract-urls
```

### API Testing
```bash
# Test API endpoints
httpx -l api-endpoints.txt -X GET,POST,PUT,DELETE

# Check API documentation
httpx -l domains.txt -path "/api/docs,/swagger,/graphql"

# Test API versioning
httpx -l apis.txt -path "/v1,/v2,/api/v1,/api/v2"
```

## Integration with Other Tools

### Pipeline with Other Security Tools
```bash
# Complete reconnaissance pipeline
echo "example.com" | \
  subfinder | \
  httpx -title -tech-detect -status-code | \
  nuclei -t vulnerabilities/

# Web application testing pipeline
cat domains.txt | \
  httpx -silent | \
  waybackurls | \
  httpx -mc 200 | \
  nuclei
```

### Automation Scripts
```bash
# Mass scanning script
#!/bin/bash
while read domain; do
    echo "Scanning $domain"
    echo $domain | httpx -silent -title -tech-detect >> results.txt
done < domains.txt

# Monitoring script
#!/bin/bash
httpx -l monitored-urls.txt -mc 200 > current_status.txt
diff previous_status.txt current_status.txt || echo "Changes detected!"
```

### Custom Output Processing
```bash
# Extract specific information
httpx -l urls.txt -json | jq '.url, .title, .tech'

# Filter results
httpx -l urls.txt -json | jq 'select(.status_code == 200)'

# Generate reports
httpx -l targets.txt -json | \
  jq -r '"URL: \(.url) | Title: \(.title) | Status: \(.status_code)"'
```

## Configuration and Customization

### Configuration File
```yaml
# ~/.config/httpx/config.yaml
threads: 50
timeout: 10
retries: 2
rate-limit: 100
random-agent: true
include-response-header: true
tech-detect: true
```

### Custom Wordlists
```bash
# Common paths wordlist
/admin
/login
/api
/dashboard
/config
/.env
/.git/config
/backup
```

## Use Cases

### Web Application Security Testing
- Vulnerability assessment
- Content discovery
- Technology fingerprinting
- SSL/TLS analysis

### Bug Bounty and Penetration Testing
- Subdomain probing
- Virtual host discovery
- API endpoint enumeration
- Backup file detection

### DevOps and Monitoring
- Service health checking
- Uptime monitoring
- Infrastructure discovery
- Configuration auditing

### Threat Intelligence
- IOC validation
- Malicious domain analysis
- Phishing site detection
- Campaign tracking

## Installation
High-performance HTTP toolkit for web reconnaissance and security testing.
Essential tool for web application assessment and network reconnaissance.

## Dependencies
None - standalone executable with built-in HTTP client and analysis capabilities.

## Performance Features
- Multi-threaded scanning
- Efficient connection pooling
- Rate limiting and throttling
- Memory-optimized processing
- Fast response analysis

---
*Part of PORTX Portable Development Environment*