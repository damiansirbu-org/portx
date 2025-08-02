# Subfinder Package Manual

## Package Information
- **Package Name**: subfinder
- **Category**: Security Tools
- **Type**: Subdomain Discovery Tool
- **License**: MIT

## Description
Fast passive subdomain discovery tool designed for penetration testing and bug bounty research.

Subfinder leverages multiple data sources including certificate transparency logs, search engines, and DNS databases to discover subdomains.
Features high-speed concurrent processing, extensive source integration, and customizable output formats for reconnaissance workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| subfinder.exe | Subdomain enumeration tool | Discover subdomains for target domains |

## Data Sources and APIs

### Passive DNS Sources
- **Certificate Transparency Logs** (crt.sh, Censys, Facebook CT)
- **DNS Databases** (DNSRepo, DNSTrails, SecurityTrails)
- **Search Engines** (Google, Bing, Yahoo, DuckDuckGo)
- **Web Archives** (Wayback Machine, CommonCrawl)

### Commercial APIs (Optional)
- **VirusTotal** - Comprehensive domain intelligence
- **Shodan** - Internet-connected device search
- **Censys** - Internet-wide scanning data
- **SecurityTrails** - DNS and domain intelligence
- **Chaos** - ProjectDiscovery's subdomain dataset
- **RiskIQ/PassiveTotal** - Threat intelligence platform

### Free Sources
- **AlienVault OTX** - Open threat intelligence
- **HackerTarget** - Free online security tools
- **ThreatCrowd** - Crowdsourced threat intelligence
- **URLScan.io** - Website scanner and analyzer

## Common Usage Examples

### Basic Subdomain Discovery
```bash
# Discover subdomains for single domain
subfinder -d example.com

# Multiple domains from command line
subfinder -d example.com,target.com,test.org

# Read domains from file
subfinder -dL domains.txt

# Specify output file
subfinder -d example.com -o subdomains.txt
```

### Advanced Configuration
```bash
# Use specific sources only
subfinder -d example.com -sources censys,virustotal,securitytrails

# Exclude specific sources
subfinder -d example.com -exclude-sources waybackarchive,commoncrawl

# List all available sources
subfinder -ls

# Maximum concurrent goroutines
subfinder -d example.com -t 50
```

### Output Format Options
```bash
# JSON output format
subfinder -d example.com -json

# Include source information
subfinder -d example.com -v

# Only show subdomains (no banner)
subfinder -d example.com -silent

# Custom output template
subfinder -d example.com -json | jq -r '.host'
```

## API Configuration

### Configuration File Setup
```yaml
# ~/.config/subfinder/config.yaml
# API Keys configuration for enhanced results

binaryedge: 
  - "API_KEY_HERE"
  
censys:
  - "API_ID:API_SECRET"
  
certspotter:
  - "API_KEY_HERE"
  
chaos:
  - "API_KEY_HERE"
  
dnsdb:
  - "API_KEY_HERE"
  
github:
  - "ghp_API_TOKEN_HERE"
  
intelx:
  - "API_KEY_HERE"
  
passivetotal:
  - "USERNAME:API_KEY"
  
securitytrails:
  - "API_KEY_HERE"
  
shodan:
  - "API_KEY_HERE"
  
virustotal:
  - "API_KEY_HERE"
  
zoomeye:
  - "USERNAME:PASSWORD"

# Rate limiting configuration
rate-limit: 3
timeout: 30
```

### Environment Variables
```bash
# Set API keys via environment variables
export CHAOS_API_KEY="your_chaos_api_key"
export SHODAN_API_KEY="your_shodan_api_key"
export VIRUSTOTAL_API_KEY="your_virustotal_api_key"
export SECURITYTRAILS_API_KEY="your_securitytrails_api_key"

# Custom config file location
export SUBFINDER_CONFIG="/path/to/custom/config.yaml"
```

## Advanced Enumeration Techniques

### Recursive Subdomain Discovery
```bash
# Basic recursive enumeration
subfinder -d example.com | subfinder -dL -

# Multi-level recursive discovery
subfinder -d example.com -o level1.txt
cat level1.txt | subfinder -dL - -o level2.txt
cat level2.txt | subfinder -dL - -o level3.txt

# Automated recursive script
#!/bin/bash
DOMAIN=$1
LEVELS=3

echo "$DOMAIN" > domains_level_0.txt

for i in $(seq 1 $LEVELS); do
    prev_level=$((i-1))
    echo "Discovering level $i subdomains..."
    
    cat domains_level_${prev_level}.txt | subfinder -dL - -silent > domains_level_${i}.txt
    
    new_count=$(wc -l < domains_level_${i}.txt)
    echo "Found $new_count new subdomains at level $i"
    
    if [ $new_count -eq 0 ]; then
        echo "No new subdomains found. Stopping at level $i"
        break
    fi
done

# Combine all results
cat domains_level_*.txt | sort -u > all_subdomains.txt
```

### Integration with Other Tools
```bash
# Subfinder + httpx for live subdomain validation
subfinder -d example.com -silent | httpx -silent

# Subfinder + nuclei for vulnerability scanning
subfinder -d example.com -silent | httpx -silent | nuclei -t cves/

# Subfinder + aquatone for visual reconnaissance
subfinder -d example.com | aquatone

# Subfinder + dirsearch for directory enumeration
subfinder -d example.com -silent | httpx -silent -mc 200 | dirsearch -l -
```

### Custom Wordlist Generation
```bash
# Extract unique subdomains patterns
subfinder -d example.com -v | cut -d ' ' -f1 | cut -d '.' -f1 | sort -u > patterns.txt

# Generate permutations
cat patterns.txt | while read subdomain; do
    echo "${subdomain}-dev.example.com"
    echo "${subdomain}-test.example.com"
    echo "${subdomain}-staging.example.com"
    echo "${subdomain}-prod.example.com"
    echo "${subdomain}01.example.com"
    echo "${subdomain}02.example.com"
    echo "old-${subdomain}.example.com"
    echo "new-${subdomain}.example.com"
done | sort -u > permuted_subdomains.txt
```

## Automated Reconnaissance Workflows

### Bug Bounty Reconnaissance Pipeline
```bash
#!/bin/bash
# Comprehensive subdomain discovery for bug bounty

TARGET=$1
OUTPUT_DIR="recon_$(date +%Y%m%d_%H%M%S)"
mkdir -p $OUTPUT_DIR

echo "[+] Starting reconnaissance for $TARGET"

# Phase 1: Subdomain Discovery
echo "[+] Phase 1: Subdomain enumeration"
subfinder -d $TARGET -v -o $OUTPUT_DIR/subdomains_raw.txt

# Phase 2: DNS Resolution
echo "[+] Phase 2: DNS resolution and filtering"
cat $OUTPUT_DIR/subdomains_raw.txt | httpx -silent -timeout 10 > $OUTPUT_DIR/live_subdomains.txt

# Phase 3: Technology Detection
echo "[+] Phase 3: Technology stack detection"
cat $OUTPUT_DIR/live_subdomains.txt | httpx -title -tech-detect -status-code > $OUTPUT_DIR/technology_stack.txt

# Phase 4: Screenshot Capture
echo "[+] Phase 4: Visual reconnaissance"
cat $OUTPUT_DIR/live_subdomains.txt | aquatone -out $OUTPUT_DIR/screenshots

# Phase 5: Vulnerability Scanning
echo "[+] Phase 5: Vulnerability assessment"
cat $OUTPUT_DIR/live_subdomains.txt | nuclei -t cves/ -o $OUTPUT_DIR/vulnerabilities.txt

# Phase 6: Directory Discovery
echo "[+] Phase 6: Directory and file discovery"
cat $OUTPUT_DIR/live_subdomains.txt | head -20 | xargs -I {} dirsearch -u {} -e php,asp,aspx,jsp,html,js,json,xml,txt -o $OUTPUT_DIR/directories.txt

# Generate summary report
echo "[+] Generating summary report"
echo "Reconnaissance Report for $TARGET" > $OUTPUT_DIR/summary.txt
echo "Generated on: $(date)" >> $OUTPUT_DIR/summary.txt
echo "Total subdomains found: $(wc -l < $OUTPUT_DIR/subdomains_raw.txt)" >> $OUTPUT_DIR/summary.txt
echo "Live subdomains: $(wc -l < $OUTPUT_DIR/live_subdomains.txt)" >> $OUTPUT_DIR/summary.txt
echo "Potential vulnerabilities: $(wc -l < $OUTPUT_DIR/vulnerabilities.txt)" >> $OUTPUT_DIR/summary.txt

echo "[+] Reconnaissance complete. Results saved in $OUTPUT_DIR/"
```

### Continuous Monitoring Setup
```bash
#!/bin/bash
# Continuous subdomain monitoring script

DOMAIN=$1
BASELINE_FILE="baseline_${DOMAIN}.txt"
NEW_SUBDOMAINS_FILE="new_subdomains_$(date +%Y%m%d).txt"

# Initial baseline creation
if [ ! -f $BASELINE_FILE ]; then
    echo "[+] Creating baseline for $DOMAIN"
    subfinder -d $DOMAIN -silent > $BASELINE_FILE
    echo "[+] Baseline created with $(wc -l < $BASELINE_FILE) subdomains"
    exit 0
fi

# Daily monitoring
echo "[+] Running daily subdomain monitoring for $DOMAIN"
subfinder -d $DOMAIN -silent > current_scan.txt

# Find new subdomains
comm -13 <(sort $BASELINE_FILE) <(sort current_scan.txt) > $NEW_SUBDOMAINS_FILE

if [ -s $NEW_SUBDOMAINS_FILE ]; then
    echo "[!] New subdomains discovered:"
    cat $NEW_SUBDOMAINS_FILE
    
    # Validate new subdomains
    cat $NEW_SUBDOMAINS_FILE | httpx -silent > validated_new.txt
    
    if [ -s validated_new.txt ]; then
        echo "[!] Live new subdomains found:"
        cat validated_new.txt
        
        # Optional: Send alert notification
        # curl -X POST "https://your-webhook-url" -d "New subdomains found for $DOMAIN: $(cat validated_new.txt | tr '\n' ' ')"
    fi
    
    # Update baseline
    cat $BASELINE_FILE current_scan.txt | sort -u > new_baseline.txt
    mv new_baseline.txt $BASELINE_FILE
    
else
    echo "[+] No new subdomains found for $DOMAIN"
fi

# Cleanup
rm -f current_scan.txt validated_new.txt
```

## Data Analysis and Filtering

### Subdomain Pattern Analysis
```bash
# Analyze subdomain patterns
subfinder -d example.com -silent | cut -d '.' -f1 | sort | uniq -c | sort -nr

# Find interesting subdomains
subfinder -d example.com -silent | grep -E "(dev|test|staging|admin|api|mail|ftp|vpn|internal)"

# Extract unique TLDs and second-level domains
subfinder -d example.com -silent | rev | cut -d '.' -f1-2 | rev | sort -u

# Find subdomains with interesting keywords
subfinder -d example.com -silent | grep -E "(admin|panel|dashboard|login|auth|api|internal|staging|dev|test|backup|old|new|beta|demo)"
```

### Statistical Analysis
```bash
# Subdomain length distribution
subfinder -d example.com -silent | awk '{print length($0)}' | sort -n | uniq -c

# Character frequency analysis
subfinder -d example.com -silent | grep -o . | sort | uniq -c | sort -nr

# Subdomain depth analysis
subfinder -d example.com -silent | awk -F'.' '{print NF-1}' | sort -n | uniq -c
```

### Output Processing and Integration
```bash
# Convert to different formats
subfinder -d example.com -json | jq -r '.host' > subdomains.txt
subfinder -d example.com -json | jq -r '.source' | sort | uniq -c | sort -nr

# Generate CSV report
echo "subdomain,source,timestamp" > report.csv
subfinder -d example.com -json | jq -r '[.host, .source, now] | @csv' >> report.csv

# Integration with databases
subfinder -d example.com -json | while read line; do
    subdomain=$(echo $line | jq -r '.host')
    source=$(echo $line | jq -r '.source')
    echo "INSERT INTO subdomains (domain, subdomain, source, discovered_date) VALUES ('example.com', '$subdomain', '$source', NOW());" >> insert_queries.sql
done
```

## Performance Optimization

### High-Speed Configuration
```bash
# Maximum performance settings
subfinder -d example.com -t 100 -timeout 5 -silent

# Bulk domain processing
subfinder -dL domains.txt -t 50 -o results/ -silent

# Memory-efficient processing for large datasets
split -l 100 large_domains.txt domain_chunk_
for chunk in domain_chunk_*; do
    subfinder -dL $chunk -o results_$(basename $chunk).txt -silent
done
cat results_*.txt | sort -u > all_results.txt
```

### Resource Management
```yaml
# config.yaml - Optimized for speed
rate-limit: 1
timeout: 10
concurrent: 25
retries: 2

# Disable slow sources for speed
exclude-sources:
  - waybackarchive
  - commoncrawl
  - archiveorg
```

## Security and Operational Considerations

### Rate Limiting and Ethics
```bash
# Respectful enumeration with delays
subfinder -d example.com -rate-limit 5

# Custom delays between requests
for domain in $(cat targets.txt); do
    subfinder -d $domain -silent
    sleep 2  # 2-second delay between domains
done
```

### Data Privacy and Compliance
```bash
# Anonymized logging
subfinder -d example.com -silent | sha256sum | cut -d' ' -f1 > domain_hash.txt

# Secure cleanup
subfinder -d example.com -o /tmp/results.txt
# Process results
shred -vfz -n 3 /tmp/results.txt
```

## Use Cases

### Penetration Testing
- Attack surface discovery and mapping
- Subdomain takeover vulnerability identification
- Network reconnaissance and enumeration
- Security assessment scope expansion

### Bug Bounty Hunting
- Comprehensive target reconnaissance
- Continuous monitoring for new assets
- Subdomain pattern analysis and prediction
- Integration with vulnerability scanning workflows

### Digital Asset Management
- Corporate asset inventory and discovery
- Domain portfolio management and monitoring
- Brand protection and monitoring
- Compliance and governance reporting

### Threat Intelligence
- Adversary infrastructure mapping
- Domain reputation analysis and monitoring
- Phishing and fraud detection
- Incident response and forensic investigation

## Installation
High-performance subdomain discovery tool for reconnaissance and security research.
Essential for penetration testing, bug bounty research, and digital asset management.

## Dependencies
- Internet connectivity for API access and data source queries
- Optional API keys for enhanced results and higher rate limits
- Sufficient disk space for large result sets
- Network bandwidth for concurrent enumeration

## Performance Features
- Concurrent processing with configurable goroutines
- Multiple data source integration and correlation
- Rate limiting and timeout controls
- Memory-efficient processing for large datasets
- JSON and text output formats

---
*Part of PORTX Portable Development Environment*