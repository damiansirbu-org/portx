# Hashdeep Package Manual

## Package Information
- **Package Name**: hashdeep
- **Category**: Security
- **Type**: Hash Computation Suite
- **License**: Public Domain

## Description
Suite of tools for computing and matching file hashes across directory trees.

Comprehensive hash computation and verification tools supporting multiple algorithms.
Essential for digital forensics, file integrity checking, and security auditing workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| hashdeep.exe | Multi-algorithm hash tool | Compute and verify hashes for multiple files |
| hashdeep64.exe | 64-bit version of hashdeep | Enhanced performance for large datasets |
| md5deep.exe | MD5 hash computation | Compute and verify MD5 hashes |
| md5deep64.exe | 64-bit MD5 deep | Enhanced MD5 processing |
| sha1deep.exe | SHA-1 hash computation | Compute and verify SHA-1 hashes |
| sha1deep64.exe | 64-bit SHA-1 deep | Enhanced SHA-1 processing |
| sha256deep.exe | SHA-256 hash computation | Compute and verify SHA-256 hashes |
| sha256deep64.exe | 64-bit SHA-256 deep | Enhanced SHA-256 processing |
| tigerdeep.exe | Tiger hash computation | Compute and verify Tiger hashes |
| tigerdeep64.exe | 64-bit Tiger deep | Enhanced Tiger processing |
| whirlpooldeep.exe | Whirlpool hash computation | Compute and verify Whirlpool hashes |
| whirlpooldeep64.exe | 64-bit Whirlpool deep | Enhanced Whirlpool processing |

## Common Usage Examples

### Basic Hash Computation
```bash
# Compute MD5 for single file
md5deep file.txt

# Compute SHA-256 for single file
sha256deep document.pdf

# Compute multiple algorithms
hashdeep file.txt
```

### Directory Hash Operations
```bash
# Hash all files in directory
md5deep -r directory/

# Hash with relative paths
sha256deep -r .

# Hash specific file types
md5deep -r -m "*.txt" directory/

# Hash excluding patterns
sha256deep -r -X "*.tmp" directory/
```

### Hash Verification
```bash
# Create hash database
md5deep -r directory/ > hashes.md5

# Verify against database
md5deep -r -X -k hashes.md5 directory/

# Check for known files
sha256deep -r -k known_hashes.sha256 target_directory/

# Negative matching (find unknown files)
md5deep -r -x -k database.md5 directory/
```

### Advanced Operations
```bash
# Estimate time for completion
hashdeep -e -r large_directory/

# Silent mode (no output except matches)
md5deep -s -k database.md5 files/

# Display only matching files
sha256deep -m -k hashes.sha256 directory/

# Display only non-matching files
md5deep -x -k database.md5 directory/
```

### Audit Mode Operations
```bash
# Create audit database
hashdeep -c md5,sha256 -r directory/ > audit.txt

# Audit mode verification
hashdeep -a -k audit.txt directory/

# Update audit database
hashdeep -u audit.txt -r directory/ > updated_audit.txt
```

### Digital Forensics Workflows
```bash
# Evidence acquisition
sha256deep -r /evidence/drive/ > evidence_hashes.sha256

# Integrity verification
sha256deep -r -k evidence_hashes.sha256 /evidence/drive/

# Known file filtering
md5deep -r -k /databases/nsrl.md5 /evidence/drive/ > unknown_files.txt

# Negative matching for investigation
md5deep -r -x -k /databases/whitelist.md5 /suspect/drive/
```

### Performance Optimized Operations
```bash
# Use 64-bit versions for large datasets
hashdeep64 -r large_directory/

# Multiple algorithms efficiently
hashdeep -c md5,sha1,sha256 -r directory/

# Estimate processing time
sha256deep64 -e -r massive_dataset/
```

### File Integrity Monitoring
```bash
# Create baseline
hashdeep -c sha256 -r /important/files/ > baseline.sha256

# Daily verification
hashdeep -a -k baseline.sha256 /important/files/ > daily_check.log

# Detect changes
hashdeep -r -X -k baseline.sha256 /important/files/ | grep -v "match"
```

### Malware Analysis
```bash
# Hash suspected files
sha256deep suspicious_file.exe

# Check against known malware database
md5deep -k malware_hashes.md5 sample.exe

# Bulk malware screening
hashdeep -r -k malware_db.hash /downloads/
```

### Data Deduplication
```bash
# Find duplicate files
md5deep -r directory/ | sort | uniq -w32 -D

# Create deduplication database
hashdeep -c md5 -r archive/ > dedup.md5

# Identify duplicates for removal
hashdeep -r -k dedup.md5 new_files/ | grep "match"
```

## Database Formats

### Hash Database Structure
```
# Example MD5 database format
## Invoked from: /path/to/directory
## $ md5deep -r directory/
## 
d41d8cd98f00b204e9800998ecf8427e  empty_file.txt
5d41402abc4b2a76b9719d911017c592  hello.txt
098f6bcd4621d373cade4e832627b4f6  test.txt
```

### Multi-Algorithm Databases
```
# Hashdeep format with multiple algorithms
## Invoked from: /path
## $ hashdeep -c md5,sha256 -r directory/
##
## size,md5,sha256,filename
0,d41d8cd98f00b204e9800998ecf8427e,e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,empty.txt
5,5d41402abc4b2a76b9719d911017c592,2cf24dba4f21d4288094e0c2bf90b4b8f9f9a7f2c1c2b96b6d4f789a7e123456,hello.txt
```

## Command Line Options

### Common Options
```bash
# Recursive processing
-r              # Process directories recursively

# Algorithm selection  
-c md5,sha1     # Compute specific algorithms

# Matching operations
-k database     # Known file matching
-x              # Negative matching (unknown files)
-m              # Positive matching (known files)

# Output control
-s              # Silent mode
-e              # Estimate time
-p              # Display progress
```

### File Selection
```bash
# Pattern matching
-m "*.exe"      # Match specific patterns
-X "*.tmp"      # Exclude patterns

# Size limits
-s              # Silent mode
-z              # Process zero-byte files
```

## Use Cases

### Security Auditing
- File integrity verification
- Malware detection and analysis
- System baseline creation
- Change detection monitoring

### Digital Forensics
- Evidence acquisition verification
- Known file elimination (NSRL)
- Timeline analysis
- Chain of custody validation

### Data Management
- Backup verification
- File deduplication
- Archive integrity
- Data migration validation

### Compliance and Governance
- Regulatory compliance verification
- Document integrity assurance
- Audit trail creation
- Data retention validation

## Installation
Comprehensive hash computation suite for security and forensics applications.
Supports multiple hash algorithms with efficient processing for large datasets.

## Dependencies
None - standalone executables with built-in hash algorithm implementations.

## Performance Considerations
- Use 64-bit versions for large datasets
- Consider SSD storage for hash databases
- Utilize multiple algorithms efficiently with hashdeep
- Monitor system resources during large operations

---
*Part of PORTX Portable Development Environment*