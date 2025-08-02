# RustScan Package Manual

## Package Information
- **Package Name**: rustscan
- **Category**: Security Tools
- **Type**: Network Port Scanner
- **License**: GPL v3

## Description
Ultra-fast network port scanner with modern output and scriptable features.

High-performance port scanner written in Rust, designed to be faster than Nmap for port discovery.
Features modern output formatting, automatic Nmap integration, and extensible scripting capabilities.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| rustscan.exe | Ultra-fast port scanner | Scan network ports with high performance |

## Common Usage Examples

### Basic Port Scanning
```bash
# Scan single host
rustscan -a 192.168.1.1

# Scan multiple hosts
rustscan -a 192.168.1.1,192.168.1.2,192.168.1.3

# Scan IP range
rustscan -a 192.168.1.0/24

# Scan with hostname
rustscan -a example.com
```

### Port Range Configuration
```bash
# Scan specific ports
rustscan -a 192.168.1.1 -p 22,80,443

# Scan port range
rustscan -a 192.168.1.1 -p 1-1000

# Scan all ports
rustscan -a 192.168.1.1 -p-

# Scan top ports
rustscan -a 192.168.1.1 --top
```

### Performance Tuning
```bash
# Adjust batch size (default 4500)
rustscan -a 192.168.1.1 -b 1000

# Set timeout (milliseconds)
rustscan -a 192.168.1.1 -t 2000

# Control number of tries
rustscan -a 192.168.1.1 --tries 3

# Ultra-fast scan (maximum performance)
rustscan -a 192.168.1.1 --ulimit 65000
```

## Advanced Scanning Options

### Output Formats
```bash
# JSON output
rustscan -a 192.168.1.1 --output json

# Greppable output
rustscan -a 192.168.1.1 -g

# No Nmap output
rustscan -a 192.168.1.1 -n

# Accessible output
rustscan -a 192.168.1.1 --accessible
```

### Network Configuration
```bash
# Scan through proxy
rustscan -a target.com --proxy 127.0.0.1:8080

# IPv6 scanning
rustscan -a ::1

# Custom interface
rustscan -a 192.168.1.1 --interface eth0

# Scan from file
rustscan --file targets.txt
```

### Integration with Nmap
```bash
# Automatic Nmap integration (default)
rustscan -a 192.168.1.1

# Custom Nmap arguments
rustscan -a 192.168.1.1 -- -sV -sC

# Disable Nmap
rustscan -a 192.168.1.1 -n

# Script scan after port discovery
rustscan -a 192.168.1.1 -- -A
```

## Scripting and Automation

### Custom Scripts
```bash
# Python script integration
rustscan -a 192.168.1.1 --scripts python-script.py

# Bash script execution
rustscan -a 192.168.1.1 --scripts custom-scan.sh

# Multiple scripts
rustscan -a 192.168.1.1 --scripts script1.py,script2.sh
```

### Example Custom Script
```python
#!/usr/bin/env python3
# custom-scan.py

import sys
import socket

def scan_port(host, port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((host, port))
        sock.close()
        
        if result == 0:
            print(f"[+] Port {port} is open on {host}")
            # Custom logic for open ports
            banner_grab(host, port)
        
    except Exception as e:
        print(f"[-] Error scanning {host}:{port} - {e}")

def banner_grab(host, port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        sock.connect((host, port))
        
        if port == 80:
            sock.send(b"GET / HTTP/1.1\r\nHost: " + host.encode() + b"\r\n\r\n")
        
        banner = sock.recv(1024).decode('utf-8', errors='ignore')
        print(f"[+] Banner from {host}:{port} - {banner[:100]}...")
        sock.close()
        
    except Exception as e:
        print(f"[-] Banner grab failed for {host}:{port}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 custom-scan.py <host> <port>")
        sys.exit(1)
    
    host = sys.argv[1]
    port = int(sys.argv[2])
    scan_port(host, port)
```

## Configuration and Customization

### Configuration File (~/.rustscan.toml)
```toml
# RustScan configuration file

[default]
# Default batch size
batch_size = 4500

# Default timeout in milliseconds
timeout = 1500

# Default number of tries
tries = 1

# Default ports to scan
ports = "1-65535"

# Default output format
output = "normal"

[scanning]
# Ultra-fast mode settings
ulimit = 5000

# Adaptive timing
adaptive = true

# Greppable output by default
greppable = false

[nmap]
# Always run Nmap after RustScan
enabled = true

# Default Nmap arguments
arguments = "-sV -sC"

# Custom Nmap path
path = "/usr/bin/nmap"
```

### Environment Variables
```bash
# Configuration via environment
export RUSTSCAN_BATCH_SIZE=3000
export RUSTSCAN_TIMEOUT=2000
export RUSTSCAN_ULIMIT=10000

# Disable Nmap integration
export RUSTSCAN_NO_NMAP=true

# Custom config file
export RUSTSCAN_CONFIG_FILE="/path/to/custom.toml"
```

## Performance Optimization

### High-Performance Scanning
```bash
# Maximum performance scan
rustscan -a target.com \
  --ulimit 65000 \
  --batch-size 10000 \
  --timeout 500 \
  --tries 1

# Network-optimized scan
rustscan -a 192.168.1.0/24 \
  --batch-size 5000 \
  --timeout 1000 \
  --top

# Stealth scan (slower but quieter)
rustscan -a target.com \
  --batch-size 100 \
  --timeout 3000 \
  --tries 2
```

### Resource Management
```bash
# Limit system resources
ulimit -n 65000  # Increase file descriptor limit
rustscan -a target.com --ulimit 60000

# Memory-efficient scanning
rustscan -a large-network.com \
  --batch-size 1000 \
  --adaptive

# CPU-optimized scanning
rustscan -a target.com \
  --threads $(nproc) \
  --batch-size 5000
```

## Network Discovery Workflows

### Network Reconnaissance
```bash
# Phase 1: Fast port discovery
rustscan -a 192.168.1.0/24 -p 22,80,443,8080 -g > open_ports.txt

# Phase 2: Detailed scanning of discovered hosts
while read line; do
  host=$(echo $line | cut -d':' -f1)
  rustscan -a $host -- -sV -sC -O
done < open_ports.txt

# Phase 3: Vulnerability scanning
rustscan -a target.com -- --script vuln
```

### Service Discovery
```bash
# Web service discovery
rustscan -a target.com -p 80,443,8080,8443,3000,8000 -- -sV

# Database service discovery
rustscan -a target.com -p 1433,3306,5432,27017,6379 -- -sV

# Common service ports
rustscan -a target.com -p 21,22,23,25,53,80,110,443,993,995 -- -sV
```

### Large-Scale Scanning
```bash
# Internet-wide scanning (be responsible!)
rustscan -a 0.0.0.0/0 -p 22 --batch-size 10000 --timeout 100

# Organization scanning
rustscan --file company-ips.txt --top

# Subnet enumeration
for subnet in 192.168.{1..254}.0/24; do
  rustscan -a $subnet -p 22,80,443 -g >> network_discovery.txt
done
```

## Integration Examples

### Security Testing Pipeline
```bash
#!/bin/bash
# Security assessment workflow

TARGET=$1
OUTPUT_DIR="scan_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p $OUTPUT_DIR

echo "[+] Starting RustScan discovery on $TARGET"

# Fast port discovery
rustscan -a $TARGET -g > $OUTPUT_DIR/open_ports.txt

# Extract unique hosts with open ports
cat $OUTPUT_DIR/open_ports.txt | cut -d':' -f1 | sort -u > $OUTPUT_DIR/live_hosts.txt

# Detailed Nmap scanning
while read host; do
  echo "[+] Detailed scan of $host"
  rustscan -a $host -- -sV -sC -O -oA $OUTPUT_DIR/nmap_$host
done < $OUTPUT_DIR/live_hosts.txt

echo "[+] Scans completed. Results in $OUTPUT_DIR/"
```

### CI/CD Security Checks
```bash
# GitLab CI/CD pipeline
stages:
  - security-scan

network-scan:
  stage: security-scan
  script:
    - rustscan -a $DEPLOYMENT_TARGET -p 80,443 -n
    - if [ $? -eq 0 ]; then echo "Expected ports are open"; else exit 1; fi
  only:
    - deploy
```

### Monitoring and Alerting
```bash
# Continuous monitoring script
#!/bin/bash

TARGETS="critical-server1.com critical-server2.com"
EXPECTED_PORTS="22,80,443"

for target in $TARGETS; do
  echo "Scanning $target..."
  result=$(rustscan -a $target -p $EXPECTED_PORTS -n -g)
  
  if [ -z "$result" ]; then
    echo "ALERT: No expected ports open on $target"
    # Send alert notification
  else
    echo "OK: Expected ports open on $target"
  fi
done
```

## Output Analysis

### JSON Output Processing
```bash
# Generate JSON output
rustscan -a target.com --output json > scan_results.json

# Process with jq
jq '.ips[].ports[] | select(.port == 80)' scan_results.json

# Extract all open ports
jq -r '.ips[] | .ip + ":" + (.ports[] | tostring)' scan_results.json

# Summary statistics
jq '.ips | length' scan_results.json  # Number of hosts
jq '[.ips[].ports[]] | length' scan_results.json  # Total open ports
```

### Greppable Output Processing
```bash
# Extract specific ports
rustscan -a network.com -g | grep ":80"

# Count open ports per host
rustscan -a network.com -g | cut -d':' -f1 | sort | uniq -c

# Find hosts with SSH open
rustscan -a network.com -g | grep ":22" | cut -d':' -f1
```

## Use Cases

### Penetration Testing
- Fast network reconnaissance
- Service discovery and enumeration
- Vulnerability assessment preparation
- Large-scale network mapping

### System Administration
- Network inventory and monitoring
- Service availability checking
- Security compliance validation
- Infrastructure documentation

### DevOps and Security
- CI/CD security gates
- Deployment validation
- Infrastructure testing
- Continuous security monitoring

### Bug Bounty and Research
- Attack surface discovery
- Subdomain enumeration integration
- Large-scale reconnaissance
- Automation and scripting

## Installation
Ultra-fast network port scanner with modern features and Nmap integration.
Essential tool for network reconnaissance and security testing.

## Dependencies
- Nmap (optional, for detailed scanning)
- Sufficient system file descriptors (ulimit)
- Network connectivity to target systems
- Appropriate permissions for network scanning

## Performance Features
- Written in Rust for maximum performance
- Asynchronous scanning capabilities
- Adaptive batch sizing
- Efficient memory usage
- Cross-platform compatibility

---
*Part of PORTX Portable Development Environment*