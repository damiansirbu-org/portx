# YARA Package Manual

## Package Information
- **Package Name**: yara
- **Category**: Security Tools
- **Type**: Malware Identification and Classification
- **License**: BSD 3-Clause

## Description
Pattern matching engine designed for malware researchers to identify and classify malware samples.

YARA provides a powerful rule-based approach to creating descriptions of malware families based on textual or binary patterns.
Enables creation of signatures for malware detection, incident response, and threat hunting across files, processes, and memory.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| yara32.exe | YARA pattern matching engine | Scan files and processes with YARA rules |
| yarac32.exe | YARA rule compiler | Compile YARA rules for optimized performance |

## YARA Rule Structure

### Basic Rule Syntax
```yara
rule RuleName
{
    meta:
        description = "Rule description"
        author = "Analyst name"
        date = "2024-01-01"
        version = "1.0"
        
    strings:
        $text_string = "suspicious text" nocase
        $hex_string = { 48 65 6C 6C 6F }
        $regex_pattern = /[a-zA-Z0-9]{32}/ ascii wide
        
    condition:
        $text_string or $hex_string or $regex_pattern
}
```

### Advanced Rule Components
```yara
rule AdvancedMalwareDetection
{
    meta:
        description = "Detects advanced malware techniques"
        author = "Security Team"
        reference = "https://attack.mitre.org/techniques/T1055/"
        severity = "high"
        tlp = "white"
        
    strings:
        // API function names
        $api1 = "VirtualAllocEx" ascii
        $api2 = "WriteProcessMemory" ascii
        $api3 = "CreateRemoteThread" ascii
        
        // Hex patterns for specific malware family
        $hex1 = { 4D 5A 90 00 03 00 00 00 04 00 00 00 FF FF }
        $hex2 = { E8 ?? ?? ?? ?? 58 05 ?? ?? ?? ?? 50 }
        
        // Regular expressions for artifacts
        $regex1 = /[A-Za-z0-9+\/]{20,}={0,2}/ ascii  // Base64
        $regex2 = /[0-9a-fA-F]{32}/ ascii            // MD5 hash
        
    condition:
        // File size constraints
        filesize < 10MB and
        
        // PE file validation
        uint16(0) == 0x5A4D and
        
        // String combinations
        (2 of ($api*)) or
        (all of ($hex*)) or
        (#regex1 > 5 and #regex2 > 2)
}
```

## Common Usage Examples

### Basic File Scanning
```bash
# Scan single file with rule
yara32 malware.yar suspicious_file.exe

# Scan directory recursively
yara32 -r malware_rules/ /path/to/scan/

# Scan with multiple rule files
yara32 rule1.yar rule2.yar rule3.yar target_file.exe

# Fast mode scanning (less thorough but faster)
yara32 -f rules.yar large_file.bin
```

### Advanced Scanning Options
```bash
# Detailed output with metadata
yara32 -m rules.yar sample.exe

# Show string matches
yara32 -s rules.yar sample.exe

# Set maximum string length
yara32 -l 1000 rules.yar sample.exe

# Custom timeout (seconds)
yara32 -a 30 rules.yar sample.exe

# Scan only specific file types
yara32 -r rules.yar /path/to/scan/ --include="*.exe" --include="*.dll"
```

### Rule Compilation
```bash
# Compile rules for better performance
yarac32 rules.yar compiled_rules.yarc

# Compile multiple rules into single file
yarac32 rule1.yar rule2.yar rule3.yar compiled.yarc

# Use compiled rules for scanning
yara32 compiled_rules.yarc target_file.exe
```

## Malware Detection Rule Examples

### PE File Analysis Rules
```yara
rule Suspicious_PE_Characteristics
{
    meta:
        description = "Detects PE files with suspicious characteristics"
        author = "Malware Analyst"
        
    condition:
        // PE file validation
        uint16(0) == 0x5A4D and
        uint32(uint32(0x3C)) == 0x00004550 and
        
        // Suspicious section characteristics
        for any section in pe.sections : (
            section.characteristics & pe.SECTION_CNT_CODE and
            section.characteristics & pe.SECTION_MEM_WRITE and
            section.characteristics & pe.SECTION_MEM_EXECUTE
        ) or
        
        // High entropy (possible packing/encryption)
        math.entropy(0, filesize) >= 7.0 or
        
        // Unusual entry point
        pe.entry_point < pe.sections[0].raw_data_offset
}

rule Packed_Executable
{
    meta:
        description = "Detects packed or compressed executables"
        
    strings:
        $upx = "UPX!" ascii
        $aspack = "aPSPack" ascii
        $fsg = "FSG!" ascii
        $mew = "MEW " ascii
        
    condition:
        uint16(0) == 0x5A4D and
        (
            any of them or
            math.entropy(0, filesize) > 7.5 or
            pe.number_of_sections < 3 or
            pe.sections[0].raw_data_size == 0
        )
}
```

### Network and Communication Rules
```yara
rule Suspicious_Network_Activity
{
    meta:
        description = "Detects suspicious network communication patterns"
        
    strings:
        // C2 domains and IPs
        $domain1 = "malware-c2.evil.com" ascii wide
        $domain2 = "185.243.115.84" ascii
        
        // User agents
        $ua1 = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" ascii
        $ua2 = "malware-bot/1.0" ascii
        
        // HTTP headers
        $header1 = "X-Session-Token:" ascii
        $header2 = "X-Bot-ID:" ascii
        
        // Base64 encoded payloads
        $b64_1 = /[A-Za-z0-9+\/]{100,}={0,2}/ ascii
        
    condition:
        any of ($domain*) or
        any of ($ua*) or
        (any of ($header*) and $b64_1)
}

rule Cryptocurrency_Mining
{
    meta:
        description = "Detects cryptocurrency mining malware"
        
    strings:
        // Mining pool addresses
        $pool1 = "stratum+tcp://" ascii
        $pool2 = "mining.pool.com" ascii
        
        // Wallet addresses
        $btc = /[13][a-km-zA-HJ-NP-Z1-9]{25,34}/ ascii
        $eth = /0x[a-fA-F0-9]{40}/ ascii
        $xmr = /4[0-9AB][1-9A-HJ-NP-Za-km-z]{93}/ ascii
        
        // Mining software strings
        $miner1 = "xmrig" ascii nocase
        $miner2 = "ccminer" ascii nocase
        $miner3 = "claymore" ascii nocase
        
    condition:
        any of ($pool*) or
        any of ($btc, $eth, $xmr) or
        any of ($miner*)
}
```

### APT and Targeted Attack Rules
```yara
rule APT_Persistence_Mechanism
{
    meta:
        description = "Detects APT-style persistence mechanisms"
        reference = "MITRE ATT&CK T1547"
        
    strings:
        // Registry persistence
        $reg1 = "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run" ascii wide
        $reg2 = "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run" ascii wide
        $reg3 = "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce" ascii wide
        
        // Service persistence
        $svc1 = "CreateServiceA" ascii
        $svc2 = "CreateServiceW" ascii
        $svc3 = "ChangeServiceConfigA" ascii
        
        // Scheduled task persistence
        $task1 = "schtasks.exe" ascii wide
        $task2 = "SchTasks" ascii wide
        $task3 = "TaskScheduler" ascii wide
        
        // WMI persistence
        $wmi1 = "__EventFilter" ascii wide
        $wmi2 = "__EventConsumer" ascii wide
        $wmi3 = "__FilterToConsumerBinding" ascii wide
        
    condition:
        uint16(0) == 0x5A4D and
        (
            2 of ($reg*) or
            2 of ($svc*) or
            2 of ($task*) or
            all of ($wmi*)
        )
}

rule Data_Exfiltration_Tools
{
    meta:
        description = "Detects tools commonly used for data exfiltration"
        
    strings:
        // Archive creation
        $zip1 = "CreateZipFile" ascii
        $zip2 = "AddFileToZip" ascii
        $rar1 = "Rar.exe" ascii wide
        
        // File transfer protocols
        $ftp1 = "FtpPutFile" ascii
        $ftp2 = "InternetConnect" ascii
        $http1 = "WinHttpSendRequest" ascii
        $http2 = "HttpSendRequest" ascii
        
        // Cloud storage APIs
        $cloud1 = "api.dropbox.com" ascii
        $cloud2 = "drive.google.com" ascii
        $cloud3 = "onedrive.live.com" ascii
        
        // Encryption before exfiltration
        $crypt1 = "CryptEncrypt" ascii
        $crypt2 = "BCryptEncrypt" ascii
        
    condition:
        uint16(0) == 0x5A4D and
        (
            any of ($zip*, $rar*) and
            (any of ($ftp*, $http*) or any of ($cloud*))
        ) or
        (any of ($crypt*) and any of ($ftp*, $http*, $cloud*))
}
```

## Advanced YARA Features

### Using Modules
```yara
import "pe"
import "math"
import "hash"

rule Advanced_PE_Analysis
{
    meta:
        description = "Advanced PE file analysis using modules"
        
    condition:
        // PE module usage
        pe.is_pe and
        pe.machine == pe.MACHINE_AMD64 and
        pe.number_of_sections > 3 and
        
        // Math module for entropy
        math.entropy(0, filesize) > 6.0 and
        
        // Hash module
        hash.md5(0, filesize) == "d41d8cd98f00b204e9800998ecf8427e"
}

import "elf"

rule Linux_Malware_Detection
{
    meta:
        description = "Detects suspicious ELF files"
        
    condition:
        elf.type == elf.ET_EXEC and
        elf.machine == elf.EM_X86_64 and
        elf.entry_point < 0x8048000
}
```

### Complex String Patterns
```yara
rule Complex_String_Patterns
{
    meta:
        description = "Demonstrates complex string pattern matching"
        
    strings:
        // Case-insensitive strings
        $text1 = "malware" nocase
        
        // Wide character strings (Unicode)
        $text2 = "suspicious" wide
        
        // ASCII and wide combined
        $text3 = "payload" ascii wide
        
        // Hex patterns with wildcards
        $hex1 = { 4D 5A ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 50 45 }
        
        // Hex patterns with jumps
        $hex2 = { 48 8B 05 [4] 48 8B 00 }
        
        // Regular expressions
        $regex1 = /https?:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/ ascii
        
        // XOR encoded strings
        $xor = "malware" xor
        
    condition:
        any of them
}
```

### Memory Scanning Rules
```yara
rule Memory_Injection_Detection
{
    meta:
        description = "Detects process injection techniques in memory"
        
    strings:
        // Process hollowing
        $hollow1 = { 48 8B ?? ?? ?? ?? ?? 48 89 ?? ?? }
        $hollow2 = "NtUnmapViewOfSection" ascii
        
        // DLL injection
        $dll1 = "LoadLibraryA" ascii
        $dll2 = "GetProcAddress" ascii
        $dll3 = "VirtualAllocEx" ascii
        
        // Reflective DLL loading
        $reflective = { 4D 5A E8 ?? ?? ?? ?? 5? 89 ?? }
        
    condition:
        // Process memory scanning
        ($hollow1 and $hollow2) or
        (all of ($dll*)) or
        $reflective
}
```

## Automated Scanning Workflows

### Bulk File Analysis
```bash
#!/bin/bash
# Bulk malware analysis with YARA

RULES_DIR="/path/to/yara/rules"
SAMPLES_DIR="/path/to/samples"
OUTPUT_DIR="/path/to/results"

mkdir -p $OUTPUT_DIR

echo "Starting bulk YARA analysis..."

# Compile all rules
echo "Compiling YARA rules..."
yarac32 $RULES_DIR/*.yar $OUTPUT_DIR/compiled_rules.yarc

# Scan all samples
echo "Scanning samples..."
find $SAMPLES_DIR -type f | while read sample; do
    filename=$(basename "$sample")
    echo "Scanning: $filename"
    
    # Scan with compiled rules
    yara32 -s -m $OUTPUT_DIR/compiled_rules.yarc "$sample" > "$OUTPUT_DIR/${filename}.result" 2>&1
    
    # Check if any matches found
    if [ -s "$OUTPUT_DIR/${filename}.result" ]; then
        echo "MATCH: $filename" >> $OUTPUT_DIR/summary.txt
        cp "$sample" "$OUTPUT_DIR/malware_samples/"
    else
        echo "CLEAN: $filename" >> $OUTPUT_DIR/summary.txt
    fi
done

echo "Analysis complete. Results in $OUTPUT_DIR/"
```

### Real-Time Monitoring
```powershell
# PowerShell script for real-time YARA monitoring
param(
    [string]$WatchPath = "C:\Downloads",
    [string]$RulesPath = "C:\YARA\rules\malware.yarc",
    [int]$ScanInterval = 30
)

# Initialize file system watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $WatchPath
$watcher.Filter = "*.*"
$watcher.EnableRaisingEvents = $true

# Define event handler
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    
    if ($changeType -eq "Created") {
        Write-Host "New file detected: $name"
        
        # Wait for file to be completely written
        Start-Sleep -Seconds 2
        
        # Scan with YARA
        $result = & "C:\YARA\yara32.exe" -s $RulesPath $path 2>&1
        
        if ($result) {
            Write-Host "MALWARE DETECTED: $name" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            
            # Move to quarantine
            $quarantinePath = "C:\Quarantine\$(Get-Date -Format 'yyyyMMdd')"
            New-Item -ItemType Directory -Path $quarantinePath -Force
            Move-Item -Path $path -Destination $quarantinePath -Force
            
            # Log incident
            $logEntry = "$(Get-Date): MALWARE - $name - $result"
            Add-Content -Path "C:\Logs\yara_detections.log" -Value $logEntry
            
            # Send alert (customize as needed)
            # Send-MailMessage -To "security@company.com" -Subject "Malware Detected" -Body $logEntry
        } else {
            Write-Host "File clean: $name" -ForegroundColor Green
        }
    }
}

# Register event handler
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action

Write-Host "YARA monitoring started for: $WatchPath"
Write-Host "Press Ctrl+C to stop monitoring"

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds $ScanInterval
    }
} finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
}
```

### Integration with Incident Response
```bash
#!/bin/bash
# YARA-based incident response script

INCIDENT_ID=$1
EVIDENCE_PATH=$2
RULES_PATH="/opt/yara/rules"
REPORT_PATH="/tmp/incident_${INCIDENT_ID}_yara_report.txt"

echo "YARA Analysis Report - Incident $INCIDENT_ID" > $REPORT_PATH
echo "Timestamp: $(date)" >> $REPORT_PATH
echo "Evidence Path: $EVIDENCE_PATH" >> $REPORT_PATH
echo "=======================================" >> $REPORT_PATH

# Scan with different rule categories
echo "Scanning with APT rules..." >> $REPORT_PATH
yara32 -r -s $RULES_PATH/apt/ $EVIDENCE_PATH >> $REPORT_PATH 2>&1

echo "Scanning with banking trojan rules..." >> $REPORT_PATH
yara32 -r -s $RULES_PATH/banking/ $EVIDENCE_PATH >> $REPORT_PATH 2>&1

echo "Scanning with ransomware rules..." >> $REPORT_PATH
yara32 -r -s $RULES_PATH/ransomware/ $EVIDENCE_PATH >> $REPORT_PATH 2>&1

echo "Scanning with generic malware rules..." >> $REPORT_PATH
yara32 -r -s $RULES_PATH/generic/ $EVIDENCE_PATH >> $REPORT_PATH 2>&1

# Generate summary
echo "=======================================" >> $REPORT_PATH
echo "Analysis Summary:" >> $REPORT_PATH
grep -c "rule" $REPORT_PATH | xargs echo "Total matches:" >> $REPORT_PATH

# Extract IOCs
echo "Extracted IOCs:" >> $REPORT_PATH
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $REPORT_PATH | sort -u >> $REPORT_PATH
grep -oE '[a-fA-F0-9]{32}' $REPORT_PATH | sort -u >> $REPORT_PATH

echo "YARA analysis complete. Report saved to: $REPORT_PATH"
```

## Rule Development and Testing

### Rule Testing Framework
```bash
#!/bin/bash
# YARA rule testing framework

RULE_FILE=$1
TEST_SAMPLES_DIR="/path/to/test/samples"
RESULTS_DIR="/tmp/yara_test_results"

mkdir -p $RESULTS_DIR

echo "Testing YARA rule: $RULE_FILE"

# Test against known malware samples (should match)
echo "Testing against malware samples..."
for sample in $TEST_SAMPLES_DIR/malware/*; do
    result=$(yara32 $RULE_FILE "$sample" 2>/dev/null)
    if [ -n "$result" ]; then
        echo "✓ PASS: $(basename $sample) - detected as expected"
    else
        echo "✗ FAIL: $(basename $sample) - not detected (false negative)"
    fi
done

# Test against clean samples (should not match)
echo "Testing against clean samples..."
for sample in $TEST_SAMPLES_DIR/clean/*; do
    result=$(yara32 $RULE_FILE "$sample" 2>/dev/null)
    if [ -z "$result" ]; then
        echo "✓ PASS: $(basename $sample) - correctly identified as clean"
    else
        echo "✗ FAIL: $(basename $sample) - false positive detected"
    fi
done

echo "Rule testing complete."
```

### Rule Performance Analysis
```bash
# Performance benchmarking for YARA rules
echo "Performance analysis for YARA rules"

# Time rule compilation
echo "Rule compilation time:"
time yarac32 rules/*.yar compiled.yarc

# Time scanning with uncompiled rules
echo "Uncompiled rules scanning time:"
time yara32 rules/malware.yar /path/to/samples/*

# Time scanning with compiled rules
echo "Compiled rules scanning time:"
time yara32 compiled.yarc /path/to/samples/*

# Memory usage analysis
echo "Memory usage analysis:"
/usr/bin/time -v yara32 compiled.yarc /path/to/large/sample.bin
```

## Use Cases

### Malware Analysis and Classification
- Automated malware family identification and classification
- IOC extraction and threat intelligence generation
- Reverse engineering assistance and pattern recognition
- Malware sample clustering and similarity analysis

### Incident Response and Forensics
- Host-based compromise assessment and investigation
- Memory dump analysis and artifact identification
- Network packet inspection and payload analysis
- Timeline reconstruction and evidence correlation

### Threat Hunting and Detection
- Proactive threat hunting across enterprise environments
- Custom detection rule development and deployment
- False positive reduction and signature tuning
- Advanced persistent threat (APT) detection and tracking

### Security Operations and Monitoring
- Real-time file and process monitoring
- Endpoint detection and response (EDR) integration
- Security information and event management (SIEM) correlation
- Automated incident triage and classification

## Installation
Advanced pattern matching engine for malware identification and classification.
Essential tool for malware analysis, incident response, and threat hunting operations.

## Dependencies
- Windows operating system (32-bit or 64-bit)
- Sufficient memory for large file scanning
- YARA rule files for detection signatures
- Optional: Compiled rule files for enhanced performance

## Performance Considerations
- Rule compilation improves scanning performance significantly
- Memory usage scales with file size and rule complexity
- Concurrent scanning limited by system resources
- Network scanning requires appropriate bandwidth and permissions

---
*Part of PORTX Portable Development Environment*