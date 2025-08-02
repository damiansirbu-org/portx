# ClamAV Package Manual

## Package Information
- **Package Name**: clamav
- **Category**: Security
- **Type**: Antivirus Scanner
- **License**: GPL v2

## Description
ClamAV antivirus scanner - open source antivirus engine for detecting trojans, viruses, malware, and other malicious threats.

Complete ClamAV suite including command-line scanner, daemon, signature management, and monitoring tools.
Designed for email scanning, web scanning, and endpoint security with regular signature database updates.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| clamav.exe | ClamAV antivirus scanner | Main antivirus scanning engine |
| clambc.exe | ClamAV bytecode testing tool | Bytecode signature testing |
| clamconf.exe | ClamAV configuration tool | Configuration management and diagnostics |
| clamd.exe | ClamAV daemon | Background scanning service |
| clamdscan.exe | ClamAV daemon scanner | Client for ClamAV daemon |
| clamdtop.exe | ClamAV daemon monitoring tool | Real-time daemon monitoring |
| clamscan.exe | ClamAV command line scanner | Direct file/directory scanning |
| clamsubmit.exe | ClamAV sample submission tool | Submit samples to ClamAV team |
| freshclam.exe | ClamAV signature database updater | Download latest virus definitions |
| sigtool.exe | ClamAV signature management tool | Signature database management |

## Common Usage Examples

### Basic Scanning
```bash
# Scan a single file
clamscan file.exe

# Scan directory recursively
clamscan -r /path/to/directory

# Scan with verbose output
clamscan -v --log=scan.log /path/to/scan
```

### Database Management
```bash
# Update virus definitions
freshclam

# Check signature database info
sigtool --info /var/lib/clamav/main.cvd

# Create custom signature
sigtool --md5 suspicious_file.exe >> custom.db
```

### Daemon Operations
```bash
# Start ClamAV daemon
clamd

# Scan using daemon (faster for multiple scans)
clamdscan /path/to/file

# Monitor daemon activity
clamdtop
```

### Configuration and Monitoring
```bash
# Display configuration
clamconf

# Test bytecode signatures
clambc --bytecode-statistics

# Submit false positive to ClamAV team
clamsubmit --false-positive suspicious_file.exe
```

### Advanced Scanning Options
```bash
# Scan archives and compressed files
clamscan --scan-archive=yes /path/to/archives

# Scan for potentially unwanted applications
clamscan --detect-pua=yes /path/to/scan

# Move infected files to quarantine
clamscan -r --move=/quarantine /path/to/scan

# Scan email files
clamscan --scan-mail=yes /path/to/mailbox
```

## Configuration
ClamAV can be configured through configuration files:
- `clamd.conf` - Daemon configuration
- `freshclam.conf` - Database update configuration

## Installation
Complete ClamAV antivirus suite for malware detection and system security.
Includes all tools needed for virus scanning, signature management, and daemon operation.

## Dependencies
- Virus signature databases (updated via freshclam)
- Network access for signature updates
- Sufficient disk space for signature databases (~200MB+)

## Notes
- Run `freshclam` first to download virus definitions
- Daemon mode (`clamd` + `clamdscan`) is faster for multiple scans
- Regular signature updates are essential for effective protection
- Some features may require specific configuration

---
*Part of PORTX Portable Development Environment*