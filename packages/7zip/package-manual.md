# 7zip Package Manual

## Package Information
- **Package Name**: 7zip
- **Category**: Compression
- **Type**: Archive Management
- **License**: LGPL

## Description
7-Zip command line archiver for compression and extraction. 

High compression ratio archive utility supporting multiple formats including 7z, ZIP, GZIP, BZIP2, TAR, and more. 
Provides excellent compression ratios and fast extraction speeds for archive management tasks.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| 7za.exe | 7-Zip command line archiver | Archive creation, extraction, and management |

## Common Usage Examples

```bash
# Create archive
7za a archive.7z file1.txt file2.txt

# Extract archive  
7za x archive.7z

# List archive contents
7za l archive.7z

# Create ZIP file
7za a -tzip archive.zip folder/

# Extract with full paths
7za x archive.7z -o./extracted/
```

## Installation
This package provides the standalone 7za.exe executable for command-line archive operations.

## Dependencies
None - standalone executable.

---
*Part of PORTX Portable Development Environment*