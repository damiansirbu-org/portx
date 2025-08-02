# Microsoft SysInternals Command-Line Tools

This directory contains 31 essential command-line tools from the Microsoft SysInternals Suite for Windows system analysis, troubleshooting, and diagnostics.

## Available Tools

### Process and System Information
- **psinfo64.exe** - Display system information and hardware specs
- **pslist64.exe** - List running processes with detailed information
- **handle64.exe** - Show open files, registry keys, and handles by process
- **listdlls64.exe** - List loaded DLLs with versions and locations
- **LogonSessions64.exe** - Display active user logon sessions

### Security and Access Control
- **accesschk64.exe** - View effective permissions on files, registry, services
- **PsGetsid64.exe** - Display Security ID (SID) of users or computers
- **psfile64.exe** - Show files opened remotely over network shares

### System Monitoring and Analysis
- **autorunsc64.exe** - Show programs configured to start automatically
- **procdump64.exe** - Create process dumps for analysis
- **Coreinfo64.exe** - Display CPU core and cache topology information
- **clockres64.exe** - View system clock resolution

### File System Operations
- **streams64.exe** - Enumerate NTFS alternate data streams
- **strings64.exe** - Extract printable strings from binary files
- **FindLinks64.exe** - Find hard links and file index information
- **junction64.exe** - Create and manage NTFS junction points and symbolic links
- **Contig64.exe** - Defragment individual files or show fragmentation
- **VolumeId64.exe** - Display or set FAT/NTFS volume serial numbers

### Network and Remote Tools
- **psping64.exe** - Measure network latency and bandwidth
- **whois64.exe** - Look up domain registration information
- **PsExec64.exe** - Execute processes remotely

### Process Management
- **pskill64.exe** - Terminate local or remote processes
- **PsLoggedon64.exe** - Show users logged on locally or via resource sharing

### Registry and System Maintenance
- **RegDelNull64.exe** - Delete registry keys containing embedded null characters
- **PendMoves64.exe** - Display file rename/delete operations scheduled for next boot
- **sync64.exe** - Force file system buffers to be written to disk

### System Utilities
- **pipelist64.exe** - Display named pipes on the system
- **hex2dec64.exe** - Convert hexadecimal numbers to decimal and vice versa
- **adrestore64.exe** - Restore deleted Active Directory objects (Server 2003+)

## Usage Notes

### EULA Acceptance
All SysInternals tools require accepting the End User License Agreement on first run. Use the `-accepteula` parameter to automatically accept:

```bash
psinfo64 -accepteula
handle64 -accepteula
```

### Common Usage Patterns

**System Information:**
```bash
psinfo64 -accepteula              # System specs and uptime
Coreinfo64 -accepteula            # CPU topology details
clockres64 -accepteula            # Timer resolution
```

**Process Analysis:**
```bash
pslist64 -accepteula              # Running processes
handle64 -accepteula -p chrome    # Files opened by Chrome
listdlls64 -accepteula chrome     # DLLs loaded by Chrome
```

**Security Analysis:**
```bash
accesschk64 -accepteula -d C:\    # Directory permissions
PsGetsid64 -accepteula username   # User SID lookup
autorunsc64 -accepteula           # Startup programs
```

**File System Analysis:**
```bash
streams64 -accepteula file.txt    # NTFS alternate streams
strings64 -accepteula binary.exe  # Extract strings from binary
FindLinks64 -accepteula file.txt  # Find hard links
```

**Network Diagnostics:**
```bash
psping64 -accepteula host:port    # Network latency test
whois64 -accepteula example.com   # Domain information
```

## Integration with PORTX

These tools integrate seamlessly with the PORTX environment and can be combined with other PORTX tools:

```bash
# Find Chrome processes using ripgrep
pslist64 -accepteula | rg "chrome|firefox"

# Extract strings and search with modern tools
strings64 -accepteula suspicious.exe | rg "http|ftp|password"

# Monitor handles and filter with jq (if output were JSON)
handle64 -accepteula | rg "firefox" | head -20
```

## Tool Size

Total size: 12MB for 31 enterprise-grade system analysis tools

## Official Documentation

For detailed documentation on each tool, visit:
https://learn.microsoft.com/en-us/sysinternals/downloads/

## License

These tools are provided by Microsoft under the SysInternals Software License Terms. Users must accept the EULA to use the tools.