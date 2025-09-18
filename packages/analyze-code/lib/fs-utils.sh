#!/bin/bash
# =============================================================================
# FILESYSTEM UTILITIES
# Shared functions for project root detection and file operations
# =============================================================================

# Initialize dependency analysis environment
init_dependency_analysis() {
    local file_path="$1"
    
    # Basic file information - export for use by analyzers (use FILE_EXT from core-utils.sh)
    export file_ext="$FILE_EXT"
    export file_basename
    file_basename="$(basename "$file_path")"
    export file_basename_no_ext="${file_basename%.*}"
    
    # Setup tool paths - use paths from settings.sh
    export rg_path="$RIPGREP_PATH"
    export es_path="$ES_PATH"
    
    # Validate ripgrep availability (required)
    if [[ ! -f "$rg_path" ]]; then
        return 1
    fi
    
    return 0
}

# Fast file search by name pattern - uses es, returns results or fails silently
find_files_by_name() {
    local pattern="$1"
    local search_path="$2"
    
    if [[ -f "$es_path" ]]; then
        "$es_path" -path "$search_path" "$pattern" 2>/dev/null
    else
        # Return failure silently to avoid corrupting JSON output
        return 1
    fi
}

# Find project root with intelligent detection (enhanced version from dependency-reverse)
find_project_root() {
    local start_path="$1"
    local current_dir
    current_dir="$(dirname "$start_path")"
    local search_root="$current_dir"
    local project_root_found=false
    
    # Project root indicators by language/technology
    local root_indicators=(
        # Version control
        ".git" ".hg" ".svn"
        # Build files - Java/JVM
        "pom.xml" "build.gradle" "gradle.properties" "gradlew" "build.gradle.kts"
        # Build files - JavaScript/Node
        "package.json" "package-lock.json" "yarn.lock" "lerna.json" "rush.json"
        # Build files - Python
        "setup.py" "setup.cfg" "pyproject.toml" "Pipfile" "requirements.txt" "poetry.lock"
        # Build files - C/C++
        "CMakeLists.txt" "Makefile" "makefile" "configure.ac" "meson.build" "conanfile.txt"
        # Build files - Rust
        "Cargo.toml" "Cargo.lock"
        # Build files - Go
        "go.mod" "go.sum"
        # Build files - .NET
        "*.sln" "*.csproj" "*.fsproj" "*.vbproj" "project.json"
        # Build files - Ruby
        "Gemfile" "Gemfile.lock" "Rakefile"
        # Build files - PHP
        "composer.json" "composer.lock"
        # Docker/Container
        "Dockerfile" "docker-compose.yml" "docker-compose.yaml"
        # CI/CD
        ".github" ".gitlab-ci.yml" "Jenkinsfile"
        # IDE/Editor configs
        ".vscode" ".idea" ".editorconfig"
    )
    
    # Search up to 5 levels for project root
    for ((level=0; level<5; level++)); do
        # Check for any root indicator in current directory
        for indicator in "${root_indicators[@]}"; do
            if [[ -e "$current_dir/$indicator" ]] || compgen -G "$current_dir/$indicator" > /dev/null 2>&1; then
                search_root="$current_dir"
                project_root_found=true
                break 2  # Break out of both loops
            fi
        done
        
        # Move up one level
        local parent_dir
        parent_dir="$(dirname "$current_dir")"
        if [[ "$parent_dir" == "$current_dir" ]]; then
            break  # Reached filesystem root
        fi
        current_dir="$parent_dir"
    done
    
    # If no project root found, use same directory as the analyzed file
    if [[ "$project_root_found" != true ]]; then
        search_root="$(dirname "$start_path")"
    fi
    
    # Return results as JSON
    echo "{\"search_root\":\"$search_root\",\"project_root_found\":$project_root_found}"
}

# Simple search root (5 levels up - from original dependency analyzer)
find_simple_search_root() {
    local file_path="$1"
    local search_root
    search_root="$(dirname "$file_path")"
    
    # Find search root (5 levels up from file)
    for ((i=0; i<5; i++)); do
        local parent_dir
        parent_dir="$(dirname "$search_root")"
        if [[ "$parent_dir" != "$search_root" ]]; then
            search_root="$parent_dir"
        else
            break
        fi
    done
    
    echo "$search_root"
}

# Execute ripgrep with timeout and error handling
rg_search() {
    local timeout_duration="$1"
    local file_types="$2"
    local patterns="$3"
    local search_path="$4"
    local max_results="${5:-50}"
    
    # Build ripgrep command
    local rg_cmd="timeout $timeout_duration \"$rg_path\" --no-heading --line-number"
    
    # Add file types if specified
    if [[ -n "$file_types" ]]; then
        rg_cmd+=" $file_types"
    fi
    
    # Add patterns
    rg_cmd+=" $patterns"
    
    # Add search path
    rg_cmd+=" \"$search_path\""
    
    # Add result limiting
    rg_cmd+=" 2>/dev/null | head -$max_results"
    
    # Execute and return results
    eval "$rg_cmd"
}

# Execute ripgrep JSON search with timeout
rg_json_search() {
    local timeout_duration="$1"
    local file_types="$2"
    local patterns="$3"
    local search_path="$4"
    local max_results="${5:-50}"
    
    # Build ripgrep command for JSON output
    local rg_cmd="timeout $timeout_duration \"$rg_path\" --json"
    
    # Add file types if specified
    if [[ -n "$file_types" ]]; then
        rg_cmd+=" $file_types"
    fi
    
    # Add patterns
    rg_cmd+=" $patterns"
    
    # Add search path
    rg_cmd+=" \"$search_path\""
    
    # Add result limiting
    rg_cmd+=" 2>/dev/null | head -$max_results"
    
    # Execute and return results
    eval "$rg_cmd"
}

# Format dependency analysis results as JSON
format_dependency_result() {
    local analyzer_name="$1"
    local file_path="$2"
    local file_ext="$3"
    local search_root="$4"
    local additional_metadata="$5"
    local dependencies_data="$6"
    
    local timestamp
    timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "unknown")"
    
    printf '{"analyzer":"%s","file":"%s","language":"%s","search_scope":{"root":"%s"},%s,"dependencies":%s,"metadata":{"analyzed_at":"%s"}}' \
        "$analyzer_name" \
        "$file_path" \
        "$file_ext" \
        "$search_root" \
        "$additional_metadata" \
        "$dependencies_data" \
        "$timestamp"
}

# Extract exports from Python files
extract_python_exports() {
    local file_path="$1"
    timeout 5 "$rg_path" --no-heading -o \
        -e "^def\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
        -e "^class\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
        -r '$1' "$file_path" 2>/dev/null | head -10
}

# Extract exports from JavaScript/TypeScript files
extract_js_exports() {
    local file_path="$1"
    timeout 5 "$rg_path" --no-heading -o \
        -e "export\s+(function\s+)?([a-zA-Z_][a-zA-Z0-9_]*)" \
        -e "export\s+default\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
        -e "export\s+\{([^}]+)\}" \
        "$file_path" 2>/dev/null | head -10
}

# Extract function definitions from shell scripts
extract_shell_functions() {
    local file_path="$1"
    timeout 5 "$rg_path" --no-heading -o \
        -e "^([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)" \
        -e "function\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
        -r '$1' "$file_path" 2>/dev/null | head -8
}

# Extract Java package and class information
extract_java_package() {
    local file_path="$1"
    timeout 5 "$rg_path" --no-heading -o \
        -e "package\s+([a-zA-Z_][a-zA-Z0-9_.]*)" \
        -r '$1' "$file_path" 2>/dev/null | head -1
}