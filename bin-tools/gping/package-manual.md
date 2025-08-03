# gping Package Manual

## Package Information
- **Package Name**: gping
- **Category**: Network Tools
- **Type**: Network Diagnostics
- **License**: MIT

## Description
Ping, but with a graph and better output.

Modern ping utility with real-time graphical output, statistics, and enhanced network diagnostics.
Provides visual feedback for network connectivity monitoring and latency analysis.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| gping.exe | Graphical ping utility | Network connectivity testing with visual graphs |

## Common Usage Examples

### Basic Network Testing
```bash
# Ping single host
gping google.com

# Ping IP address
gping 8.8.8.8

# Ping with specific count
gping -c 10 github.com

# Continuous ping (default)
gping cloudflare.com
```

### Multiple Host Monitoring
```bash
# Ping multiple hosts simultaneously
gping google.com github.com cloudflare.com

# Compare different DNS servers
gping 8.8.8.8 1.1.1.1 208.67.222.222

# Monitor local and remote hosts
gping localhost 192.168.1.1 google.com
```

### Advanced Options
```bash
# Custom ping interval
gping --ping-interval 0.5 google.com

# IPv4 only
gping -4 google.com

# IPv6 only
gping -6 google.com

# Watch mode (like watch command)
gping --watch-interval 1 google.com
```

### Network Diagnostics
```bash
# Test network stability
gping --ping-interval 0.1 -c 100 8.8.8.8

# Monitor gateway connectivity
gping 192.168.1.1

# Test DNS resolution and connectivity
gping dns.google.com

# Monitor multiple network paths
gping 8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9
```

### Display and Output Control
```bash
# Simple display (no graph)
gping --simple-graphics google.com

# Custom graph buffer size
gping --buffer 100 google.com

# No color output
gping --no-color google.com

# Specific interface (if multiple available)
gping --interface eth0 google.com
```

## Visual Interface

### Graph Display
- **Real-time latency graph**: Shows ping response times over time
- **Multiple host comparison**: Different colored lines for each host
- **Response time axis**: Y-axis shows milliseconds
- **Time axis**: X-axis shows elapsed time
- **Statistics panel**: Shows min/max/avg latency and packet loss

### Color Coding
- **Green**: Good latency (< 50ms typically)
- **Yellow**: Moderate latency (50-150ms)
- **Red**: High latency (> 150ms) or timeouts
- **Different colors**: For different hosts when pinging multiple

### Information Display
- Current latency for each host
- Minimum/Maximum/Average response times
- Packet loss percentage
- Total packets sent/received
- Elapsed time

## Network Troubleshooting Examples

### Connectivity Testing
```bash
# Test internet connectivity
gping 8.8.8.8

# Test local network
gping 192.168.1.1

# Test DNS resolution
gping google.com
```

### Performance Analysis
```bash
# Monitor network stability over time
gping --ping-interval 1 -c 300 target.com

# Compare different routes/providers
gping provider1.com provider2.com provider3.com

# Test during different times
gping --watch-interval 60 service.com
```

### ISP and Route Analysis
```bash
# Test primary DNS
gping 8.8.8.8

# Test secondary DNS
gping 1.1.1.1

# Test local ISP DNS
gping 192.168.1.1

# Compare international vs local
gping local-server.com international-server.com
```

### Gaming and Real-time Applications
```bash
# Test gaming server latency
gping game-server.com

# Monitor VoIP quality
gping --ping-interval 0.1 voip-server.com

# Test video streaming
gping cdn.streaming-service.com
```

## Integration with Other Tools

### Scripting and Automation
```bash
# Export data for analysis
gping -c 100 google.com > ping-results.txt

# Monitor and alert
gping --ping-interval 5 critical-server.com &
PID=$!
# Later: kill $PID
```

### Network Monitoring Workflows
```bash
# Quick network health check
gping 8.8.8.8 1.1.1.1 &

# Continuous monitoring
while true; do
    gping -c 10 server.com
    sleep 60
done
```

### Troubleshooting Scripts
```bash
# Network diagnostic script
echo "Testing connectivity..."
gping -c 5 8.8.8.8
echo "Testing DNS..."
gping -c 5 google.com
echo "Testing local gateway..."
gping -c 5 192.168.1.1
```

## Use Cases

### Development and Testing
- API endpoint response time monitoring
- CDN performance testing
- Database connection latency
- Microservice communication testing

### System Administration
- Network infrastructure monitoring
- ISP performance validation
- Route optimization analysis
- Connectivity troubleshooting

### Gaming and Entertainment
- Gaming server latency testing
- Streaming service connectivity
- VPN performance analysis
- Network stability for real-time applications

### Business Operations
- SLA monitoring and validation
- Service availability testing
- Network performance baselines
- Incident response diagnostics

## Interactive Controls

### During Execution
- **Ctrl+C**: Stop ping and show summary
- **Q**: Quit application
- **R**: Reset graph display
- **P**: Pause/resume pinging

## Installation
Modern ping utility with graphical output and enhanced network diagnostics.
Essential tool for network connectivity testing and latency monitoring.

## Dependencies
- Network interface access
- ICMP packet sending capabilities (may require elevated privileges)
- Terminal with color support for best experience

## Performance Features
- Efficient packet handling
- Real-time graph rendering
- Low system resource usage
- Concurrent multi-host support
- Responsive terminal interface

---
*Part of PORTX Portable Development Environment*