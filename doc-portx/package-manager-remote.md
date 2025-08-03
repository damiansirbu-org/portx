# PORTX Package Manager - Remote Repository Guide

## Complete Package Manager System

PORTX now has a **two-layer package management system**:

1. **`portx-pkg`** - Local package management and installation
2. **`portx-repo`** - Remote repository management and downloads

## Quick Start with Remote Packages

```bash
# 1. Add your GitHub repository
portx-repo add-repo https://api.github.com/repos/YOUR-USERNAME/portx/releases

# 2. Update package index from GitHub releases
portx-repo update

# 3. Search for packages (searches both local and remote)
portx-pkg search kubectl
portx-pkg search docker

# 4. Install packages (downloads from GitHub if not local)
portx-pkg install kubectl      # Downloads from GitHub, extracts, installs
portx-pkg install terraform

# 5. List what's installed
portx-pkg list
```

## Repository Management Commands

### `portx-repo add-repo <url>`
Add a GitHub repository as a package source:

```bash
# Add the main PORTX repository
portx-repo add-repo https://api.github.com/repos/damiansirbu/portx/releases

# Add your own repository
portx-repo add-repo https://api.github.com/repos/yourname/packages/releases
```

### `portx-repo update`
Fetch package index from all configured repositories:

```bash
portx-repo update
# Updating package index...
#   Fetching from portx-main...
# ✓ Package index updated: 25 packages available
```

### `portx-repo search <query>`
Search only remote packages:

```bash
portx-repo search kubectl
portx-repo search docker
```

### `portx-repo install <package>`
Download and install package from remote repository:

```bash
portx-repo install kubectl
# Installing kubectl from remote repository...
#   Source: kubectl-1.30.0-windows-amd64.zip
#   Size: 45MB
# 
# Downloading...
# ████████████████████████████████████████ 100%
# Extracting...
# ✓ Package 'kubectl' installed successfully
```

### `portx-repo list-remote`
List all packages available in remote repositories:

```bash
portx-repo list-remote
```

### `portx-repo list-repos`
Show configured repositories:

```bash
portx-repo list-repos
# Configured repositories:
#   portx-main - https://api.github.com/repos/damiansirbu/portx/releases
```

## How Remote Installation Works

### 1. **GitHub Releases Detection**
The system fetches your GitHub releases via the API:
```
GET https://api.github.com/repos/YOUR-USER/portx/releases
```

### 2. **Package Archive Discovery**
Automatically finds `.zip` and `.tar.gz` files in releases:
- `kubectl-1.30.0-windows-amd64.zip`
- `terraform-1.8.2-windows-amd64.zip`
- `docker-compose-2.24.0.zip`

### 3. **Smart Package Naming**
Extracts package names from filenames:
```
kubectl-1.30.0-windows-amd64.zip  →  kubectl
terraform-1.8.2.zip              →  terraform
docker-compose-v2.24.0.zip        →  docker-compose
```

### 4. **Download and Extract**
```bash
# Downloads to cache
C:/App/PORTX/.portx/cache/kubectl-1.30.0.zip

# Extracts to packages directory
C:/App/PORTX/packages/kubectl/
├── kubectl.exe
└── package-manual.md  (auto-generated)
```

### 5. **Integration with PORTX**
- Package automatically available in PATH
- Discovered by `portx-tools`
- Tracked by package manager

## GitHub Repository Setup

To host packages on GitHub, create releases with zip files:

### **Repository Structure:**
```
your-repo/
├── .github/workflows/
│   └── build-packages.yml    # Build automation
├── packages/
│   ├── kubectl/
│   │   └── kubectl.exe
│   ├── terraform/
│   │   └── terraform.exe
│   └── helm/
│       └── helm.exe
└── scripts/
    └── package-release.sh     # Release automation
```

### **Release Naming Convention:**
```
Release Tag: v1.0.0
Assets:
  - kubectl-1.30.0-windows-amd64.zip
  - terraform-1.8.2-windows-amd64.zip
  - helm-3.14.0-windows-amd64.zip
```

### **Package Zip Contents:**
```
kubectl-1.30.0-windows-amd64.zip
├── kubectl.exe                    # Main executable
├── package-manual.md              # Documentation (optional)
└── LICENSE                        # License file (optional)
```

## Unified Search Experience

`portx-pkg search` now searches **both** local and remote packages:

```bash
portx-pkg search docker
# Searching for 'docker'...
# 
# Local packages:
#   docker-compose [installed]
#   lazydocker [available locally]
# 
# Remote packages:
#   docker-cli [remote only]
#     Repository: portx-main, Size: 35MB
#   docker-buildx [remote only]  
#     Repository: portx-main, Size: 12MB
```

**Status indicators:**
- `[installed]` - Package is installed
- `[available locally]` - Package exists locally but not installed
- `[remote only]` - Package only available from remote repository

## Installation Priority

When you run `portx-pkg install <package>`:

1. **Check if installed** - Skip if already installed
2. **Check local packages** - Install from local if available
3. **Check remote repositories** - Download and install if found
4. **Report not found** - Show search suggestions

```bash
portx-pkg install kubectl
# Package 'kubectl' not found locally
# Checking remote repositories...
# Installing kubectl from remote repository...
# ✓ Package installed from remote repository
```

## Caching System

**Download Cache:**
```
C:/App/PORTX/.portx/cache/
├── package-index.json           # Remote package index
├── portx-main-releases.json     # GitHub API responses
├── kubectl-1.30.0.zip           # Downloaded packages (temporary)
└── terraform-1.8.2.zip
```

**Clear cache:**
```bash
portx-repo cache-clear
```

## Configuration Files

**Repository Configuration:**
```json
{
  "repositories": [
    {
      "name": "portx-main",
      "url": "https://api.github.com/repos/damiansirbu/portx/releases",
      "type": "github-releases"
    }
  ],
  "last_update": "2025-08-03T13:45:22Z"
}
```

**Package Index:**
```json
{
  "packages": [
    {
      "name": "kubectl",
      "repository": "portx-main",
      "download_url": "https://github.com/user/repo/releases/download/v1.0/kubectl.zip",
      "filename": "kubectl-1.30.0.zip",
      "size": 47185920,
      "updated_at": "2025-08-03T12:00:00Z",
      "type": "archive"
    }
  ],
  "last_update": "2025-08-03T13:45:22Z"
}
```

## Examples

### **Install Development Tools from Remote:**
```bash
# Update package index
portx-repo update

# Install container tools
portx-pkg install kubectl       # From remote
portx-pkg install helm          # From remote
portx-pkg install docker-cli    # From remote

# Install editors
portx-pkg install vscode-cli    # From remote
portx-pkg install neovim        # From remote

# Check what was installed
portx-pkg list
```

### **Search and Install Workflow:**
```bash
# Search for Git tools
portx-pkg search git
# Shows both local and remote packages

# Get info before installing
portx-repo search git-lfs
portx-pkg install git-lfs       # Downloads from GitHub

# Verify installation
portx-pkg list | grep git
```

### **Multiple Repository Support:**
```bash
# Add multiple package sources
portx-repo add-repo https://api.github.com/repos/user1/packages/releases
portx-repo add-repo https://api.github.com/repos/user2/tools/releases

# Update from all repositories
portx-repo update

# Search across all sources
portx-pkg search monitoring
```

## Troubleshooting

### **Package Not Found:**
```bash
# Update package index
portx-repo update

# Search with different terms
portx-pkg search kube
portx-pkg search k8s

# Check repository configuration
portx-repo list-repos
```

### **Download Fails:**
```bash
# Check network connectivity
curl -I https://api.github.com/repos/damiansirbu/portx/releases

# Clear cache and retry
portx-repo cache-clear
portx-repo update
```

### **Missing Dependencies:**
```bash
# Ensure required tools are available
which curl    # Required for downloads
which unzip   # Required for extraction
which jq      # Required for JSON parsing (optional but recommended)
```

## Future Enhancements

**Planned features:**
- **Version constraints:** `portx-pkg install kubectl@1.30.0`
- **Dependency resolution:** Automatic dependency installation
- **Package signing:** GPG signature verification
- **Delta updates:** Only download changed files
- **Private repositories:** Authentication support
- **Package manifests:** Rich metadata and dependency information

This gives you a **complete package management solution** that can fetch packages from your GitHub repository automatically! 🚀