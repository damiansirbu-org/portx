# PORTX - Portable POSIX Environment for Windows

A complete, portable POSIX toolkit built on Git Bash with 494 Windows-native command-line tools. Zero installation, zero dependencies, enterprise-friendly.

## Architecture

PORTX transforms Git for Windows into a comprehensive POSIX environment using a layered architecture:

**Foundation Layer**: Git Bash (MinGW64) provides the core POSIX shell environment with 272 Unix utilities (ls, grep, awk, sed, tar, curl, ssh)

**Enhancement Layer**: 44 modern CLI tools (ripgrep, bat, fzf, jq, micro, 7za) for improved productivity

**Professional Layer**: 127 enterprise tools spanning cloud platforms (AWS CLI, Azure CLI), container orchestration (Kubernetes, Docker), infrastructure (Terraform, monitoring), and security (ClamAV, YARA, osquery, nuclei)

**Integration Layer**: 48 development tools (gcc, git-core, libraries) plus 2 system binaries for seamless interoperability

All tools are Windows-native executables with no external dependencies or DLL requirements.

## Key Advantages

**Enterprise Compatible**: No installation required, no registry entries, no administrative privileges needed. Works on locked-down corporate environments.

**Performance**: Native Windows executables without emulation layers. No cygwin1.dll or msys-2.0.dll dependencies.

**Portability**: Self-contained environment runs from any directory. Consistent toolset across different Windows machines.

**Completeness**: Full POSIX shell environment with modern tooling. Covers development, DevOps, security, and system administration workflows.

**Integration**: Tools work together seamlessly through proper PATH configuration and shared environment variables.

## Tool Categories

**Development**: Git, GCC compiler suite, text editors (micro, helix), build tools (make), language runtimes

**DevOps**: AWS CLI, Azure CLI, Terraform, Kubernetes (kubectl, helm, k9s), Docker Compose, monitoring tools

**Security**: ClamAV antivirus, YARA malware detection, osquery endpoint monitoring, hash utilities (hashdeep, ssdeep), network scanning (nuclei)

**Text Processing**: Traditional Unix tools (grep, sed, awk) plus modern alternatives (ripgrep, bat), JSON/YAML processors (jq, yq)

**System Administration**: Process monitoring (btop), file management (7za), network utilities (curl, SSH), remote access tools

## Quick Start

1. Extract PORTX to any directory
2. Run `portx.bat` to launch the environment
3. Access tools via standard Unix commands or Windows paths
4. Use `portx wiki` for comprehensive tool documentation

## Technical Specifications

**Shell Environment**: Bash 4.4+ with POSIX compatibility layer
**Home Directory**: Portable user environment with SSH, Git configuration
**PATH Management**: Hierarchical tool discovery across bin/, bin-ext/, bin-tools/
**File System**: Unix-style paths with Windows compatibility layer
**Process Management**: Native Windows process handling with Unix signals

PORTX delivers enterprise-grade Unix functionality on Windows without the complexity or security concerns of traditional emulation approaches.