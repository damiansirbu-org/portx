# PORTX - Portable POSIX Environment for Windows

A complete, portable POSIX toolkit built on Git Bash with 538 Windows-native command-line tools. Zero installation, zero dependencies, enterprise-friendly.

## Architecture

PORTX transforms Git for Windows into a comprehensive POSIX environment using a layered architecture:

**Foundation Layer**: Git Bash (MinGW64) provides the core POSIX shell environment with 284 Unix utilities (ls, grep, awk, sed, tar, curl, ssh)

**Enhancement Layer**: 44 modern CLI tools (ripgrep, bat, fzf, jq, micro, 7za) for improved productivity

**Professional Layer**: 210 enterprise tools spanning cloud platforms (AWS CLI, Azure CLI), container orchestration (Kubernetes, Docker), infrastructure (Terraform, monitoring), security (ClamAV, YARA, osquery, nuclei), and system analysis (Microsoft SysInternals suite)

**Integration Layer**: Development tools (gcc, git-core, libraries) and system utilities for seamless interoperability

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

**System Analysis**: Microsoft SysInternals command-line tools (psinfo, handle, pslist, accesschk, procdump, strings) for Windows system diagnostics and troubleshooting

**Windows Automation**: NirCmd utility for Windows system control, automation, clipboard management, volume control, window management, and speech synthesis

**Text Processing**: Traditional Unix tools (grep, sed, awk) plus modern alternatives (ripgrep, bat, fd, sd), JSON/YAML processors (jq, yq)

**System Administration**: Process monitoring (btop), file management (7za), network utilities (curl, SSH), remote access tools

## Tool Discovery & Research Methodology

PORTX includes a comprehensive tool discovery system with scientifically curated documentation for all 538 tools:

### Discovery Interface

**Interactive Tool Finder** (`portx-find-tools`): Real-time search and browse interface using fzf with:
- Full-text search across tool names, categories, and descriptions
- Live preview with detailed usage examples
- Tool availability verification
- Category-based filtering and statistics

**Category Browser** (`portx-category`): Organized navigation through 18 professional categories:
- Network Utilities, Security Tools, Development Tools, Database Management
- Text Processing, System Administration, Cryptography, Cloud Platforms
- Container Orchestration, Infrastructure as Code, and specialized tool suites

### Research & Curation Process

**Systematic Tool Analysis**: Each of the 538 tools underwent individual research:
1. **Source Documentation Review**: Official manuals, GitHub repositories, vendor documentation
2. **Functional Classification**: Categorization based on primary use case and professional domain
3. **Usage Pattern Analysis**: Real-world command examples and common workflows
4. **Compatibility Verification**: Windows-native execution testing and dependency analysis

**Quality Assurance Standards**:
- **Zero Generic Descriptions**: Every tool has specific, researched functionality descriptions
- **Comprehensive Examples**: 5-10 practical usage examples per tool with real commands
- **Professional Categorization**: Industry-standard taxonomy aligned with DevOps and enterprise workflows
- **Continuous Validation**: Automated availability checking and path verification

**Data Structure**: Tools database maintained in pipe-delimited format:
```
tool_name|category|full_path|detailed_description|usage_examples
```

**Extraction Methodology**: Automated deep-scan algorithm traversing 53 directories with 4-level depth analysis:
- Minimum 1 executable per directory requirement
- PATH optimization for 284 total executables
- Smart caching system with regeneration triggers
- Integration with Git Bash environment variables

This scientific approach ensures PORTX provides enterprise-grade tool discovery with professional documentation standards comparable to commercial development environments.

## Screenshots

<div align="center">

![screenshot.2](doc-portx/pic/screenshot.2.jpg)
![screenshot.3](doc-portx/pic/screenshot.3.jpg)
![screenshot.4](doc-portx/pic/screenshot.4.jpg)

![screenshot.5](doc-portx/pic/screenshot.5.jpg)
![screenshot.6](doc-portx/pic/screenshot.6.jpg)
![screenshot.7](doc-portx/pic/screenshot.7.jpg)

![screenshot.9](doc-portx/pic/screenshot.9.jpg)
![screenshot.10](doc-portx/pic/screenshot.10.jpg)
![screenshot.11](doc-portx/pic/screenshot.11.jpg)

![screenshot.12](doc-portx/pic/screenshot.12.jpg)
![screenshot.13](doc-portx/pic/screenshot.13.jpg)
![screenshot.14](doc-portx/pic/screenshot.14.jpg)

![screenshot.15](doc-portx/pic/screenshot.15.jpg)
![screenshot.16](doc-portx/pic/screenshot.16.jpg)
![screenshot.17](doc-portx/pic/screenshot.17.jpg)

</div>

## Quick Start

1. Extract PORTX to any directory
2. Run `portx.bat` to launch the environment
3. Access tools via standard Unix commands or Windows paths
4. Use `portx-tools find` for interactive tool discovery

## Technical Specifications

**Shell Environment**: Bash 4.4+ with POSIX compatibility layer
**Home Directory**: Portable user environment with SSH, Git configuration
**PATH Management**: Hierarchical tool discovery across bin/, bin-ext/, bin-tools/
**File System**: Unix-style paths with Windows compatibility layer
**Process Management**: Native Windows process handling with Unix signals

PORTX delivers enterprise-grade Unix functionality on Windows without the complexity or security concerns of traditional emulation approaches.