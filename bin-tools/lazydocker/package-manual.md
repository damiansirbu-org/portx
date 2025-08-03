# Lazydocker Package Manual

## Package Information
- **Package Name**: lazydocker
- **Category**: Containers
- **Type**: Docker Terminal UI
- **License**: MIT

## Description
Simple terminal UI for Docker and docker-compose management.

Interactive terminal interface for managing Docker containers, images, volumes, and networks.
Provides visual Docker management with keyboard shortcuts and real-time monitoring capabilities.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| lazydocker.exe | Interactive Docker management interface | Manage Docker resources with terminal UI |

## Common Usage Examples

### Basic Docker Management
```bash
# Launch lazydocker
lazydocker

# Launch with specific Docker host
lazydocker -h tcp://remote-host:2376

# Launch with custom config
lazydocker --config ~/.config/lazydocker/config.yml

# Debug mode
lazydocker --debug
```

## Interface Overview

### Main Panels
- **Containers**: Running and stopped containers
- **Images**: Available Docker images
- **Volumes**: Docker volumes and their usage
- **Networks**: Docker networks and connections
- **Services**: Docker Compose services (when available)

### Navigation
- **Tab**: Switch between main panels
- **j/k**: Navigate up/down within panels
- **h/l**: Navigate left/right between sub-panels
- **Enter**: Interact with selected item
- **Esc**: Go back/cancel

## Container Management

### Container Operations
```bash
# Container actions (when container selected):
Enter           # View container details
d               # Remove container
s               # Stop container
r               # Restart container
p               # Pause/unpause container
a               # Attach to container
e               # Execute command in container
l               # View logs
```

### Container Monitoring
```bash
# Monitoring features:
R               # Refresh container list
f               # Follow logs in real-time
t               # Toggle timestamps in logs
w               # Wrap/unwrap log lines
```

### Container Interaction
```bash
# Interactive operations:
a               # Attach to running container
e               # Execute shell in container
c               # Copy files from container
```

## Image Management

### Image Operations
```bash
# Image actions (when image selected):
Enter           # View image details
d               # Remove image
f               # Force remove image
i               # Inspect image
h               # View image history
t               # Tag image
p               # Push image to registry
```

### Image Information
```bash
# Image details available:
- Image ID and tags
- Size and creation date
- Layer information
- Environment variables
- Exposed ports
- Entry points and commands
```

## Volume and Network Management

### Volume Operations
```bash
# Volume actions:
Enter           # View volume details
d               # Remove volume
p               # Prune unused volumes
i               # Inspect volume
```

### Network Operations
```bash
# Network actions:
Enter           # View network details
d               # Remove network
i               # Inspect network configuration
c               # View connected containers
```

## Docker Compose Integration

### Service Management
```bash
# Compose service actions:
u               # Compose up
d               # Compose down
r               # Restart service
s               # Stop service
l               # View service logs
e               # Execute in service container
```

### Compose Operations
```bash
# Compose project management:
U               # Compose up (recreate)
D               # Compose down (remove volumes)
P               # Compose pull
B               # Compose build
```

## Log Management

### Log Viewing
```bash
# Log operations:
l               # View container logs
f               # Follow logs (tail -f)
t               # Toggle timestamps
w               # Toggle word wrap
/               # Search in logs
n/N             # Next/previous search result
```

### Log Configuration
```bash
# Log display options:
- Real-time log streaming
- Timestamp display toggle
- Word wrapping control
- Search and highlight
- Color-coded output
```

## System Information

### Docker System Stats
```bash
# System monitoring:
- Container resource usage
- Image storage utilization
- Volume space consumption
- Network activity overview
- System-wide Docker info
```

### Resource Monitoring
```bash
# Resource information displayed:
- CPU usage per container
- Memory consumption
- Network I/O statistics
- Disk usage by volumes
- Container health status
```

## Configuration and Customization

### Configuration File (~/.config/lazydocker/config.yml)
```yaml
gui:
  scrollHeight: 2
  language: 'en'
  theme:
    activeBorderColor:
      - white
      - bold
    inactiveBorderColor:
      - cyan
    optionsTextColor:
      - blue
  returnImmediately: false
  wrapMainPanel: true

docker:
  composeCommand: 'docker-compose'
  rootlessCommand: 'rootless-docker'

stats:
  graphs:
    - caption: "CPU (%)"
      statPath: "DerivedStats.CPUPercentage"
      color: "blue"
    - caption: "Memory (%)"
      statPath: "DerivedStats.MemoryPercentage"
      color: "green"
```

### Custom Key Bindings
```yaml
keybinding:
  universal:
    quit: 'q'
    return: '<esc>'
    quitWithoutChanges: 'Q'
    togglePanel: '<tab>'
    prevItem: '<up>'
    nextItem: '<down>'
    prevPage: ','
    nextPage: '.'
    scrollLeft: 'H'
    scrollRight: 'L'
```

### Theme Customization
```yaml
gui:
  theme:
    activeBorderColor:
      - white
      - bold
    inactiveBorderColor:
      - cyan
    selectedLineBgColor:
      - blue
    selectedRangeBgColor:
      - blue
    cherryPickedCommitBgColor:
      - cyan
    cherryPickedCommitFgColor:
      - blue
```

## Advanced Features

### Docker Context Support
```bash
# Multiple Docker contexts
- Automatically detects Docker contexts
- Switch between local and remote Docker hosts
- Support for Docker Machine environments
- SSH tunnel support for remote connections
```

### Bulk Operations
```bash
# Bulk management:
Space           # Select multiple items
a               # Select all items
A               # Deselect all items
d               # Delete selected items
```

### Filtering and Search
```bash
# Filtering capabilities:
/               # Filter/search current view
Ctrl+r          # Reset filters
?               # Show help and shortcuts
```

## Workflow Integration

### Development Workflow
```bash
# Typical development usage:
1. Launch lazydocker
2. Navigate to Services (docker-compose)
3. Start development stack with 'u'
4. Monitor logs with 'l'
5. Debug containers with 'e' (exec)
6. Clean up with 'd' when done
```

### Debugging Workflow
```bash
# Container debugging:
1. Identify problematic container
2. View logs with 'l'
3. Execute shell with 'e'
4. Check container stats
5. Restart container with 'r'
```

### Cleanup Workflow
```bash
# System cleanup:
1. Navigate to Images panel
2. Remove unused images with 'd'
3. Navigate to Volumes panel
4. Prune unused volumes with 'p'
5. Check system stats
```

## Integration with Other Tools

### Command Line Integration
```bash
# Use alongside Docker CLI
docker ps                    # List containers in CLI
lazydocker                   # Manage in UI

# Combine with docker-compose
docker-compose up -d         # Start services
lazydocker                   # Monitor and manage
```

### IDE Integration
```bash
# Terminal integration
# Can be launched from IDE terminal
# Works with VS Code, IntelliJ, etc.
# Supports tmux/screen sessions
```

## Use Cases

### Local Development
- Docker Compose service management
- Container log monitoring
- Quick container cleanup
- Development environment management

### System Administration
- Docker host monitoring
- Container resource usage analysis
- Image and volume cleanup
- Network troubleshooting

### DevOps Operations
- Multi-container application management
- Deployment monitoring
- Resource optimization
- Incident response

### Learning and Training
- Visual Docker concept learning
- Interactive Docker exploration
- Container behavior understanding
- Docker best practices demonstration

## Installation
Interactive Docker management tool with terminal-based interface.
Essential for efficient Docker container, image, and resource management.

## Dependencies
- Docker Engine installed and running
- Docker CLI tools accessible
- docker-compose (optional, for compose features)
- Terminal with color support for optimal experience

## Performance Features
- Real-time container monitoring
- Efficient Docker API usage
- Responsive terminal interface
- Minimal resource overhead
- Fast container operations

---
*Part of PORTX Portable Development Environment*