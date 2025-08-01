# nuclei - Vulnerability Scanner

[🏠 Back to Wiki Home](../index.md) | [🛡️ Security & Cryptography](../categories/security.md)

---

## Overview

Fast and customizable vulnerability scanner powered by community templates. Modern replacement for traditional vulnerability scanners.

**Version**: 3.2.0  
**Location**: `bin-tools/nuclei/nuclei.exe`  
**Category**: Security & Cryptography

---

## Basic Usage

```bash
# Scan single target
nuclei -u https://target.com

# Scan multiple targets from file
nuclei -l targets.txt

# Scan with specific severity
nuclei -u https://target.com -severity critical,high

# Use specific template category
nuclei -u https://target.com -t cves/

# Output to file
nuclei -u https://target.com -o results.json
```

---

## Template Management

```bash
# Update templates
nuclei -update-templates

# List available templates
nuclei -tl

# Use custom templates
nuclei -u https://target.com -t /path/to/custom-templates/

# Exclude specific templates
nuclei -u https://target.com -exclude-templates dns/
```

---

## Advanced Options

```bash
# Rate limiting (requests per second)
nuclei -u https://target.com -rate-limit 100

# Increase concurrency
nuclei -u https://target.com -c 50

# Include response in output
nuclei -u https://target.com -include-rr

# Debug mode
nuclei -u https://target.com -debug
```

---

## Template Categories

- **cves/** - CVE-based detection templates
- **exposures/** - Exposure detection templates  
- **misconfigurations/** - Configuration issue templates
- **vulnerabilities/** - General vulnerability templates
- **workflows/** - Multi-step scanning workflows

---

## Output Formats

```bash
# JSON output
nuclei -u https://target.com -json -o results.json

# SARIF output
nuclei -u https://target.com -sarif-export results.sarif

# Markdown report
nuclei -u https://target.com -markdown-export report.md
```

---

## Examples

```bash
# Complete web application scan
nuclei -u https://webapp.com -t cves/ -t exposures/ -t misconfigurations/ -severity medium,high,critical

# Bulk scanning with rate limiting
nuclei -l domains.txt -rate-limit 50 -o scan-results.json

# Custom template with variables
nuclei -u https://target.com -t custom.yaml -var domain=target.com
```