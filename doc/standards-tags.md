# PORTX Tool Taxonomy Standards (portx package tags)

## Overview

This document defines the standardized 4-dimensional taxonomy system for categorizing and tagging all tools in the PORTX portable development environment. This system enables powerful tool discovery and filtering for both human users and AI assistants.

## Taxonomy Dimensions

### Dimension 1: PURPOSE *(What the tool does)*

The primary function or action the tool performs:

- **analyze** - Code analysis, static analysis, pattern detection, inspection
- **build** - Compilation, building, packaging, assembling
- **convert** - Format conversion, transformation, encoding/decoding
- **debug** - Debugging, profiling, troubleshooting, diagnostics  
- **deploy** - Deployment, installation, distribution, publishing
- **develop** - Development support, scaffolding, generation, templates
- **manage** - Management, administration, configuration, orchestration
- **monitor** - Monitoring, observation, tracking, logging
- **process** - Data processing, manipulation, filtering, transformation
- **secure** - Security scanning, vulnerability detection, encryption
- **test** - Testing, validation, verification, quality assurance

### Dimension 2: DOMAIN *(What field/category)*

The technical domain or field the tool operates in:

- **cloud** - Cloud platforms, services, infrastructure (AWS, Azure, GCP)
- **code** - Source code, programming, development tools
- **database** - Database systems, SQL, data storage, queries
- **git** - Version control, Git operations, repository management
- **media** - Audio, video, images, multimedia processing
- **mobile** - Mobile development, iOS, Android, cross-platform
- **network** - Networking, protocols, connectivity, monitoring
- **security** - Cybersecurity, cryptography, vulnerability assessment
- **system** - Operating system, processes, performance, administration
- **web** - Web development, HTTP, browsers, web services

### Dimension 3: RUNTIME *(What it's built with/runs on)*

The technology stack or runtime environment:

- **bash** - Bash/shell scripts, Unix utilities
- **dotnet** - .NET runtime, C#, F#, VB.NET
- **go** - Go/Golang compiled binaries
- **java** - Java Virtual Machine, JVM languages
- **native** - Compiled native binaries (C/C++/Rust/etc)
- **node** - Node.js, JavaScript runtime
- **powershell** - PowerShell scripts and modules
- **python** - Python interpreter, Python packages
- **rust** - Rust compiled binaries
- **web** - Browser-based, HTML/CSS/JavaScript

### Dimension 4: TARGET *(What it operates on)*

The type of resources or entities the tool works with:

- **cloud** - Cloud resources, services, deployments
- **code** - Source code files, repositories, projects
- **containers** - Docker containers, Kubernetes pods, images
- **databases** - Database systems, tables, queries, data
- **files** - File system, documents, archives, data files
- **media** - Audio/video files, images, multimedia content
- **network** - Network connections, protocols, traffic, endpoints
- **processes** - Running processes, system services, applications
- **systems** - Operating systems, hardware, infrastructure

## Tagging Guidelines

### Multi-Tag Support
- Tools can have **multiple tags per dimension** when appropriate
- Use comma-separated tags: `analyze,secure,detect`
- Be specific but avoid redundancy

### Tag Selection Rules
1. **Purpose**: Choose 1-3 most relevant primary functions
2. **Domain**: Select 1-2 main technical areas  
3. **Runtime**: Usually 1 tag, occasionally 2 for hybrid tools
4. **Target**: Choose 1-3 types of resources the tool operates on

### Consistency Requirements
- Use exact tag names as defined above (lowercase, no variations)
- Maintain consistent tagging across similar tools
- Document any new tags that emerge during classification

## PORTX Package.json Structure Reference

### Standard Package Structure
Every PORTX package follows this exact structure:

```json
{
  "name": "package-name",
  "version": "x.y.z", 
  "description": "Brief description of package purpose and functionality",
  "tools": [
    {
      "executable": "tool.exe",
      "description": "Detailed tool description with purpose and capabilities",
      "usage": "command examples\\nseparated by newlines\\nwith typical use cases",
      "dependencies": "native|windows|msys-runtime",
      "tags": ["purpose", "domain", "runtime", "target"]
    }
  ],
  "paths": [
    "./"
  ]
}
```

### Required Fields
- **name**: Package identifier (lowercase, hyphen-separated)
- **version**: Semantic version number
- **description**: Comprehensive package description
- **tools**: Array of tool objects (see Tool Structure)
- **paths**: Array of relative paths where executables are located

### Tool Structure
Each tool object must contain:
- **executable**: Exact executable filename (including .exe on Windows)
- **description**: Detailed description of tool purpose and capabilities
- **usage**: Multi-line usage examples separated by `\\n`
- **dependencies**: Runtime dependency type
- **tags**: Array of taxonomy tags (see 4-dimensional taxonomy)

### Dependency Types
- **native**: Compiled native binaries (C/C++/Rust/Go)
- **windows**: Windows-specific native executables
- **msys-runtime**: Requires MSYS2/MinGW runtime environment

### Invalid Fields
These fields are NOT supported and should never be used:
- ❌ `category` - Use tags array instead
- ❌ `aliases` - Not tracked in package.json
- ❌ `source` - Not a valid field
- ❌ `author` - Package-level metadata not supported
- ❌ `license` - Not tracked at package level
- ❌ `importType` - Invalid field
- ❌ `import` - Invalid field
- ❌ `architecture` - Not package metadata
- ❌ `platform` - Not package metadata
- ❌ `runtime` - Use tags instead
- ❌ `categories` - Use tags array instead
- ❌ `packageInfo` - Not a valid structure

## Implementation in package.json

Add tags array to each tool object following the 4-dimensional taxonomy:

```json
{
  "executable": "ffmpeg.exe",
  "description": "Universal multimedia converter and processor",
  "usage": "ffmpeg -i input.mp4 output.avi\\nffmpeg -i video.mp4 -vn audio.mp3",
  "dependencies": "native",
  "tags": ["convert", "process", "media", "native", "files"]
}
```

## Example Classifications

### Security Tool: YARA
```json
"tags": ["analyze", "secure", "detect", "security", "native", "files", "processes"]
```

### Container Tool: kubectl
```json
"tags": ["manage", "deploy", "monitor", "cloud", "containers", "native"]
```

### Network Monitor: bandwhich
```json
"tags": ["monitor", "analyze", "network", "system", "native", "processes"]
```

### Code Analysis: ast-grep
```json
"tags": ["analyze", "develop", "code", "native"]
```

## Usage Examples

### Human Queries
- "Show me all security analysis tools" → `purpose:analyze + domain:security`
- "Find Python-based code tools" → `runtime:python + domain:code`
- "Get native network monitoring tools" → `runtime:native + domain:network + purpose:monitor`

### AI Assistant Queries  
- "I need to debug container deployment issues" → `purpose:debug + domain:cloud,containers`
- "Find tools for processing media files" → `purpose:process + domain:media + target:files`
- "Security scan my codebase" → `purpose:secure,analyze + domain:security + target:code`

## Maintenance

### Regular Review
- Review taxonomy quarterly for new tool additions
- Update tags when tool functionality evolves
- Ensure consistency across package updates

### Extension Process
1. Identify need for new tag
2. Document rationale and scope
3. Update this standards document
4. Apply consistently across relevant tools
5. Update filtering and search logic

---

*This taxonomy system is based on comprehensive research of industry standards including SWEBOK knowledge areas, NIST tool classifications, and GitHub Awesome Lists community practices.*