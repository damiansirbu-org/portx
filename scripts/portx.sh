#!/bin/bash
# PORTX Package Manager Shell Script  
# Portable POSIX Environment for Windows

# Enhanced error handling (not fully strict due to legacy code)
set -e  # Exit on command failure

# Get script directory to use relative paths for tools  
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load theme system for consistent colors and icons - let it crash if not found
# shellcheck source=/dev/null
source "$SCRIPT_DIR/theme.sh"

# Logging functions using printf
log() { printf "%sℹ %s%s\n" "$(color_primary)" "$1" "$(color_reset)"; }
error() { printf "%s✗ %s%s\n" "$(color_error)" "$1" "$(color_reset)" >&2; }
success() { printf "%s✓ %s%s\n" "$(color_success)" "$1" "$(color_reset)"; }
warning() { printf "%s⚠ %s%s\n" "$(color_warning)" "$1" "$(color_reset)"; }

# Auto-discover GIT_BASH_ROOT by looking for bin, home, mingw64 directories
find_git_bash_root() {
    local current_dir="$SCRIPT_DIR"

    # First check common Git Bash installation locations
    local common_locations=(
        "/c/App/Git"
        "/c/App/git-bash"
        "/c/git-bash"
        "/opt/git-bash"
        "/usr/local/git-bash"
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

GIT_BASH_ROOT=$(find_git_bash_root)

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

# Initialize tool paths - tools are in PATH
CURL="curl"
WGET="wget" 
SEVENZIP="7za"
# GREP, MKDIR, RM removed - unused variables

# Configuration
PACKAGES_REPO="https://github.com/damiansirbu-org/portx-packages/raw/main/releases/windows-amd64"
PACKAGES_DIR="$GIT_BASH_ROOT/home/portx/packages"
BIN_DIR="$GIT_BASH_ROOT/bin"

# Note: Legacy color variables removed - using theme system functions instead

# Enhanced error handling with strict mode
error_exit() {
    local line_no="${1:-unknown}"
    local error_code="${2:-1}"
    printf "ERROR [%s:%s]: Script failed on line %s\n" "${BASH_SOURCE[1]##*/}" "${FUNCNAME[1]}" "$line_no" >&2
    exit "$error_code"
}

trap 'error_exit ${LINENO} $?' ERR

# Enhanced logging functions using theme system
log() {
    printf "%s[PORTX]%s %s\n" "$(color_primary)" "$(color_reset)" "$1"
}

error() {
    printf "%s%s %s%s\n" "$(color_error)" "$(icon_error)" "$1" "$(color_reset)" >&2
}

success() {
    printf "%s%s %s%s\n" "$(color_success)" "$(icon_success)" "$1" "$(color_reset)"
}

warning() {
    printf "%s%s %s%s\n" "$(color_warning)" "$(icon_warning)" "$1" "$(color_reset)"
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

    echo "$(icon_directory) Git Bash Root: $GIT_BASH_ROOT"
    echo "$(icon_directory) Script Directory: $SCRIPT_DIR"
    echo "$(icon_package) Packages Directory: $PACKAGES_DIR"
    echo "$(icon_statistics) Binary Directory: $BIN_DIR"
    echo "$(icon_network) Repository: $PACKAGES_REPO"
    echo

    # Check directories
    if [[ -d "$PACKAGES_DIR" ]]; then
        local pkg_count=0
        local pkg_dirs
        pkg_dirs=("$PACKAGES_DIR"/*/)
        [[ -d "${pkg_dirs[0]}" ]] && pkg_count=${#pkg_dirs[@]}
        success "Packages directory exists ($((pkg_count - 1)) packages)"
    else
        warning "Packages directory does not exist"
    fi

    if [[ -d "$BIN_DIR" ]]; then
        local bin_count=0
        local bin_files
        bin_files=("$BIN_DIR"/*.exe)
        [[ -f "${bin_files[0]}" ]] && bin_count=${#bin_files[@]}
        success "Binary directory exists ($bin_count executables)"
    else
        warning "Binary directory does not exist"
    fi

    # Check available tools
    echo
    log "Available Tools:"
    if [[ -n "$CURL" && -f "$CURL" ]]; then
        echo "  ◈ curl: $CURL"
    else
        echo "  ◆ curl: not found"
    fi

    if [[ -n "$SEVENZIP" && -f "$SEVENZIP" ]]; then
        echo "  ◈ 7za64: $SEVENZIP"
    else
        echo "  ◆ 7za64: not found"
    fi

    if [[ -n "$WGET" && -f "$WGET" ]]; then
        echo "  ◈ wget: $WGET"
    else
        echo "  ◇  wget: not found (optional)"
    fi
}

# Get available packages from GitHub
get_available_packages() {
    if ! command -v jq >/dev/null 2>&1; then
        return 1
    fi

    curl -s "https://api.github.com/repos/damiansirbu-org/portx-packages/contents/releases/windows-amd64" 2>/dev/null |
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
        printf "%-18s %-12s %s\n" "Package" "Status" "Description"
        printf "%-18s %-12s %s\n" "-------" "------" "-----------"

        if [[ -n "$installed_packages" ]]; then
            echo "$installed_packages" | while read -r package; do
                if [[ -n "$package" ]]; then
                    local version=""
                    local pkg_dir="$PACKAGES_DIR/$package"
                    if [[ -f "$pkg_dir/VERSION.md" ]]; then
                        version="($(cat "$pkg_dir/VERSION.md" | head -1 | tr -d '\r\n'))"
                    fi
                    printf "%-18s %-12s %s\n" "$package" "◈ Installed" "$version"
                fi
            done
        fi
        return
    fi

    # Collect package info for columnar display
    local packages=()
    local temp_file=$(mktemp)
    echo "$available_packages" >"$temp_file"

    # Process each package and collect info
    while IFS= read -r package; do
        package=$(echo "$package" | tr -d '\r\n' | xargs)
        if [[ -n "$package" ]]; then
            local status="$(icon_package)"
            local version=""

            # Check if package is properly installed
            local pkg_dir="$PACKAGES_DIR/$package"
            if [[ -d "$pkg_dir" && -f "$pkg_dir/package-manual.md" ]]; then
                if ls "$pkg_dir"/*.exe >/dev/null 2>&1 || find "$pkg_dir" -name "*.exe" -type f | head -1 >/dev/null 2>&1; then
                    status="$(icon_success)"
                    if [[ -f "$pkg_dir/VERSION.md" ]]; then
                        version=$(head -1 "$pkg_dir/VERSION.md" | tr -d '\r\n')
                    fi
                else
                    status="$(icon_warning)"
                fi
            fi

            # Store package info
            packages+=("$package|$status|$version")
        fi
    done <"$temp_file"
    rm -f "$temp_file"

    # Display in columns (3 columns)
    local cols=3
    local total=${#packages[@]}
    local rows=$(((total + cols - 1) / cols))

    for ((row = 0; row < rows; row++)); do
        for ((col = 0; col < cols; col++)); do
            local idx=$((row + col * rows))
            if [[ $idx -lt $total ]]; then
                IFS='|' read -r pkg_name pkg_status pkg_version <<<"${packages[$idx]}"
                printf "%-2s %-20s " "$pkg_status" "$pkg_name"
            else
                printf "%-23s " "" # Empty padding for missing entries
            fi
        done
        echo
    done
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
        "$PACKAGES_REPO/$package_name/${package_name}-x64-windows.zip" # no version pattern
        "$PACKAGES_REPO/$package_name/${package_name}.zip"             # simple pattern
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

    if ! "$SEVENZIP" x "$zip_file" -o"$temp_extract" -y >/dev/null; then
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
        mapfile -t exe_files < <(find "$pkg_dir" -maxdepth 4 -name "*.exe" -type f -exec basename {} \; 2>/dev/null)
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
    echo "$(icon_package) Package: $package_name"
    echo "$(icon_directory) Location: $pkg_dir"
    if [[ $exe_count -gt 0 ]]; then
        echo "$(icon_statistics) Executables: ${exe_list[*]}"
        echo "$(icon_statistics) Auto-discovery: Tools will be available in new shell sessions"

        # Trigger reindexing by removing .portx_tools
        rm -f "$HOME/.portx_tools" 2>/dev/null || true
    fi

    # Show manual location if available
    if [[ -f "$manual_file" ]]; then
        echo "$(icon_directory) Manual: $manual_file"
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
            local exe_name="${exe_file##*/}"
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

# Show package manual
show_manual() {
    local package_name="$1"

    if [[ -z "$package_name" ]]; then
        error "Package name required"
        echo "Usage: portx man <package_name>"
        exit 1
    fi

    local manual_file="$PACKAGES_DIR/$package_name/package-manual.md"

    if [[ ! -f "$manual_file" ]]; then
        error "Manual not found for package: $package_name"
        echo "Package may not be installed or manual file is missing."
        echo "Try: portx.sh list"
        exit 1
    fi

    log "Showing manual for package: $package_name"
    echo

    # Use appropriate pager/viewer
    if command -v less >/dev/null 2>&1; then
        less "$manual_file"
    elif command -v more >/dev/null 2>&1; then
        more "$manual_file"
    else
        cat "$manual_file"
    fi
}

# Parse package manual and extract tool information - key-value format
parse_package_manual() {
    local package_dir="$1"
    local package_name="${package_dir##*/}"
    local manual_file="$package_dir/package-manual.md"

    if [[ ! -f "$manual_file" ]]; then
        return 1
    fi

    # Check if this is new key-value format or old markdown format
    if grep -q "^package-name:" "$manual_file"; then
        # New key-value format
        parse_keyvalue_format "$manual_file"
    else
        # Old markdown format (fallback)
        parse_markdown_format "$manual_file" "$package_name"
    fi
}

# Parse new key-value format
parse_keyvalue_format() {
    local manual_file="$1"

    local pkg_name=""
    local pkg_version=""
    local in_tools_section=false

    while IFS= read -r line; do
        # Remove carriage return if present (Windows line endings)
        line="${line%$'\r'}"

        # Extract package metadata
        if [[ "$line" =~ ^package-name:[[:space:]]*(.+)$ ]]; then
            pkg_name="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^package-version:[[:space:]]*(.+)$ ]]; then
            pkg_version="${BASH_REMATCH[1]}"
        elif [[ "$line" == "package-tools:" ]]; then
            in_tools_section=true
            continue
        elif [[ "$line" == "package-paths:" ]]; then
            in_tools_section=false
            continue
        fi

        # Parse tools in tools section
        if [[ "$in_tools_section" == "true" && -n "$line" && ! "$line" =~ ^[[:space:]]*$ ]]; then
            if [[ "$line" =~ ^(.+)[[:space:]]-[[:space:]](.+)$ ]]; then
                local tool_name="${BASH_REMATCH[1]}"
                local tool_desc="${BASH_REMATCH[2]}"

                # Clean up whitespace from tool name
                tool_name="${tool_name# }"
                tool_name="${tool_name% }"

                echo "$pkg_name|$pkg_version|$tool_name|$tool_desc|"
            fi
        fi
    done <"$manual_file"
}

# Parse old markdown format (fallback)
parse_markdown_format() {
    local manual_file="$1"
    local package_name="$2"

    local category=""

    # Extract category from old format
    category=$(grep -E "^- \*\*Category\*\*:" "$manual_file" | head -1 | sed 's/^- \*\*Category\*\*:[[:space:]]*//' || echo "")

    # Extract all table rows that look like tools
    grep -E '^\|[^|]*\|[^|]*\|[^|]*\|$' "$manual_file" |
        grep -v -E '^\|[[:space:]]*Tool[[:space:]]*\|' |
        grep -v -E '^\|[-[:space:]]*\|' |
        while IFS='|' read -r _ tool_name tool_desc tool_usage _; do
            # Clean up whitespace
            tool_name=$(echo "$tool_name" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            tool_desc=$(echo "$tool_desc" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

            # Skip section headers and invalid entries
            if [[ -z "$tool_name" || "$tool_name" == "Tool" ]]; then
                continue
            fi
            
            # Skip markdown section headers like **Path Conversion**
            if [[ "$tool_name" =~ ^\*\*.*\*\*$ ]]; then
                continue
            fi
            
            # Skip empty package placeholders
            if [[ "$tool_name" =~ \(Empty[[:space:]]*Package\) ]]; then
                continue
            fi

            # Output tool information
            echo "$package_name|$category|$tool_name|$tool_desc|"
        done
}

# List all tools in hierarchical format (package -> tools)
list_tools() {
    set +e  # Disable strict error handling for this function
    echo "PORTX Tools Inventory - Hierarchical View"
    echo
    
    local total_tools=0
    local total_packages=0
    
    # Check if packages directory exists
    if [[ ! -d "$PACKAGES_DIR" ]]; then
        echo "ERROR: Packages directory not found: $PACKAGES_DIR"
        return 1
    fi
    
    # Check if jq is available
    local JQ_CMD=""
    if command -v jq >/dev/null 2>&1; then
        JQ_CMD="jq"
    elif command -v jq.cmd >/dev/null 2>&1; then
        JQ_CMD="jq.cmd"
    else
        echo "ERROR: jq not found in PATH - required for package.json parsing"
        return 1
    fi
    
    for pkg_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_dir" && -f "$pkg_dir/package.json" ]]; then
            local pkg_name=$(basename "$pkg_dir")
            
            # Extract package metadata safely
            local pkg_description=""
            local pkg_version=""
            local tool_count=0
            
            pkg_description=$($JQ_CMD -r '.description // ""' "$pkg_dir/package.json" 2>/dev/null || echo "")
            pkg_version=$($JQ_CMD -r '.version // ""' "$pkg_dir/package.json" 2>/dev/null || echo "")
            tool_count=$($JQ_CMD -r '.tools // [] | length' "$pkg_dir/package.json" 2>/dev/null || echo "0")
            
            # Skip packages with no tools
            if [[ "$tool_count" -eq 0 ]]; then
                continue
            fi
            
            ((total_packages++))
            total_tools=$((total_tools + tool_count))
            
            # Display package header with aligned description
            pkg_header="$pkg_name"
            if [[ -n "$pkg_version" ]]; then
                pkg_header="$pkg_header (v$pkg_version)"
            fi
            printf "%-30s %s\n" "$pkg_header" "$pkg_description"
            
            # Use jq to format complete output with tools and tags (using ASCII tree chars)
            $JQ_CMD -r '(.tags // []) as $tags | .tools[]? | "  |- " + (.executable // "" | . + (25 - length) * " " | .[0:25]) + " " + (.description // "") + if ($tags | length > 0) then " [" + ($tags | join(", ")) + "]" else "" end' "$pkg_dir/package.json" 2>/dev/null
            echo
        fi
    done
    
    echo "Summary: $total_packages packages, $total_tools total tools"
    set -e  # Re-enable strict error handling
}

# Search tools by pattern
search_tools() {
    local pattern="$1"
    local matches=0

    printf "%s%s Searching for '%s'...%s\n" "$(color_primary)" "$(icon_search)" "$pattern" "$(color_reset)" >&2

    printf "\n%s%s Search Results for '%s'%s\n" "$(color_success)" "$(icon_search)" "$pattern" "$(color_reset)"
    echo

    for package_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$package_dir" ]]; then
            # Parse package manual and search tools
            while IFS='|' read -r package category tool_name tool_desc tool_usage; do
                if [[ -n "$tool_name" ]]; then
                    if echo "$tool_name $tool_desc $tool_usage" | grep -qi "$pattern"; then
                        printf "%-20s %-25s %-20s %s\n" "$tool_name" "($package)" "[$category]" "$tool_desc"
                        ((matches++))
                    fi
                fi
            done < <(parse_package_manual "$package_dir" 2>/dev/null)
        fi
    done

    echo
    printf "%sFound %d matches%s\n" "$(color_primary)" "$matches" "$(color_reset)"
}

# Show count statistics
show_tools_count() {
    local total_tools=0
    local total_packages=0
    declare -A category_counts
    declare -A package_counts

    for package_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$package_dir" ]]; then
            ((total_packages++))
            local package_name="${package_dir##*/}"
            local package_tool_count=0

            # Parse package manual and count tools
            while IFS='|' read -r package category tool_name tool_desc tool_usage; do
                if [[ -n "$tool_name" ]]; then
                    if [[ -n "$category" ]]; then
                        category_counts["$category"]=$((${category_counts["$category"]:-0} + 1))
                    fi
                    ((package_tool_count++))
                    ((total_tools++))
                fi
            done < <(parse_package_manual "$package_dir" 2>/dev/null)

            package_counts["$package_name"]=$package_tool_count
        fi
    done

    printf "\n%s%s PORTX Tools Statistics%s\n" "$(color_success)" "$(icon_statistics)" "$(color_reset)"
    printf "%sTotal Packages: %d%s\n" "$(color_primary)" "$total_packages" "$(color_reset)"
    printf "%sTotal Tools: %d%s\n" "$(color_primary)" "$total_tools" "$(color_reset)"
    echo

    printf "%s%s By Category:%s\n" "$(color_warning)" "$(icon_directory)" "$(color_reset)"
    for category in $(printf '%s\n' "${!category_counts[@]}" | sort); do
        if [[ -n "$category" ]]; then
            printf "  %-30s %d tools\n" "$category" "${category_counts[$category]}"
        fi
    done

    echo
    printf "%s%s Top Packages by Tool Count:%s\n" "$(color_warning)" "$(icon_package)" "$(color_reset)"
    for package in "${!package_counts[@]}"; do
        if [[ ${package_counts[$package]} -gt 0 ]]; then
            printf "  %-20s %d tools\n" "$package" "${package_counts[$package]}"
        fi
    done | sort -k3 -nr | head -10
}

# Handle tools commands
handle_tools_command() {
    local command="${1:-list}"

    # Note: Using theme system color functions instead of legacy variables

    case "$command" in
        list | ls)
            list_tools
            ;;
        search | find)
            if [[ -z "$2" ]]; then
                error "Search pattern required"
                echo "Usage: portx tools search <pattern>"
                exit 1
            fi
            search_tools "$2"
            ;;
        count | stats)
            show_tools_count
            ;;
        help | --help | -h)
            echo "PORTX Tools Aggregator"
            echo
            echo "Usage: portx tools <command> [options]"
            echo
            echo "Commands:"
            echo "  list              List all available tools"
            echo "  search PATTERN    Search tools by name or description"
            echo "  count             Show tool count statistics"
            echo "  help              Show this help message"
            echo
            echo "Examples:"
            echo "  portx tools list"
            echo "  portx tools search git"
            echo "  portx tools count"
            ;;
        *)
            error "Unknown tools command: $command"
            echo "Try: portx tools help"
            exit 1
            ;;
    esac
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
    echo "  man <package>       Show package manual"
    echo "  tools [command]     Access PORTX tools aggregator"
    echo "  help               Show this help"
    echo
    echo "Examples:"
    echo "  portx.sh status"
    echo "  portx.sh list"
    echo "  portx.sh install ag"
    echo "  portx.sh remove ag"
    echo "  portx.sh man ag"
    echo "  portx.sh tools list"
    echo "  portx.sh tools search git"
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
        "remove" | "uninstall")
            remove_package "$2"
            ;;
        "man" | "manual")
            show_manual "$2"
            ;;
        "tools")
            # Handle tools command with all remaining arguments
            shift # Remove 'tools' from arguments
            handle_tools_command "$@"
            ;;
        "help" | "-h" | "--help")
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
