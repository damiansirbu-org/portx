#!/bin/bash
# PORTX Package Manager Shell Script
# Portable POSIX Environment for Windows

# Get script directory to use relative paths for tools
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PORTX_ROOT="$SCRIPT_DIR"

# Tool paths (using tools from portx/bin)
CURL="$SCRIPT_DIR/bin/curl.exe"
WGET="$SCRIPT_DIR/bin/wget.exe"
SEVENZIP="$SCRIPT_DIR/bin/7za64.exe"
GREP="$SCRIPT_DIR/bin/grep.exe"
MKDIR="mkdir"
RM="rm"

# Configuration
PACKAGES_REPO="https://github.com/damiansirbu-org/portx-packages/raw/main/releases/windows-amd64"
PACKAGES_DIR="/c/App/PORTX/packages"
BIN_DIR="/c/App/PORTX/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
set -e
trap 'echo -e "${RED}❌ Error occurred on line $LINENO${NC}"' ERR

# Logging function
log() {
    echo -e "${BLUE}[PORTX]${NC} $1"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if required tools exist
check_tools() {
    local missing_tools=()
    
    if [[ ! -f "$CURL" ]]; then
        missing_tools+=("curl.exe")
    fi
    
    if [[ ! -f "$SEVENZIP" ]]; then
        missing_tools+=("7za64.exe")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
}

# Initialize directories
init_dirs() {
    mkdir -p "$PACKAGES_DIR" 2>/dev/null || true
    mkdir -p "$BIN_DIR" 2>/dev/null || true
}

# Show package manager status
status() {
    log "PORTX Package Manager Status"
    echo
    
    echo "🏠 PORTX Root: $PORTX_ROOT"
    echo "📦 Packages Directory: $PACKAGES_DIR"
    echo "🔧 Binary Directory: $BIN_DIR"
    echo "🌐 Repository: $PACKAGES_REPO"
    echo
    
    # Check directories
    if [[ -d "$PACKAGES_DIR" ]]; then
        local pkg_count=$(find "$PACKAGES_DIR" -maxdepth 1 -type d | wc -l)
        success "Packages directory exists ($((pkg_count - 1)) packages)"
    else
        warning "Packages directory does not exist"
    fi
    
    if [[ -d "$BIN_DIR" ]]; then
        local bin_count=$(find "$BIN_DIR" -name "*.exe" | wc -l)
        success "Binary directory exists ($bin_count executables)"
    else
        warning "Binary directory does not exist"
    fi
    
    # Check available tools
    echo
    log "Available Tools:"
    if [[ -f "$CURL" ]]; then
        echo "  ✅ curl.exe"
    else
        echo "  ❌ curl.exe"
    fi
    
    if [[ -f "$SEVENZIP" ]]; then
        echo "  ✅ 7za64.exe"
    else
        echo "  ❌ 7za64.exe"
    fi
    
    if [[ -f "$WGET" ]]; then
        echo "  ✅ wget.exe"
    else
        echo "  ⚠️  wget.exe (optional)"
    fi
}

# List available packages
list_available() {
    log "Fetching available packages from repository..."
    
    # This would require fetching package metadata
    # For now, show common packages that should be available
    echo
    echo "📋 Available Packages:"
    echo "  • ag - The Silver Searcher (fast text search)"
    echo "  • rg - ripgrep (ultra-fast text search)" 
    echo "  • jq - JSON processor"
    echo "  • yq - YAML processor"
    echo "  • fzf - Fuzzy finder"
    echo "  • micro - Modern terminal editor"
    echo "  • kubectl - Kubernetes command-line tool"
    echo "  • helm - Kubernetes package manager"
    echo "  • k9s - Kubernetes CLI dashboard"
    echo
    warning "Use 'portx install <package>' to install a package"
}

# List installed packages
list_installed() {
    log "Installed packages:"
    echo
    
    if [[ ! -d "$PACKAGES_DIR" ]]; then
        warning "No packages directory found"
        return
    fi
    
    local found_packages=false
    for pkg_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_dir" && ! "$pkg_dir" =~ /_zip$ ]]; then
            local pkg_name=$(basename "$pkg_dir")
            local version="unknown"
            
            # Try to read version from VERSION.md
            if [[ -f "$pkg_dir/VERSION.md" ]]; then
                version=$(cat "$pkg_dir/VERSION.md" | head -1 | tr -d '\r\n')
            fi
            
            echo "  📦 $pkg_name ($version)"
            found_packages=true
        fi
    done
    
    if [[ "$found_packages" == false ]]; then
        warning "No packages installed"
    fi
}

# Install a package
install_package() {
    local package_name="$1"
    
    if [[ -z "$package_name" ]]; then
        error "Package name required"
        echo "Usage: portx install <package_name>"
        exit 1
    fi
    
    log "Installing package: $package_name"
    
    # Create package directory
    local pkg_dir="$PACKAGES_DIR/$package_name"
    mkdir -p "$pkg_dir"
    
    # Try to download the package
    # This is a simplified version - in reality, we'd need to:
    # 1. Fetch package metadata to get exact filename and version
    # 2. Handle different package versions
    # 3. Check dependencies
    
    local zip_file="$pkg_dir/${package_name}.zip"
    local download_url="$PACKAGES_REPO/$package_name/${package_name}-latest-x64-windows.zip"
    
    log "Downloading from: $download_url"
    
    # Download with curl
    if ! "$CURL" -L "$download_url" -o "$zip_file" --silent --show-error; then
        error "Failed to download package $package_name"
        rm -rf "$pkg_dir"
        exit 1
    fi
    
    success "Downloaded $package_name"
    
    # Extract with 7zip
    log "Extracting package..."
    if ! "$SEVENZIP" x "$zip_file" -o"$pkg_dir" -y > /dev/null; then
        error "Failed to extract package $package_name"
        rm -rf "$pkg_dir"
        exit 1
    fi
    
    # Remove zip file after extraction
    rm "$zip_file"
    
    # Copy executables to bin directory
    log "Installing executables..."
    local exe_count=0
    for exe_file in "$pkg_dir"/*.exe; do
        if [[ -f "$exe_file" ]]; then
            local exe_name=$(basename "$exe_file")
            cp "$exe_file" "$BIN_DIR/"
            ((exe_count++))
            log "  → Installed $exe_name"
        fi
    done
    
    if [[ $exe_count -eq 0 ]]; then
        warning "No executables found in package"
    fi
    
    success "Package $package_name installed successfully"
}

# Remove a package
remove_package() {
    local package_name="$1"
    
    if [[ -z "$package_name" ]]; then
        error "Package name required"
        echo "Usage: portx remove <package_name>"
        exit 1
    fi
    
    local pkg_dir="$PACKAGES_DIR/$package_name"
    
    if [[ ! -d "$pkg_dir" ]]; then
        error "Package $package_name is not installed"
        exit 1
    fi
    
    log "Removing package: $package_name"
    
    # Remove executables from bin directory
    for exe_file in "$pkg_dir"/*.exe; do
        if [[ -f "$exe_file" ]]; then
            local exe_name=$(basename "$exe_file")
            local bin_exe="$BIN_DIR/$exe_name"
            if [[ -f "$bin_exe" ]]; then
                rm "$bin_exe"
                log "  → Removed $exe_name from bin"
            fi
        fi
    done
    
    # Remove package directory
    rm -rf "$pkg_dir"
    
    success "Package $package_name removed successfully"
}

# Show help
show_help() {
    echo "PORTX Package Manager"
    echo
    echo "Usage: portx.sh <command> [arguments]"
    echo
    echo "Commands:"
    echo "  status              Show package manager status"
    echo "  list                List installed packages"
    echo "  list available      List available packages"
    echo "  install <package>   Install a package"
    echo "  remove <package>    Remove a package"
    echo "  help               Show this help"
    echo
    echo "Examples:"
    echo "  portx.sh status"
    echo "  portx.sh install ag"
    echo "  portx.sh list"
    echo "  portx.sh remove ag"
}

# Main script logic
main() {
    # Check tools first
    check_tools
    
    # Initialize directories
    init_dirs
    
    # Parse command
    local command="${1:-help}"
    
    case "$command" in
        "status")
            status
            ;;
        "list")
            if [[ "$2" == "available" ]]; then
                list_available
            else
                list_installed
            fi
            ;;
        "install")
            install_package "$2"
            ;;
        "remove"|"uninstall")
            remove_package "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"