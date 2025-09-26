# PORTX 2.0

Universal portable package manager for cross-platform tool deployment across Windows, WSL, Cygwin, MSYS2, and Linux containers.

## Overview

PORTX 2.0 manages 200+ portable development, security, and system tools through sophisticated wrapper generation and environment detection. The system provides seamless cross-platform access to tools while maintaining native performance and compatibility.

## Quick Start

```bash
# Import all packages
./portx.sh import

# Import specific package
./portx.sh import git

# Clean import (remove existing wrappers)
./portx.sh import --clean
```

## Key Features

- **Universal Compatibility**: Windows, WSL, Cygwin, MSYS2, Linux containers
- **Zero Dependencies**: PowerShell Core-based execution engine
- **Automatic Wrappers**: POSIX and Windows wrappers generated per tool
- **Environment Detection**: Intelligent path resolution across platforms
- **Schema Validation**: JSON-validated package configurations
- **200+ Tools**: Development, security, container, and system utilities

## Architecture

The system consists of:

- **Entry Points**: `portx.sh` (bash) and `portx.cmd` (Windows batch)
- **Core Engine**: PowerShell-based import manager (`ps/portx-import.ps1`)
- **Package System**: JSON-configured packages with validation
- **Wrapper Layer**: Auto-generated cross-platform executable wrappers
- **PATH Management**: Intelligent environment-aware path construction

## Tool Categories

- **Development**: git, node, go, python, java, helm, terraform
- **Security**: nmap, nuclei, trivy, rustscan, gitleaks, semgrep
- **System**: btop, dust, hyperfine, procs, bandwhich
- **Search/Text**: ripgrep, fd, ast-grep, choose, miller, dasel
- **Containers**: docker-compose, podman, dive, lazydocker, k9s

## Documentation

- **[Architecture](architecture.md)**: System design, components, and cross-platform mechanisms
- **[Implementation](implementation.md)**: Technical details, package structure, and development guide

## Requirements

- PowerShell Core (included in `packages/powershell-core/`)
- Windows-compatible environment (WSL, Cygwin, MSYS2, or native Windows)

## License

Proprietary - PORTX Universal Toolchain System