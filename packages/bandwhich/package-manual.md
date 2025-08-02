# bandwhich Package Manual

## Package Information
- **Package Name**: bandwhich
- **Category**: System Analysis
- **Type**: Network Monitor
- **License**: MIT

## Description
Terminal bandwidth utilization tool that displays network activity by process and remote host.

Real-time network monitoring tool that shows which processes are using bandwidth and which remote hosts they're communicating with.
Essential for diagnosing network issues, monitoring data usage, and identifying network-heavy applications.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| bandwhich.exe | Network bandwidth monitor by process | Monitor network usage in real-time by application |

## Common Usage Examples

### Basic Network Monitoring
```bash
# Monitor all network activity
bandwhich

# Run with elevated privileges (recommended for full process info)
# Right-click Command Prompt -> Run as Administrator
bandwhich
```

### Interface-Specific Monitoring
```bash
# List available network interfaces
bandwhich --help

# Monitor specific interface
bandwhich -i eth0

# Monitor wireless interface
bandwhich -i wlan0
```

### Process Analysis
```bash
# Show processes using most bandwidth
bandwhich

# Group by process name
bandwhich -p

# Show detailed process information
bandwhich --processes
```

### Remote Host Analysis
```bash
# Show remote hosts by data usage
bandwhich -a

# Show connections to specific addresses
bandwhich --addresses

# Monitor external connections only
bandwhich --no-local
```

### Output Customization
```bash
# Raw output (no UI)
bandwhich --raw

# Show totals only
bandwhich --total-utilization

# Unit selection
bandwhich --unit-family bytes
bandwhich --unit-family bits
```

### Debugging Network Issues
```bash
# Monitor during specific operation
bandwhich &
# Run your application
# Observe network patterns
```

## Display Interface

### Main View Components
- **Process List**: Shows applications using network
- **Remote Hosts**: Displays connected external hosts
- **Total Usage**: Real-time upload/download speeds
- **Connection Details**: Active network connections per process

### Navigation
- **Tab**: Switch between processes and connections view
- **↑/↓**: Navigate through list items  
- **q**: Quit the application
- **?**: Show help

### Information Displayed
- Process name and PID
- Upload/download speeds
- Total data transferred
- Remote IP addresses and ports
- Protocol information (TCP/UDP)

## Use Cases

### Development & Debugging
```bash
# Monitor app network usage during testing
bandwhich

# Identify which API calls are heaviest
# Track data consumption patterns
# Debug connection issues
```

### System Administration
```bash
# Identify bandwidth-heavy processes
bandwhich

# Monitor unexpected network activity
# Track data usage by application
# Investigate network performance issues
```

### Security Analysis
```bash
# Monitor for suspicious connections
bandwhich

# Track outbound connections
# Identify unknown network activity
# Monitor for data exfiltration
```

## Installation
Real-time network bandwidth monitoring by process and remote host.
Provides detailed insights into network usage patterns and connection analysis.

## Dependencies
- Administrator/elevated privileges recommended for full process information
- Windows network subsystem
- Active network interface

## Configuration
No configuration files required. All options available via command-line flags.
Run with administrator privileges for best results and complete process information.

## Performance Impact
Minimal system impact with efficient network monitoring implementation.
Uses Windows network APIs for accurate real-time data collection.

---
*Part of PORTX Portable Development Environment*