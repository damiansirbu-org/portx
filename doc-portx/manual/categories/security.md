# 🛡️ Security & Cryptography (22 tools)

[🏠 Back to Wiki Home](../index.md)

---

## Tools in this category:

- **[age](../tools/age.md)** - Modern file encryption tool
- **[clamav](../tools/clamav.md)** - Open-source antivirus engine (broken)
- **[gpg](../tools/gpg.md)** - GNU Privacy Guard (OpenPGP)
- **[hashdeep](../tools/hashdeep.md)** - Cryptographic hash computation
- **[httpx](../tools/httpx.md)** - HTTP toolkit for security testing
- **[md5sum](../tools/md5sum.md)** - MD5 checksum utility
- **[nuclei](../tools/nuclei.md)** - Vulnerability scanner
- **[openssl](../tools/openssl.md)** - Cryptographic toolkit
- **[osquery](../tools/osquery.md)** - SQL-based system instrumentation
- **[rustscan](../tools/rustscan.md)** - High-speed port scanner
- **[sha256sum](../tools/sha256sum.md)** - SHA-256 checksum utility
- **[ssdeep](../tools/ssdeep.md)** - Fuzzy hashing for similarity analysis
- **[subfinder](../tools/subfinder.md)** - Subdomain enumeration tool
- **[yara](../tools/yara.md)** - Pattern matching engine for malware

### **subfinder** - Subdomain enumeration
Passive subdomain discovery tool for reconnaissance.
- **Sources**: 40+ search engines and services (Shodan, Virustotal, etc.)
- **Features**: Passive reconnaissance, API integration, high-speed discovery
- **Usage**: `subfinder -d target.com -o subdomains.txt -v`
- **Integration**: Perfect for reconnaissance pipelines
- **Location**: `bin-tools/subfinder/subfinder.exe`

### **rustscan** - High-speed port scanner
Modern port scanner built in Rust for speed and reliability.
- **Features**: Extremely fast scanning, service detection, scriptable
- **Usage**: `rustscan -a target.com --ulimit 5000 -- -sV -sC`
- **Performance**: Scans all 65k ports in under 3 seconds
- **Location**: `bin-tools/rustscan/rustscan.exe`

---

## 🦠 Malware Detection & Analysis

### **YARA** - v4.5.4 ⭐ **Pattern Matching**
Pattern matching engine for malware researchers and incident responders.
- **Features**: Rule-based detection, file and memory scanning, extensible
- **Rules**: Custom signature creation with conditions and metadata
- **Usage**: `yara32 rules.yar malware.exe -s -m`
- **Compile**: `yarac rules.yar compiled.yac && yara32 compiled.yac target/`
- **Location**: `bin-tools/yara/yara32.exe`

### **ClamAV** - ❌ **Under Repair**
Open-source antivirus engine for detecting trojans, viruses, and malware.
- **Status**: Currently broken - DLL dependency issues
- **Features**: Real-time scanning, signature updates, email scanning
- **Usage**: `clamscan -r /path/to/scan --log=scan.log`
- **Alternative**: Use Windows Defender CLI or portable antivirus solutions
- **Location**: `bin-tools/clamav/` (disabled)

---

## 🔬 Digital Forensics & Analysis

### **osquery** - v5.18.1 ⭐ **System Intelligence**
SQL-based operating system instrumentation framework.
- **Features**: SQL queries for system information, real-time monitoring
- **Tables**: Processes, network connections, file systems, registry, users
- **Usage**: `osqueryi "SELECT pid,name,cmdline FROM processes WHERE name LIKE '%chrome%'"`
- **Forensics**: `osqueryi "SELECT * FROM hash WHERE path='/suspicious/file'"`
- **Location**: `bin-tools/osquery/osqueryi.exe`

### **hashdeep** - v4.4
Compute and match cryptographic hashes for digital forensics.
- **Features**: Recursive hashing, hash verification, forensic timelines
- **Algorithms**: MD5, SHA-1, SHA-256, Tiger, Whirlpool
- **Usage**: `hashdeep -r -c md5,sha256 /evidence > baseline.txt`
- **Verification**: `hashdeep -a -k baseline.txt /suspect/files`
- **Location**: `bin-tools/hashdeep/hashdeep.exe`

### **ssdeep** - Fuzzy hashing
Context triggered piecewise hashes for file similarity analysis.
- **Features**: Fuzzy matching, malware variant detection, similarity scoring
- **Usage**: `ssdeep -r /malware/samples > fuzzy_hashes.txt`
- **Compare**: `ssdeep -m fuzzy_hashes.txt /new/sample.exe`
- **Location**: `bin-tools/ssdeep/ssdeep.exe`

---

## 🔐 Cryptography & Encryption

### **GPG (GnuPG)** - OpenPGP implementation
Complete cryptographic toolkit for encryption and digital signatures.
- **Features**: RSA/DSA/ECDSA keys, encryption, signatures, key management
- **Usage**: `gpg --gen-key && gpg --armor --export user@example.com`
- **Encrypt**: `gpg --encrypt --recipient user@example.com document.txt`
- **Location**: `bin-tools/gnupg/gpg.exe`

### **age** - Modern encryption
Simple, modern, and secure file encryption tool.
- **Features**: Small keys, no config files, multiple recipients, streaming
- **Usage**: `age-keygen -o key.txt && age -R key.txt.pub file.txt > file.age`
- **Decrypt**: `age --decrypt -i key.txt file.age > decrypted.txt`
- **Location**: `bin-tools/age/age.exe`

### **OpenSSL** - Cryptographic library
Robust, full-featured cryptographic library and toolkit.
- **Features**: SSL/TLS, certificates, encryption, hashing, random data
- **Usage**: `openssl req -new -x509 -keyout private.key -out cert.crt -days 365`
- **Testing**: `openssl s_client -connect target.com:443 -servername target.com`
- **Location**: `usr/bin/openssl.exe`

---

## 🔧 Security Utilities

### **md5sum / sha256sum** - Hash utilities
Calculate and verify cryptographic checksums.
- **Usage**: `sha256sum file.txt > file.sha256`, `sha256sum -c file.sha256`
- **Bulk**: `find /path -type f -exec sha256sum {} \; > hashes.txt`
- **Location**: `usr/bin/` directory

---

## 🚀 Security Assessment Workflows

### Web Application Security Testing
```bash
# 1. Reconnaissance phase
subfinder -d target.com -o subdomains.txt
httpx -l subdomains.txt -title -tech-detect -status-code -o active_hosts.txt

# 2. Vulnerability scanning
nuclei -l active_hosts.txt -t cves/ -severity critical,high -o vulnerabilities.json
nuclei -l active_hosts.txt -t exposures/ -t misconfigurations/ -o exposures.json

# 3. Port scanning and service detection
rustscan -a target.com --ulimit 5000 -- -sV -sC -oN port_scan.txt
nc -zv target.com 80 443 8080 8443
```

### Malware Analysis Pipeline
```bash
# 1. Hash analysis and identification
sha256sum suspicious_file.exe > file_hash.txt
md5sum suspicious_file.exe >> file_hash.txt
ssdeep suspicious_file.exe > fuzzy_hash.txt

# 2. YARA rule detection
yara32 -s -m malware_rules.yar suspicious_file.exe
yara32 -r /path/to/rules/ /suspicious/directory/

# 3. System behavior analysis
osqueryi "SELECT * FROM processes WHERE path LIKE '%suspicious%'"
osqueryi "SELECT * FROM file WHERE path = '/path/to/suspicious_file.exe'"
```

### Digital Forensics Investigation
```bash
# 1. System state capture
osqueryi "SELECT pid,name,path,cmdline,start_time FROM processes" > running_processes.json
osqueryi "SELECT * FROM listening_ports" > network_connections.json
osqueryi "SELECT * FROM users" > user_accounts.json

# 2. File integrity verification
hashdeep -r -c sha256 /critical/system/files > baseline_hashes.txt
hashdeep -a -k baseline_hashes.txt /critical/system/files

# 3. Evidence collection and preservation  
hashdeep -r -c md5,sha256 /evidence/drive > evidence_hashes.txt
ssdeep -r /evidence/drive > evidence_fuzzy.txt
```

---

## 🔧 Advanced Security Configurations

### Nuclei Custom Templates
```yaml
# custom-security-check.yaml
id: custom-security-check
info:
  name: Custom Security Vulnerability Check
  severity: high
  tags: custom,security,webapp

requests:
  - method: GET
    path:
      - "{{BaseURL}}/admin/config"
      - "{{BaseURL}}/.env"
      - "{{BaseURL}}/debug"
      
    matchers-condition: or
    matchers:
      - type: word
        words:
          - "admin panel"
          - "configuration"
          - "database password"
```

### YARA Rule Development
```yara
rule SuspiciousPowerShellActivity {
    meta:
        description = "Detects suspicious PowerShell activity patterns"
        author = "Security Team"
        date = "2024-01-01"
        severity = "high"
        
    strings:
        $ps1 = "IEX" wide ascii
        $ps2 = "Invoke-Expression" wide ascii
        $ps3 = "DownloadString" wide ascii
        $ps4 = "EncodedCommand" wide ascii
        $ps5 = "FromBase64String" wide ascii
        
    condition:
        any of ($ps*) and filesize < 100KB
}
```

### osquery Configuration
```json
{
  "queries": {
    "suspicious_processes": {
      "query": "SELECT pid,name,path,cmdline FROM processes WHERE path NOT LIKE '/usr/%' AND path NOT LIKE '/bin/%' AND path NOT LIKE 'C:\\Windows\\%'",
      "interval": 300,
      "description": "Processes running from unusual locations"
    },
    "network_connections": {
      "query": "SELECT pid,family,protocol,local_address,local_port,remote_address,remote_port FROM process_open_sockets WHERE remote_port != 0",
      "interval": 60,
      "description": "Active network connections by processes"
    },
    "file_changes": {
      "query": "SELECT * FROM file_events WHERE path LIKE '/etc/%' OR path LIKE 'C:\\Windows\\System32\\%'",
      "interval": 300,
      "description": "Monitor critical system file changes"
    }
  }
}
```

---

## ⚠️ Security Best Practices

### Responsible Security Testing
- **Authorization Required**: Always obtain written permission before testing systems
- **Scope Definition**: Clearly define testing boundaries and limitations
- **Rate Limiting**: Use appropriate delays to avoid service disruption
- **Data Handling**: Secure storage and proper disposal of sensitive findings

### Vulnerability Management
- **Regular Updates**: Keep security tools and signatures up to date
- **False Positive Handling**: Manually verify automated findings
- **Risk Assessment**: Prioritize vulnerabilities by severity and exploitability
- **Documentation**: Maintain detailed logs of all security activities

### Incident Response
- **Evidence Preservation**: Use forensic tools to maintain chain of custody
- **Timeline Creation**: Document all actions with timestamps
- **System Isolation**: Contain threats while preserving evidence
- **Communication**: Follow proper escalation and notification procedures

---

## 💡 Pro Tips

1. **Template Updates**: Regularly update Nuclei templates with `nuclei -update-templates`
2. **YARA Performance**: Compile YARA rules for faster scanning: `yarac rules.yar compiled.yac`
3. **osquery Joins**: Combine multiple tables for complex investigations
4. **Hash Databases**: Maintain known-good and known-bad hash databases
5. **Automation**: Script common security workflows for consistency
6. **Log Everything**: Maintain comprehensive audit trails for security activities

---

## 🔗 Related Categories

- **[🌐 Network Tools](network.md)** - Network security and analysis tools
- **[📊 System Monitoring](monitoring.md)** - Security monitoring and alerting
- **[💻 Development Tools](development.md)** - Secure development practices

---

*Use `portx security` to view this category | `portx search <term>` to find specific tools*

**[⬆️ Back to Top](#️-security--cryptography-22-tools)** | **[🏠 Wiki Home](../index.md)**