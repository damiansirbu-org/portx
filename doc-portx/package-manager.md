# PORTX Package Manager Usage Guide

## Quick Start

The PORTX package manager (`portx-pkg`) provides a simple interface to manage your PORTX tools and packages.

```bash
# Check system status
portx-pkg status

# Search for packages
portx-pkg search docker
portx-pkg search kubernetes

# Get package information
portx-pkg info kubectl
portx-pkg info terraform

# Install packages
portx-pkg install kubectl
portx-pkg install terraform
portx-pkg install docker-compose

# List installed packages
portx-pkg list

# Remove packages
portx-pkg remove kubectl
```

## Commands

### `portx-pkg status`
Shows PORTX package manager system status:
- Available packages count
- Installed packages count  
- System health checks

### `portx-pkg search <query>`
Search for packages by name. Case-insensitive substring matching.

**Examples:**
```bash
portx-pkg search k8          # Finds k8, k9s packages
portx-pkg search docker      # Finds docker-compose, lazydocker
portx-pkg search terraform   # Finds terraform package
portx-pkg search git         # Finds git-extras, gitui, lazygit
```

### `portx-pkg info <package>`
Show detailed information about a package:
- Installation status
- Package location
- Number of executables
- Disk usage
- Description from package manual

**Example:**
```bash
portx-pkg info kubectl
```

### `portx-pkg install <package>`
Install a package. The package files already exist in PORTX - this command:
- Records the installation in the database
- Shows available executables
- Displays documentation path

**Example:**
```bash
portx-pkg install kubectl
# ✓ Package 'kubectl' installed successfully
# 📄 Documentation: C:/App/PORTX/packages/kubectl/package-manual.md
# 🔧 Executables available:
#    kubectl
```

### `portx-pkg list`
List all installed packages with installation timestamps.

### `portx-pkg remove <package>`
Remove an installed package:
- Removes installation record from database
- Package files remain in place
- Can be re-installed later

### `portx-pkg available`
List all available packages in the PORTX repository.

## Package Structure

PORTX packages live in `C:/App/PORTX/packages/` with this structure:

```
packages/
├── kubectl/
│   ├── kubectl.exe           # Main executable
│   └── package-manual.md     # Documentation
├── terraform/
│   ├── terraform.exe
│   └── package-manual.md
└── docker-compose/
    ├── docker-compose.exe
    └── package-manual.md
```

## Installation Database

Installation records are stored in `C:/App/PORTX/.portx/installed.json`:

```json
{
  "packages": [
    {
      "name": "kubectl",
      "path": "C:/App/PORTX/packages/kubectl",
      "installed_at": "2025-08-03T13:26:12Z",
      "version": "latest"
    }
  ]
}
```

## Integration with PORTX Tools

Installed packages are automatically available through PORTX's existing tool discovery system:

- **Tool caching**: Executables are discovered by `portx-tools`
- **PATH integration**: Available in shell sessions
- **Documentation**: Each package includes `package-manual.md`

## Examples

### Installing Development Tools
```bash
# Install container tools
portx-pkg install docker-compose
portx-pkg install kubectl
portx-pkg install helm

# Install text editors
portx-pkg install micro
portx-pkg install helix

# Install monitoring tools
portx-pkg install k9s
portx-pkg install lazydocker
```

### Managing Package Information
```bash
# Find Git-related tools
portx-pkg search git

# Get info before installing
portx-pkg info lazygit

# Install if suitable
portx-pkg install lazygit

# Check what's installed
portx-pkg list
```

### Package Exploration
```bash
# See all available packages
portx-pkg available

# Search by category
portx-pkg search monitor     # monitoring tools
portx-pkg search editor      # text editors
portx-pkg search container   # container tools
```

## Package Manager Philosophy

Following **ARCHITECT** principles:

### **1. Simplicity Over Complexity**
- No complex dependency resolution (yet)
- Simple JSON database
- Direct file operations
- Clear, predictable behavior

### **2. Performance First**
- Fast search (filesystem-based)
- Minimal overhead
- No network operations for installed packages
- Efficient package discovery

### **3. Domain Separation**
- Package management separate from tool discovery
- Clear separation between installation tracking and package usage
- Modular design for future enhancements

## Current Limitations

**Version 1.0 Simplifications:**
- No version management (all packages are "latest")
- No dependency resolution
- No package updates (reinstall to update)
- No package removal from filesystem (only tracking)
- No network package repositories (local only)

**Future Enhancements:**
- Semantic versioning support
- Dependency resolution with minimal version selection
- Package updates with delta downloads
- Remote package repositories
- Package integrity verification

## Troubleshooting

### Cannot Write to Database
```bash
# Create database directory
mkdir -p C:/App/PORTX/.portx

# Check permissions
ls -la C:/App/PORTX/.portx/
```

### Package Not Found
```bash
# Check available packages
portx-pkg available

# Search with different terms
portx-pkg search kubectl
portx-pkg search k8
```

### Installation Issues
```bash
# Check system status
portx-pkg status

# Verify package exists
portx-pkg info <package-name>
```

For more help, see the individual package documentation in `packages/<name>/package-manual.md`.