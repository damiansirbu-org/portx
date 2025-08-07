#!/bin/bash
# PORTX Package Manager Shell Script
# Portable POSIX Environment for Windows

# Get script directory to use relative paths for tools
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Auto-discover PORTX_ROOT by looking for bin, home, mingw64 directories
find_portx_root() {
    local current_dir="$SCRIPT_DIR"
    
    # First check common PORTX installation locations
    local common_locations=(
        "/c/App/PORTX"
        "/c/PORTX"
        "/opt/PORTX"
        "/usr/local/PORTX"
    )
    
    for location in "${common_locations[@]}"; do
        if [[ -d "$location/bin" && -d "$location/home" && -d "$location/mingw64" ]]; then
            echo "$location"
            return 0
        fi
    done
    
    # Search upward from script directory
    while [[ "$current_dir" != "/" && "$current_dir" != "" ]]; do
        # Check if all required directories exist
        if [[ -d "$current_dir/bin" && -d "$current_dir/home" && -d "$current_dir/mingw64" ]]; then
            echo "$current_dir"
            return 0
        fi
        
        # Move up one directory
        current_dir="$(dirname "$current_dir")"
    done
    
    # If not found, return script directory as fallback
    echo "$SCRIPT_DIR"
    return 1
}

PORTX_ROOT=$(find_portx_root)

# Tool detection with hybrid approach: try PATH first, then local paths
detect_tool() {
    local tool_name="$1"
    local fallback_path="$2"
    
    # Try to find tool in PATH first (POSIX compliant)
    if command -v "$tool_name" >/dev/null 2>&1; then
        command -v "$tool_name"
    elif command -v "${tool_name}.exe" >/dev/null 2>&1; then
        command -v "${tool_name}.exe"
    elif [[ -n "$fallback_path" && -f "$fallback_path" ]]; then
        echo "$fallback_path"
    else
        return 1
    fi
}

# Initialize tool paths
CURL=$(detect_tool "curl" "$SCRIPT_DIR/bin/curl.exe")
WGET=$(detect_tool "wget" "$SCRIPT_DIR/bin/wget.exe")  
SEVENZIP=$(detect_tool "7za64" "$SCRIPT_DIR/bin/7za64.exe")
GREP=$(detect_tool "grep" "$SCRIPT_DIR/bin/grep.exe")
MKDIR="mkdir"
RM="rm"

# Configuration
PACKAGES_REPO="https://github.com/damiansirbu-org/portx-packages/raw/main/releases/windows-amd64"
PACKAGES_DIR="$PORTX_ROOT/packages"
BIN_DIR="$PORTX_ROOT/bin"

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
    
    # Check curl
    if [[ -z "$CURL" ]]; then
        missing_tools+=("curl")
    fi
    
    # Check 7zip
    if [[ -z "$SEVENZIP" ]]; then
        missing_tools+=("7za64")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
        error "Please ensure these tools are in PATH or install them to $SCRIPT_DIR/bin/"
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
    echo "📂 Script Directory: $SCRIPT_DIR"
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
    if [[ -n "$CURL" && -f "$CURL" ]]; then
        echo "  ✅ curl: $CURL"
    else
        echo "  ❌ curl: not found"
    fi
    
    if [[ -n "$SEVENZIP" && -f "$SEVENZIP" ]]; then
        echo "  ✅ 7za64: $SEVENZIP"
    else
        echo "  ❌ 7za64: not found"
    fi
    
    if [[ -n "$WGET" && -f "$WGET" ]]; then
        echo "  ✅ wget: $WGET"
    else
        echo "  ⚠️  wget: not found (optional)"
    fi
}

# Get available packages from GitHub
get_available_packages() {
    if ! command -v jq >/dev/null 2>&1; then
        return 1
    fi
    
    curl -s "https://api.github.com/repos/damiansirbu-org/portx-packages/contents/releases/windows-amd64" 2>/dev/null | \
        jq -r '.[] | select(.type == "dir") | .name' 2>/dev/null | sort
}

# Get installed packages from local directory
get_installed_packages() {
    if [[ ! -d "$PACKAGES_DIR" ]]; then
        return 1
    fi
    
    for pkg_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_dir" && ! "$pkg_dir" =~ /_zip$ && -f "$pkg_dir/package-manual.md" ]]; then
            # Check if package has executables
            if ls "$pkg_dir"/*.exe >/dev/null 2>&1; then
                basename "$pkg_dir"
            fi
        fi
    done | sort
}


# List packages with status (merged view)
list_merged() {
    log "PORTX Package Manager - All Packages"
    echo
    
    # Get both lists
    local available_packages installed_packages
    available_packages=$(get_available_packages)
    installed_packages=$(get_installed_packages)
    
    if [[ -z "$available_packages" ]]; then
        error "Failed to fetch available packages from GitHub API"
        echo "Showing installed packages only..."
        echo
        printf "%-20s %-10s %s\n" "Package" "Status" "Description"
        printf "%-20s %-10s %s\n" "-------" "------" "-----------"
        
        if [[ -n "$installed_packages" ]]; then
            echo "$installed_packages" | while read -r package; do
                if [[ -n "$package" ]]; then
                    local version=""
                    local pkg_dir="$PACKAGES_DIR/$package"
                    if [[ -f "$pkg_dir/VERSION.md" ]]; then
                        version="($(cat "$pkg_dir/VERSION.md" | head -1 | tr -d '\r\n'))"
                    fi
                    printf "%-20s %-10s %s\n" "$package" "✅ Installed" "$version"
                fi
            done
        fi
        return
    fi
    
    printf "%-20s %-10s %s\n" "Package" "Status" "Description"
    printf "%-20s %-10s %s\n" "-------" "------" "-----------"
    
    # Save packages to temp file to avoid pipeline issues
    local temp_file=$(mktemp)
    echo "$available_packages" > "$temp_file"
    
    # Process each package
    while IFS= read -r package; do
        # Strip any carriage returns or whitespace
        package=$(echo "$package" | tr -d '\r\n' | xargs)
        if [[ -n "$package" ]]; then
            local status="⚠️  Available"
            local description=""
            
            # Check if package is properly installed
            local pkg_dir="/c/App/PORTX/packages/$package"
            if [[ -d "$pkg_dir" && -f "$pkg_dir/package-manual.md" ]]; then
                # Check if package has executables (check root and subdirectories)
                if ls "$pkg_dir"/*.exe >/dev/null 2>&1 || find "$pkg_dir" -name "*.exe" -type f | head -1 >/dev/null 2>&1; then
                    status="✅ Installed"
                    
                    # Try to get version info
                    if [[ -f "$pkg_dir/VERSION.md" ]]; then
                        local version=$(head -1 "$pkg_dir/VERSION.md" | tr -d '\r\n')
                        description="($version)"
                    fi
                else
                    status="⚠️  Incomplete"
                    description="(missing executables)"
                fi
            fi
            
            printf "%-20s %-10s %s\n" "$package" "$status" "$description"
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
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
    
    # Try to discover the actual package filename by testing common patterns
    log "Discovering package version..."
    local download_url=""
    
    # Try to discover version patterns by testing GitHub directory listing
    local test_urls=()
    
    # Package-specific known versions (add as we discover them)
    local known_versions=()
    case "$package_name" in
        "ag")
            known_versions=("2.2.0")
            ;;
        "aws")
            known_versions=("2.15.30" "2.15.0" "2.14.0" "2.13.0")
            ;;
        # Add more as discovered
    esac
    
    # Try known versions first
    for version in "${known_versions[@]}"; do
        test_urls+=(
            "$PACKAGES_REPO/$package_name/${package_name}-${version}-x64-windows.zip"
        )
    done
    
    # Generic version patterns (only if no known versions)
    if [[ ${#known_versions[@]} -eq 0 ]]; then
        local common_versions=("latest" "1.0.0" "2.0.0")
        for version in "${common_versions[@]}"; do
            test_urls+=(
                "$PACKAGES_REPO/$package_name/${package_name}-${version}-x64-windows.zip"
            )
        done
    fi
    
    # Add fallback patterns
    test_urls+=(
        "$PACKAGES_REPO/$package_name/${package_name}-x64-windows.zip"  # no version pattern
        "$PACKAGES_REPO/$package_name/${package_name}.zip"  # simple pattern
    )
    
    for test_url in "${test_urls[@]}"; do
        log "Trying: $(basename "$test_url")"
        local http_code
        http_code=$("$CURL" -s -I "$test_url" --write-out "%{http_code}" -o /dev/null)
        if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
            download_url="$test_url"
            log "Found working URL: $test_url"
            break
        fi
    done
    
    if [[ -z "$download_url" ]]; then
        error "Could not find package $package_name in repository"
        error "Tried multiple filename patterns but none worked"
        rm -rf "$pkg_dir"
        exit 1
    fi
    
    log "Downloading from: $download_url"
    
    # Download with curl and check HTTP status
    local http_code
    http_code=$("$CURL" -L "$download_url" -o "$zip_file" --silent --show-error --write-out "%{http_code}")
    
    if [[ "$http_code" != "200" ]]; then
        error "Failed to download package $package_name (HTTP $http_code)"
        if [[ "$http_code" == "404" ]]; then
            error "Package not found in repository. Check package name or try: portx list"
        fi
        rm -rf "$pkg_dir"
        exit 1
    fi
    
    # Verify the downloaded file is a valid zip
    if ! "$SEVENZIP" t "$zip_file" >/dev/null 2>&1; then
        error "Downloaded file is not a valid zip archive"
        error "URL: $download_url"
        rm -rf "$pkg_dir"
        exit 1
    fi
    
    success "Downloaded $package_name"
    
    # Extract with 7zip
    log "Extracting package..."
    local temp_extract="$pkg_dir/temp_extract"
    mkdir -p "$temp_extract"
    
    if ! "$SEVENZIP" x "$zip_file" -o"$temp_extract" -y > /dev/null; then
        error "Failed to extract package $package_name"
        rm -rf "$pkg_dir"
        exit 1
    fi
    
    # Check if extraction created a nested directory structure
    local dir_count
    dir_count=$(find "$temp_extract" -maxdepth 1 -type d | wc -l)
    
    if [[ $dir_count -eq 2 ]]; then
        # Only one subdirectory (plus temp_extract itself), flatten it
        local nested_dir
        nested_dir=$(find "$temp_extract" -maxdepth 1 -type d ! -path "$temp_extract")
        if [[ -n "$nested_dir" ]]; then
            log "Flattening nested directory structure..."
            mv "$nested_dir"/* "$pkg_dir/" 2>/dev/null || true
            # Move hidden files if they exist
            if ls "$nested_dir"/.[!.]* >/dev/null 2>&1; then
                mv "$nested_dir"/.[!.]* "$pkg_dir/" 2>/dev/null || true
            fi
        fi
    else
        # Multiple items or no subdirectories, move everything
        mv "$temp_extract"/* "$pkg_dir/" 2>/dev/null || true
        # Move hidden files if they exist
        if ls "$temp_extract"/.[!.]* >/dev/null 2>&1; then
            mv "$temp_extract"/.[!.]* "$pkg_dir/" 2>/dev/null || true
        fi
    fi
    
    # Clean up temp directory and zip file
    rm -rf "$temp_extract"
    rm "$zip_file"
    
    # Count executables for information  
    log "Cataloging package executables..."
    local exe_count=0
    local exe_list=()
    
    # Simple approach - just count .exe files
    if find "$pkg_dir" -maxdepth 4 -name "*.exe" -type f >/dev/null 2>&1; then
        local exe_files
        exe_files=($(find "$pkg_dir" -maxdepth 4 -name "*.exe" -type f -exec basename {} \; 2>/dev/null))
        exe_count=${#exe_files[@]}
        exe_list=("${exe_files[@]}")
        
        for exe_name in "${exe_files[@]}"; do
            log "  → Found $exe_name"
        done
        log "Found $exe_count executable(s)"
    else
        warning "No executables found in package"
    fi
    
    success "Package $package_name installed successfully"
    
    # Display package information
    local manual_file="$pkg_dir/package-manual.md"
    echo
    echo "📦 Package: $package_name"
    echo "📁 Location: $pkg_dir"
    if [[ $exe_count -gt 0 ]]; then
        echo "🔧 Executables: ${exe_list[*]}"
        echo "🔄 Auto-discovery: Tools will be available in new shell sessions"
        
        # Trigger reindexing by removing .portx_tools
        rm -f "$HOME/.portx_tools" 2>/dev/null || true
    fi
    
    # Show manual location if available
    if [[ -f "$manual_file" ]]; then
        echo "📖 Manual: $manual_file"
    fi
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
    echo "  list                Show all packages with install status"
    echo "  install <package>   Install a package"
    echo "  remove <package>    Remove a package"
    echo "  help               Show this help"
    echo
    echo "Examples:"
    echo "  portx.sh status"
    echo "  portx.sh list"
    echo "  portx.sh install ag"
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
            list_merged
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