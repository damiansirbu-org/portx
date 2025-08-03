# SysInternals Package Manual

## Package Information
- **Package Name**: sysinternals
- **Category**: System Analysis
- **Type**: Windows System Diagnostics
- **License**: Microsoft Software License

## Description
Microsoft SysInternals suite for Windows system diagnostics and troubleshooting.

Complete collection of advanced system utilities for Windows analysis, monitoring, and administration.
Essential tools for system administrators, security professionals, and developers working with Windows systems.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| accesschk64.exe | View effective permissions on files, registry, services | Security auditing and permission analysis |
| adrestore64.exe | Active Directory object restoration tool | AD recovery and management |
| autorunsc64.exe | Show programs configured to start automatically | Security analysis of startup programs |
| clockres64.exe | System clock resolution viewer | System timing analysis |
| Contig64.exe | File defragmentation tool | File system optimization |
| Coreinfo64.exe | CPU information tool | Hardware analysis and capabilities |
| FindLinks64.exe | Hard link finder | File system link analysis |
| handle64.exe | Handle viewer | Process and system handle analysis |
| hex2dec64.exe | Hex to decimal converter | Number base conversion utility |
| junction64.exe | Junction point manager | NTFS junction point management |
| listdlls64.exe | List loaded DLLs | Process dependency analysis |
| LogonSessions64.exe | Logon session information | User session monitoring |
| PendMoves64.exe | Pending file operations viewer | System file operation monitoring |
| pipelist64.exe | Named pipe viewer | Inter-process communication analysis |
| procdump64.exe | Process dump utility | Application crash dump generation |
| psfile64.exe | Show files opened remotely | Network file access monitoring |
| PsGetsid64.exe | Display SID information | Security identifier lookup |
| psinfo64.exe | System information tool | Comprehensive system details |
| pskill64.exe | Process termination utility | Advanced process management |
| PsList64.exe | Process listing tool | Enhanced process information |
| PsLoggedon64.exe | Show logged on users | User session analysis |
| psping64.exe | Network ping utility | Network connectivity testing |
| PsExec64.exe | Execute processes remotely | Remote process execution |
| RegDelNull64.exe | Registry null value cleaner | Registry maintenance |
| streams64.exe | NTFS alternate data streams | File system metadata analysis |
| strings64.exe | Extract strings from binaries | Binary analysis and forensics |
| sync64.exe | Force file system sync | File system cache management |
| VolumeId64.exe | Volume ID changer | Disk volume management |
| whois64.exe | Domain registration lookup | Network domain information |

## Common Usage Examples

### System Analysis
```bash
# Get comprehensive system information
psinfo64

# View CPU details and capabilities  
Coreinfo64

# Check system clock resolution
clockres64
```

### Security Auditing
```bash
# Check file/registry permissions
accesschk64 -accepteula -s -d C:\Windows

# View startup programs
autorunsc64 -accepteula

# Show logged on users
PsLoggedon64 -accepteula
```

### Process Management
```bash
# List all processes with details
PsList64 -accepteula

# View process handles
handle64 -accepteula

# List loaded DLLs for a process
listdlls64 -accepteula notepad.exe

# Create process dump
procdump64 -accepteula notepad.exe
```

### File System Analysis
```bash
# Find hard links
FindLinks64 C:\Windows\System32\kernel32.dll

# View NTFS streams
streams64 -accepteula file.txt

# Extract strings from binary
strings64 program.exe
```

### Network Analysis
```bash
# Test network connectivity
psping64 google.com:80

# View network file access
psfile64 -accepteula

# Domain information lookup
whois64 microsoft.com
```

## Installation
Complete Microsoft SysInternals suite with all command-line utilities.
These tools provide deep Windows system analysis capabilities for professionals.

## Dependencies
- Windows operating system
- Administrative privileges recommended for full functionality
- Tools accept `-accepteula` flag to bypass license dialog

## Notes
- Most tools require `-accepteula` parameter for unattended operation
- Some tools require administrative privileges
- All tools are digitally signed by Microsoft
- Part of the official Microsoft SysInternals toolkit

---
*Part of PORTX Portable Development Environment*