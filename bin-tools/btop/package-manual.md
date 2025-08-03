# btop Package Manual

## Package Information
- **Package Name**: btop
- **Category**: System Analysis  
- **Type**: System Monitor
- **License**: Apache 2.0

## Description
Resource monitor that shows usage and stats for processor, memory, disks, network and processes.

Modern system monitor with beautiful interface, detailed metrics, and process management capabilities.
C++ replacement for htop and other top-like tools with enhanced graphics and functionality.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| btop.exe | Advanced system resource monitor | Monitor CPU, memory, disk, network, and processes |

## Common Usage Examples

### Basic System Monitoring
```bash
# Launch btop
btop

# Start with specific theme
btop --theme Default

# Start with UTF-8 force enabled
btop --utf-force

# Launch in TTY mode
btop --tty_on
```

### Configuration Options
```bash
# Use preset configuration
btop --preset 0

# Force specific color depth
btop --force-color

# Disable mouse support
btop --no-mouse

# Set update interval
btop --update 1000
```

## Interactive Controls

### General Navigation
- **q**: Quit btop
- **Esc**: Close menus and submenus
- **m**: Show main menu
- **o**: Show options menu
- **h**: Show help

### Process Management
- **t**: Kill process (select process first)
- **k**: Kill process with custom signal
- **r**: Toggle reverse sorting
- **c**: Toggle command/program name
- **e**: Show process environment variables

### View Controls
- **1-4**: Toggle CPU/Memory/Network/Disk boxes
- **Tab**: Switch between process sorting options
- **Space**: Pause/unpause updates
- **+/-**: Increase/decrease update speed
- **F1-F4**: Show help for each section

### Process Sorting
- **P**: Sort by PID
- **N**: Sort by process name  
- **C**: Sort by CPU usage
- **M**: Sort by memory usage
- **T**: Sort by running time
- **I**: Sort by I/O usage

### Process Filtering
- **f**: Filter processes
- **F**: Toggle case-sensitive filtering
- **Ctrl+f**: Clear filter
- **/**: Search in process list

## Display Sections

### CPU Monitor
- Multi-core CPU graphs
- CPU frequency and temperature
- Load average display
- CPU usage history
- Per-core utilization

### Memory Monitor  
- RAM usage with detailed breakdown
- Swap usage monitoring
- Memory history graphs
- Available/used memory stats
- Memory pressure indicators

### Network Monitor
- Real-time network I/O
- Download/upload speeds
- Total data transferred
- Network interface statistics
- Connection activity

### Disk Monitor
- Disk usage by filesystem
- Read/write activity
- I/O rates and latency
- Disk space availability
- Mount point information

### Process List
- Detailed process information
- CPU and memory usage per process
- Process tree view option
- Command line arguments
- User and group information

## Configuration File (btop.conf)

### Location
- Windows: `%APPDATA%\btop\btop.conf`
- Configuration created automatically on first run

### Sample Configuration
```ini
# Color theme
color_theme = "Default"

# Update time in milliseconds  
update_ms = 1000

# Show disks stats
show_disks = true

# Shown CPU graph type
cpu_graph_upper = "total"
cpu_graph_lower = "total"

# Show memory in bytes
mem_unit = "binary"

# Network interface to monitor
net_interface = "auto"

# Process sorting
proc_sorting = "cpu lazy"

# Show process tree
proc_tree = false
```

### Theme Options
- Default
- TTY
- Low-contrast
- High-contrast
- Gruvbox_dark
- Nord
- Dracula

## Advanced Features

### Custom Signal Management
```bash
# Send SIGTERM (default kill)
Select process + t

# Send custom signal
Select process + k
# Then select signal number
```

### Filtering Examples
```bash
# Filter by process name
f -> "firefox"

# Filter by user
f -> "user:username"

# Filter by CPU usage
f -> "cpu:>50"

# Filter by memory
f -> "mem:>1G"
```

### Process Information
- Real-time CPU and memory usage
- I/O read/write statistics
- Process uptime and state
- Parent-child relationships
- Thread count and priorities

## Installation
Advanced system monitor with beautiful interface and comprehensive metrics.
Modern replacement for htop with enhanced graphics and process management.

## Dependencies
- Windows console with Unicode support recommended
- Color terminal for best visual experience
- Administrative privileges for some system information

## Performance Impact
Optimized C++ implementation with minimal system overhead.
Efficient data collection and display rendering for smooth real-time monitoring.

---
*Part of PORTX Portable Development Environment*