# bottom Package Manual

## Package Information
- **Package Name**: bottom
- **Category**: System Analysis
- **Type**: System Monitor
- **License**: MIT

## Description
Cross-platform graphical process/system monitor with a customizable interface.

Modern system monitoring tool with real-time process, CPU, memory, disk, and network monitoring.
Features customizable widgets, process management, and detailed system information display.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| btm.exe | System monitor with customizable dashboard | Monitor system resources and processes |

## Common Usage Examples

### Basic System Monitoring
```bash
# Launch interactive system monitor
btm

# Start with specific refresh rate (milliseconds)
btm -r 1000

# Start with basic interface
btm -b
```

### Process Management
```bash
# Launch focused on processes
btm --default_widget_type proc

# Show tree view by default
btm -T

# Group processes by default
btm -g
```

### Resource Monitoring
```bash
# Show CPU usage as percentage
btm --cpu_left_legend

# Show memory in specific units
btm --memory_legend="MiB"

# Hide specific widgets
btm --hide_table_gap
```

### Interface Customization
```bash
# Use specific color scheme
btm --color gruvbox

# Set custom temperature type
btm -F  # Fahrenheit
btm -C  # Celsius
btm -K  # Kelvin

# Disable mouse support
btm --no_mouse
```

## Interactive Controls

### Navigation
- **Arrow Keys**: Navigate between widgets
- **Tab/Shift+Tab**: Cycle through widgets
- **Enter**: Enter widget selection mode
- **Esc**: Exit selection mode or quit

### Process Management
- **dd**: Kill selected process
- **Tab**: Switch between process list and details
- **s**: Sort processes
- **i**: Toggle case sensitivity in search
- **/**:  Search processes

### View Controls
- **t**: Toggle tree mode for processes
- **g**: Group processes by name
- **f**: Freeze/unfreeze display updates
- **+/-**: Zoom in/out on graphs
- **=**: Reset zoom

### Widget Management
- **?**: Show help
- **q**: Quit application
- **Ctrl+c**: Force quit
- **Ctrl+r**: Reset display

## Widget Types

### Process Widget
- Process list with PID, name, CPU%, memory%
- Tree view showing parent-child relationships
- Process grouping by name
- Search and filter capabilities
- Kill process functionality

### CPU Widget
- Real-time CPU usage graphs
- Multi-core CPU display
- CPU percentage and frequency
- Load average information

### Memory Widget
- RAM and swap usage
- Memory usage over time
- Available/used memory breakdown
- Memory percentage display

### Network Widget
- Network I/O rates
- Upload/download speeds
- Total data transferred
- Network interface information

### Disk Widget
- Disk usage by mount point
- Disk I/O rates
- Read/write operations
- Available space information

### Temperature Widget
- CPU and component temperatures
- Temperature history graphs
- Configurable temperature units
- Thermal monitoring

## Configuration

### Command Line Options
```bash
# Configuration file location
btm --config ~/.config/bottom/bottom.toml

# Override default colors
btm --color default-light

# Set update rate
btm --rate 2000

# Hide specific widgets
btm --hide_avg_cpu
```

### Sample Configuration (bottom.toml)
```toml
[flags]
hide_avg_cpu = true
temperature_type = "celsius"
rate = 1000
group_processes = true
tree = true

[colors]
cpu_core_colors = ["Red", "Green", "Blue", "Yellow"]
border_color = "White"
highlighted_border_color = "Cyan"
```

## Use Cases

### Development Monitoring
```bash
# Monitor build processes
btm

# Track resource usage during compilation
# Monitor memory leaks in applications
# Analyze performance bottlenecks
```

### System Administration
```bash
# Monitor server performance
btm -b

# Track system health
# Identify resource-heavy processes
# Monitor network activity
```

### Performance Analysis
```bash
# Long-term monitoring
btm --rate 5000

# Detailed process analysis
# Resource utilization tracking
# System optimization insights
```

## Installation
Modern system monitor with customizable interface and real-time resource tracking.
Provides comprehensive system information with intuitive graphical interface.

## Dependencies
None - standalone executable with built-in system monitoring capabilities.

## Performance Features
- Low system overhead
- Efficient data collection
- Configurable update rates
- Memory-efficient display
- Cross-platform compatibility

---
*Part of PORTX Portable Development Environment*