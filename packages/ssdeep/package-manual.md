# SSDeep Package Manual

## Package Information
- **Package Name**: ssdeep
- **Category**: Security Tools
- **Type**: Fuzzy Hashing Utility
- **License**: GPL v2

## Description
Context triggered piecewise hashing tool for identifying similar or related files.

SSDeep computes fuzzy hashes that can match files with minor differences, making it ideal for malware analysis, forensic investigations, and detecting file variants.
Uses context triggered piecewise hashing (CTPH) to identify similarities between files even when they have been modified or obfuscated.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| ssdeep.exe | Fuzzy hashing utility | Generate and compare fuzzy hashes |
| fuzzy.dll | Fuzzy hashing library | Core hashing and comparison algorithms |

## Fuzzy Hashing Concepts

### Context Triggered Piecewise Hashing (CTPH)
- **Rolling Hash**: Uses a rolling hash to identify similar byte sequences
- **Piece Boundaries**: Triggered by content-dependent boundaries
- **Similarity Scoring**: Produces similarity percentage between files
- **Partial Matching**: Can identify similar files even with significant changes

### Hash Format
```
blocksize:hash1:hash2
3072:OGLa+Qy7Fqh2pLa5Q3y7Fqh2pLa5Q3y7:OGLa+Qy7FqzQ3y7
```
- **Blocksize**: Average size of pieces used
- **Hash1**: Hash of pieces with blocksize
- **Hash2**: Hash of pieces with blocksize*2

## Common Usage Examples

### Basic Fuzzy Hashing
```bash
# Generate fuzzy hash for single file
ssdeep file.exe

# Generate fuzzy hash with filename
ssdeep -b file.exe

# Hash multiple files
ssdeep *.exe

# Recursive hashing of directory
ssdeep -r /path/to/directory

# Output to file
ssdeep -r malware_samples/ > hashes.txt
```

### File Comparison and Similarity
```bash
# Compare two files directly
ssdeep -m file1.exe file2.exe

# Compare file against hash database
ssdeep -m known_hashes.txt suspicious_file.exe

# Set similarity threshold (0-100)
ssdeep -t 50 -m baseline.txt sample.exe

# Batch comparison
ssdeep -d known_malware.txt suspicious_files/
```

### Advanced Options
```bash
# Generate hash only (no filename)
ssdeep -s file.exe

# Pretty print output
ssdeep -p files/

# Verbose output
ssdeep -v -r samples/

# Silent mode (no warnings)
ssdeep -q files/

# Process files with specific extensions
find /samples -name "*.exe" -exec ssdeep {} \;
```

## Malware Analysis Workflows

### Building Malware Family Signatures
```bash
#!/bin/bash
# Build fuzzy hash database for malware family

FAMILY_NAME=$1
SAMPLES_DIR=$2
OUTPUT_DB="${FAMILY_NAME}_signatures.txt"

echo "Building signature database for: $FAMILY_NAME"

# Generate fuzzy hashes for all samples
ssdeep -r "$SAMPLES_DIR" > "$OUTPUT_DB"

# Sort by similarity (requires preprocessing)
echo "Analyzing sample relationships..."

# Create similarity matrix
while IFS= read -r line; do
    if [[ $line == *":"* ]]; then
        hash=$(echo "$line" | cut -d',' -f1)
        filename=$(echo "$line" | cut -d',' -f2)
        
        echo "Checking similarity for: $filename"
        ssdeep -t 70 -m "$OUTPUT_DB" "$filename" | grep -v "^$filename" >> "${FAMILY_NAME}_similarities.txt"
    fi
done < "$OUTPUT_DB"

echo "Signature database created: $OUTPUT_DB"
echo "Similarity analysis: ${FAMILY_NAME}_similarities.txt"
```

### Malware Variant Detection
```bash
#!/bin/bash
# Detect variants of known malware

KNOWN_MALWARE_DB="known_malware.txt"
SUSPICIOUS_FILE=$1
THRESHOLD=${2:-75}

echo "Analyzing file for malware variants: $SUSPICIOUS_FILE"

# Generate hash for suspicious file
SUSPECT_HASH=$(ssdeep -s "$SUSPICIOUS_FILE")

if [ -z "$SUSPECT_HASH" ]; then
    echo "Error: Could not generate hash for $SUSPICIOUS_FILE"
    exit 1
fi

echo "File hash: $SUSPECT_HASH"

# Compare against known malware database
echo "Checking against known malware database..."
MATCHES=$(ssdeep -t $THRESHOLD -m "$KNOWN_MALWARE_DB" "$SUSPICIOUS_FILE")

if [ -n "$MATCHES" ]; then
    echo "ALERT: Potential malware variant detected!"
    echo "Matches found:"
    echo "$MATCHES"
    
    # Extract similarity scores
    echo "$MATCHES" | while read match; do
        if [[ $match == *"matches"* ]]; then
            score=$(echo "$match" | grep -o '[0-9]\+%' | head -1)
            family=$(echo "$match" | cut -d' ' -f1)
            echo "  - Family: $family, Similarity: $score"
        fi
    done
else
    echo "No significant matches found (threshold: $THRESHOLD%)"
fi
```

### Forensic File Analysis
```bash
#!/bin/bash
# Forensic analysis using fuzzy hashing

EVIDENCE_DIR=$1
CASE_ID=$2
ANALYSIS_DIR="/forensics/case_${CASE_ID}_analysis"

mkdir -p "$ANALYSIS_DIR"

echo "Starting forensic analysis for case: $CASE_ID"

# Generate complete hash database
echo "Generating comprehensive hash database..."
ssdeep -r "$EVIDENCE_DIR" > "$ANALYSIS_DIR/all_files.txt"

# Identify potential duplicate or similar files
echo "Identifying similar files..."
ssdeep -d "$ANALYSIS_DIR/all_files.txt" > "$ANALYSIS_DIR/similar_files.txt"

# Extract unique file families
echo "Clustering similar files..."

# Process similarity results
awk '/matches/ {
    file1 = $1
    file2 = $3
    gsub(/\(|\)|%/, "", $NF)
    similarity = $NF
    if (similarity >= 80) {
        print file1 " -> " file2 " (" similarity "%)"
    }
}' "$ANALYSIS_DIR/similar_files.txt" > "$ANALYSIS_DIR/high_similarity.txt"

# Generate statistics
total_files=$(wc -l < "$ANALYSIS_DIR/all_files.txt")
similar_pairs=$(wc -l < "$ANALYSIS_DIR/high_similarity.txt")

echo "Analysis complete for case: $CASE_ID"
echo "Total files analyzed: $total_files"
echo "High similarity pairs found: $similar_pairs"
echo "Results saved in: $ANALYSIS_DIR"
```

## Advanced Analysis Techniques

### Malware Clustering and Classification
```python
#!/usr/bin/env python3
# Advanced ssdeep analysis with Python

import subprocess
import re
import json
from collections import defaultdict

class SSDeepAnalyzer:
    def __init__(self, threshold=70):
        self.threshold = threshold
        self.samples = {}
        self.clusters = defaultdict(list)
    
    def generate_hash(self, filepath):
        """Generate ssdeep hash for a file"""
        try:
            result = subprocess.run(['ssdeep', '-s', filepath], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                return result.stdout.strip()
        except Exception as e:
            print(f"Error hashing {filepath}: {e}")
        return None
    
    def compare_hashes(self, hash1, hash2):
        """Compare two ssdeep hashes"""
        try:
            # Create temporary files with hashes
            with open('temp_hash1.txt', 'w') as f:
                f.write(f"{hash1},file1\n")
            
            result = subprocess.run(['ssdeep', '-m', 'temp_hash1.txt'], 
                                  input=hash2, capture_output=True, text=True)
            
            # Extract similarity percentage
            match = re.search(r'(\d+)%', result.stdout)
            return int(match.group(1)) if match else 0
            
        except Exception as e:
            print(f"Error comparing hashes: {e}")
            return 0
    
    def analyze_directory(self, directory):
        """Analyze all files in directory"""
        import os
        
        for root, dirs, files in os.walk(directory):
            for file in files:
                filepath = os.path.join(root, file)
                hash_value = self.generate_hash(filepath)
                if hash_value:
                    self.samples[filepath] = hash_value
    
    def cluster_samples(self):
        """Cluster samples by similarity"""
        processed = set()
        cluster_id = 0
        
        for file1, hash1 in self.samples.items():
            if file1 in processed:
                continue
                
            cluster = [file1]
            processed.add(file1)
            
            for file2, hash2 in self.samples.items():
                if file2 in processed:
                    continue
                    
                similarity = self.compare_hashes(hash1, hash2)
                if similarity >= self.threshold:
                    cluster.append(file2)
                    processed.add(file2)
            
            if len(cluster) > 1:
                self.clusters[f"cluster_{cluster_id}"] = cluster
                cluster_id += 1
    
    def generate_report(self, output_file):
        """Generate analysis report"""
        report = {
            'total_samples': len(self.samples),
            'clusters_found': len(self.clusters),
            'threshold': self.threshold,
            'clusters': dict(self.clusters)
        }
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        return report

# Usage example
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 ssdeep_analyzer.py <directory>")
        sys.exit(1)
    
    analyzer = SSDeepAnalyzer(threshold=75)
    analyzer.analyze_directory(sys.argv[1])
    analyzer.cluster_samples()
    
    report = analyzer.generate_report('analysis_report.json')
    print(f"Analysis complete. Found {report['clusters_found']} clusters from {report['total_samples']} samples.")
```

### Timeline Analysis with Fuzzy Hashing
```bash
#!/bin/bash
# Timeline analysis using fuzzy hashing

TIMELINE_DIR=$1
OUTPUT_DIR="/tmp/timeline_analysis"
BASELINE_HASH="baseline_system.txt"

mkdir -p "$OUTPUT_DIR"

echo "Starting timeline analysis..."

# Generate baseline system hash
if [ ! -f "$BASELINE_HASH" ]; then
    echo "Generating baseline system hashes..."
    ssdeep -r /bin /usr/bin /sbin /usr/sbin > "$BASELINE_HASH"
fi

# Analyze each timeline snapshot
for snapshot in "$TIMELINE_DIR"/*; do
    if [ -d "$snapshot" ]; then
        timestamp=$(basename "$snapshot")
        echo "Analyzing snapshot: $timestamp"
        
        # Generate hashes for snapshot
        ssdeep -r "$snapshot" > "$OUTPUT_DIR/snapshot_${timestamp}.txt"
        
        # Compare against baseline
        ssdeep -t 90 -m "$BASELINE_HASH" "$OUTPUT_DIR/snapshot_${timestamp}.txt" > "$OUTPUT_DIR/changes_${timestamp}.txt"
        
        # Identify new files (not in baseline)
        comm -23 <(sort "$OUTPUT_DIR/snapshot_${timestamp}.txt") <(sort "$BASELINE_HASH") > "$OUTPUT_DIR/new_files_${timestamp}.txt"
        
        # Generate summary
        new_count=$(wc -l < "$OUTPUT_DIR/new_files_${timestamp}.txt")
        changed_count=$(wc -l < "$OUTPUT_DIR/changes_${timestamp}.txt")
        
        echo "  New files: $new_count"
        echo "  Changed files: $changed_count"
    fi
done

echo "Timeline analysis complete. Results in: $OUTPUT_DIR"
```

## Integration with Security Tools

### YARA Rule Generation from Fuzzy Hashes
```bash
#!/bin/bash
# Generate YARA rules from ssdeep clusters

CLUSTER_FILE=$1
RULE_NAME=$2
OUTPUT_RULE="${RULE_NAME}.yar"

echo "Generating YARA rule from fuzzy hash cluster..."

# Extract representative samples from cluster
head -5 "$CLUSTER_FILE" | while read hash_line; do
    filename=$(echo "$hash_line" | cut -d',' -f2)
    echo "Processing: $filename"
    
    # Extract strings for YARA rule
    strings "$filename" | grep -E '^.{8,}$' | head -10 >> "/tmp/strings_${RULE_NAME}.txt"
done

# Generate YARA rule
cat > "$OUTPUT_RULE" << EOF
rule ${RULE_NAME}_Fuzzy_Cluster
{
    meta:
        description = "Generated from fuzzy hash cluster analysis"
        author = "SSDeep Analysis"
        date = "$(date +%Y-%m-%d)"
        
    strings:
EOF

# Add unique strings to rule
sort "/tmp/strings_${RULE_NAME}.txt" | uniq | head -15 | while read str; do
    echo "        \$str$(md5sum <<< "$str" | cut -c1-8) = \"$str\" ascii" >> "$OUTPUT_RULE"
done

cat >> "$OUTPUT_RULE" << EOF
        
    condition:
        3 of them
}
EOF

echo "YARA rule generated: $OUTPUT_RULE"
rm -f "/tmp/strings_${RULE_NAME}.txt"
```

### VirusTotal Integration
```python
#!/usr/bin/env python3
# Integrate ssdeep with VirusTotal for enhanced analysis

import requests
import hashlib
import subprocess
import json
import time

class SSDeepVTIntegration:
    def __init__(self, vt_api_key):
        self.vt_api_key = vt_api_key
        self.vt_base_url = "https://www.virustotal.com/vtapi/v2"
    
    def get_file_ssdeep(self, filepath):
        """Generate ssdeep hash for file"""
        result = subprocess.run(['ssdeep', '-s', filepath], 
                              capture_output=True, text=True)
        return result.stdout.strip() if result.returncode == 0 else None
    
    def get_file_md5(self, filepath):
        """Generate MD5 hash for file"""
        hash_md5 = hashlib.md5()
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    
    def query_virustotal(self, file_hash):
        """Query VirusTotal for file information"""
        params = {
            'apikey': self.vt_api_key,
            'resource': file_hash
        }
        
        response = requests.get(f"{self.vt_base_url}/file/report", params=params)
        
        if response.status_code == 200:
            return response.json()
        else:
            return None
    
    def analyze_file(self, filepath):
        """Comprehensive file analysis"""
        print(f"Analyzing: {filepath}")
        
        # Generate hashes
        ssdeep_hash = self.get_file_ssdeep(filepath)
        md5_hash = self.get_file_md5(filepath)
        
        if not ssdeep_hash or not md5_hash:
            print("Error generating hashes")
            return None
        
        print(f"SSDeep: {ssdeep_hash}")
        print(f"MD5: {md5_hash}")
        
        # Query VirusTotal
        vt_result = self.query_virustotal(md5_hash)
        
        if vt_result and vt_result.get('response_code') == 1:
            print(f"VirusTotal detections: {vt_result.get('positives', 0)}/{vt_result.get('total', 0)}")
            
            # Check if VirusTotal has ssdeep
            if 'ssdeep' in vt_result:
                vt_ssdeep = vt_result['ssdeep']
                print(f"VT SSDeep: {vt_ssdeep}")
                
                # Compare ssdeep hashes
                similarity = self.compare_ssdeep(ssdeep_hash, vt_ssdeep)
                print(f"SSDeep similarity: {similarity}%")
        else:
            print("File not found in VirusTotal")
        
        # Throttle API requests
        time.sleep(15)
        
        return {
            'file': filepath,
            'ssdeep': ssdeep_hash,
            'md5': md5_hash,
            'virustotal': vt_result
        }
    
    def compare_ssdeep(self, hash1, hash2):
        """Compare two ssdeep hashes"""
        try:
            with open('temp_compare.txt', 'w') as f:
                f.write(f"{hash1},file1\n")
            
            result = subprocess.run(['ssdeep', '-m', 'temp_compare.txt'],
                                  input=hash2, capture_output=True, text=True)
            
            import re
            match = re.search(r'(\d+)%', result.stdout)
            return int(match.group(1)) if match else 0
        except:
            return 0

# Usage
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: python3 ssdeep_vt.py <api_key> <file_path>")
        sys.exit(1)
    
    api_key = sys.argv[1]
    file_path = sys.argv[2]
    
    analyzer = SSDeepVTIntegration(api_key)
    result = analyzer.analyze_file(file_path)
```

## Performance Optimization and Batch Processing

### High-Performance Batch Analysis
```bash
#!/bin/bash
# High-performance batch ssdeep processing

INPUT_DIR=$1
OUTPUT_DIR="/tmp/ssdeep_batch"
THREADS=${2:-4}

mkdir -p "$OUTPUT_DIR"

echo "Starting batch processing with $THREADS threads..."

# Split file list for parallel processing
find "$INPUT_DIR" -type f -executable > "/tmp/file_list.txt"
total_files=$(wc -l < "/tmp/file_list.txt")
files_per_thread=$((total_files / THREADS + 1))

split -l $files_per_thread "/tmp/file_list.txt" "/tmp/chunk_"

# Process chunks in parallel
for chunk in /tmp/chunk_*; do
    {
        chunk_id=$(basename "$chunk")
        echo "Processing chunk: $chunk_id"
        
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                ssdeep "$file" >> "$OUTPUT_DIR/hashes_${chunk_id}.txt"
            fi
        done < "$chunk"
        
        echo "Completed chunk: $chunk_id"
    } &
done

# Wait for all background jobs to complete
wait

# Combine results
cat "$OUTPUT_DIR"/hashes_chunk_*.txt > "$OUTPUT_DIR/all_hashes.txt"

# Generate similarity matrix
echo "Generating similarity analysis..."
ssdeep -d "$OUTPUT_DIR/all_hashes.txt" > "$OUTPUT_DIR/similarities.txt"

# Cleanup
rm -f /tmp/chunk_* /tmp/file_list.txt

echo "Batch processing complete. Results in: $OUTPUT_DIR"
echo "Total files processed: $total_files"
echo "Hash database: $OUTPUT_DIR/all_hashes.txt"
echo "Similarity analysis: $OUTPUT_DIR/similarities.txt"
```

### Memory-Efficient Large Dataset Processing
```bash
#!/bin/bash
# Memory-efficient processing for large datasets

DATASET_DIR=$1
CHUNK_SIZE=${2:-1000}
OUTPUT_BASE="/tmp/ssdeep_large_dataset"

mkdir -p "$OUTPUT_BASE"

echo "Processing large dataset in chunks of $CHUNK_SIZE files..."

# Create file inventory
find "$DATASET_DIR" -type f > "$OUTPUT_BASE/file_inventory.txt"
total_files=$(wc -l < "$OUTPUT_BASE/file_inventory.txt")

echo "Total files to process: $total_files"

# Process in chunks to manage memory
chunk_num=0
while IFS= read -r file; do
    echo "$file" >> "$OUTPUT_BASE/current_chunk.txt"
    
    # Process chunk when it reaches target size
    if [ $(($(wc -l < "$OUTPUT_BASE/current_chunk.txt"))) -eq $CHUNK_SIZE ]; then
        echo "Processing chunk $chunk_num..."
        
        # Generate hashes for current chunk
        while IFS= read -r chunk_file; do
            ssdeep "$chunk_file" >> "$OUTPUT_BASE/chunk_${chunk_num}_hashes.txt"
        done < "$OUTPUT_BASE/current_chunk.txt"
        
        # Clear current chunk
        > "$OUTPUT_BASE/current_chunk.txt"
        ((chunk_num++))
    fi
done < "$OUTPUT_BASE/file_inventory.txt"

# Process remaining files
if [ -s "$OUTPUT_BASE/current_chunk.txt" ]; then
    echo "Processing final chunk $chunk_num..."
    while IFS= read -r chunk_file; do
        ssdeep "$chunk_file" >> "$OUTPUT_BASE/chunk_${chunk_num}_hashes.txt"
    done < "$OUTPUT_BASE/current_chunk.txt"
fi

# Create master hash database
cat "$OUTPUT_BASE"/chunk_*_hashes.txt > "$OUTPUT_BASE/master_hashes.txt"

echo "Large dataset processing complete."
echo "Master hash database: $OUTPUT_BASE/master_hashes.txt"
echo "Chunks processed: $((chunk_num + 1))"
```

## Use Cases

### Malware Analysis and Research
- Malware family classification and clustering
- Variant detection and analysis
- Payload similarity assessment
- Evolutionary tracking of malware families

### Digital Forensics and Investigation
- File tampering detection and analysis
- Evidence correlation and timeline reconstruction
- Data exfiltration pattern identification
- Incident response and damage assessment

### Threat Intelligence and Hunting
- IOC development and signature creation
- Threat actor tracking and attribution
- Campaign analysis and correlation
- Proactive threat hunting operations

### Data Loss Prevention and Compliance
- Sensitive data identification and tracking
- Document similarity analysis
- Copyright infringement detection
- Intellectual property protection

## Installation
Context triggered piecewise hashing tool for file similarity analysis.
Essential for malware research, digital forensics, and security investigations.

## Dependencies
- Windows operating system (32-bit or 64-bit)
- Sufficient memory for large file processing
- Disk space for hash databases and analysis results
- Optional: Python for advanced analysis scripts

## Performance Considerations
- Processing speed depends on file size and system resources
- Large datasets benefit from parallel processing approaches
- Memory usage scales with number of files processed simultaneously
- Network bandwidth may be required for threat intelligence integration

---
*Part of PORTX Portable Development Environment*