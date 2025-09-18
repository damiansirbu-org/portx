#!/bin/bash
# Source analyzer interface
source "$(dirname "${BASH_SOURCE[0]}")/analyzer-interface.sh" 2>/dev/null || true
# =============================================================================
# COMMON UTILITIES WITH COMPREHENSIVE FILE TYPE MAPPING
# =============================================================================

# Configuration now sourced from settings.sh
# Global variables - used across multiple functions and sourced modules
# shellcheck disable=SC2034  # Variables used by multiple functions and sourced files
FILE_PATH="${FILE_PATH:-}"
FILE_EXT="${FILE_EXT:-}"
BASENAME="${BASENAME:-}"
AVAILABLE_ANALYZERS=()

# =============================================================================
# CENTRALIZED OUTPUT SYSTEM
# =============================================================================

# =============================================================================
# SIMPLIFIED OUTPUT SYSTEM - For standalone tool
# =============================================================================

# Simple output functions for standalone tool
send_output() {
    echo "$1"
}

send_error() {
    echo "$1" >&2
}

# =============================================================================
# STANDARDIZED JSON OUTPUT FUNCTIONS
# =============================================================================

# Unified JSON output function - single method for all message types
json_output() {
    local status="$1"    # error, success, skipped
    local message="$2"   # main message
    local extra_fields="${3:-}"  # optional extra JSON fields
    
    local json='{"status":"'"$status"'","message":"'"${message//\"/\\\"}"'"'
    
    if [[ -n "$extra_fields" ]]; then
        # Remove trailing } and add extra fields
        json="${json%\}},${extra_fields}}"
    fi
    
    json="$json}"
    echo "$json"
}



# NOTE: Analyzer communication functions are in analyzer-interface.sh
# Analyzers should use return_result(), return_success(), return_error() from that file

# =============================================================================
# COMPREHENSIVE LOGGING SYSTEM
# =============================================================================

# Logging configuration - variables set in settings.sh
# LOG_LEVEL and LOG_MAX_SIZE are already defined as readonly in settings.sh
LOG_FILE=""  # Set by setup_environment

# Initialize logging system
init_logging() {
    if [[ -n "$LOG_FILE" ]]; then
        # Rotate log if too large
        if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE" 2>/dev/null || stat -f%z "$LOG_FILE" 2>/dev/null || echo 0) -gt $LOG_MAX_SIZE ]]; then
            mv "$LOG_FILE" "$LOG_FILE.old" 2>/dev/null || true
        fi
        
        # Write session header
        {
            echo "=================================="
            echo "ANALYZE-HOOK SESSION: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "FILE: $FILE_PATH"
            echo "ACTION: ${ACTION:-inspect}"
            echo "PID: $$"
            echo "=================================="
        } >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# Get current function name for logging context
get_caller_function() {
    # Skip get_caller_function and the logging function calling it
    local caller_info="${FUNCNAME[2]:-main}"
    echo "$caller_info"
}

# Core logging function
write_log() {
    local level="$1"
    local message="$2"
    local function_name="$3"
    
    # Check if logging is enabled and level is appropriate
    [[ -z "$LOG_FILE" ]] && return 0
    
    # Level filtering
    case "$LOG_LEVEL" in
        ERROR) [[ "$level" != "ERROR" ]] && return 0 ;;
        WARN)  [[ ! "$level" =~ ^(ERROR|WARN)$ ]] && return 0 ;;
        INFO)  [[ ! "$level" =~ ^(ERROR|WARN|INFO)$ ]] && return 0 ;;
        DEBUG) ;; # Log everything
        *) return 0 ;;
    esac
    
    # Write formatted log entry
    local timestamp
    timestamp=$(date '+%H:%M:%S.%3N' 2>/dev/null || date '+%H:%M:%S')
    printf '[%s] [%-5s] [%-15s] %s\n' "$timestamp" "$level" "$function_name" "$message" >> "$LOG_FILE" 2>/dev/null || true
}

# Public logging API
log_debug() {
    write_log "DEBUG" "$1" "$(get_caller_function)"
}

log_info() {
    write_log "INFO" "$1" "$(get_caller_function)"
}

log_warn() {
    write_log "WARN" "$1" "$(get_caller_function)"
}

log_error() {
    write_log "ERROR" "$1" "$(get_caller_function)"
}

# Additional analyzer communication helpers
send_message() {
    local message="$1"
    local channel="${2:-stdout}"
    
    case "$channel" in
        stdout) echo "$message" ;;
        stderr) echo "$message" >&2 ;;
        both) echo "$message"; echo "$message" >&2 ;;
        *) echo "$message" ;;
    esac
}

# Utility functions removed - use sanitizer.sh functions directly

setup_environment() {
    # Use the global FILE_PATH variable 
    if [[ -z "$FILE_PATH" ]]; then
        echo "ERROR: FILE_PATH not set before setup_environment" >&2
        return 1
    fi
    
    BASENAME="$(basename "$FILE_PATH")"
    if [[ "$BASENAME" == *"."* ]]; then
        FILE_EXT="${BASENAME##*.}"
    else
        FILE_EXT=""  # No extension
    fi
    
    # No cache setup needed for standalone tool
    LOG_FILE=""  # Disable file logging for standalone tool
    
}


# Validate file path and return JSON status
validate_file_path() {
    local file_path="$FILE_PATH"
    
    # Check if file path is provided
    if [[ -z "$file_path" ]]; then
        echo '{"status":"ERROR","data":{"error":"no_file_path","message":"File path is required"}}'
        return 1
    fi
    
    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        echo '{"status":"ERROR","data":{"error":"file_not_found","message":"File does not exist","file_path":"'"$file_path"'"}}'
        return 1
    fi
    
    # Check if file is readable
    if [[ ! -r "$file_path" ]]; then
        echo '{"status":"ERROR","data":{"error":"file_not_readable","message":"File is not readable","file_path":"'"$file_path"'"}}'
        return 1
    fi
    
    # File is valid
    echo '{"status":"SUCCESS","data":{"file_path":"'"$file_path"'","file_exists":true,"file_readable":true}}'
    return 0
}

# Cache functions removed - no caching in standalone tool

# read_file_contents removed - hook-specific function not needed for standalone tool

# show_claude_instructions removed - hook-specific function not needed for standalone tool

# cleanup_on_exit removed - killing background processes is not good practice

handle_errors() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        local result_json='{"status":"ERROR","data":{"error":"analysis_failed","exit_code":'$exit_code',"file":"'"$FILE_PATH"'","message":"Analysis failed with exit code '$exit_code'"}}'
        echo "$result_json"
    fi
}

# Cache storage functions removed - no caching in standalone tool

# generate_final_output removed - hook-specific function not needed for standalone tool

# Analyzer management
analyzer_exists() {
    declare -F "analyze_$1" >/dev/null 2>&1
}

get_inspect_analyzers() {
    local file_ext="$1"
    local basename="$2"
    local potential_analyzers=(ctags scc)
    
    case "$file_ext" in
        py|pyx|pyi) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        java) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        js|jsx|ts|tsx|vue|svelte) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        c|cc|cpp|cxx|h|hpp|hxx) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        cs|fs|vb) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        rs) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        go) potential_analyzers+=(treesitter ast_grep dependency dependency_reverse) ;;
        sh|bash|zsh|fish) potential_analyzers+=(treesitter ast_grep shellcheck dependency dependency_reverse) ;;
        pl|pm|perl|groovy|gradle|rb|rbx|php) potential_analyzers+=(treesitter ast_grep) ;;
        yaml|yml)
            potential_analyzers+=(treesitter ast_grep)
            case "$basename" in
                Chart.yaml|Chart.yml|values.yaml|values.yml|values-*.yaml|values-*.yml) potential_analyzers+=(helm_chart) ;;
                docker-compose*.yml|docker-compose*.yaml|compose*.yml|compose*.yaml) ;;
                *) ;;
            esac ;;
        json)
            potential_analyzers+=(treesitter ast_grep)
            case "$basename" in
                package*.json|composer.json) potential_analyzers+=(dependency dependency_reverse) ;;
                *) ;;
            esac ;;
        xml)
            potential_analyzers+=(treesitter ast_grep) ;;
        tf|hcl)
            potential_analyzers+=(treesitter ast_grep terraform) ;;
        feature)
            potential_analyzers+=(treesitter ast_grep) ;;
        sql|ddl|dml)
            potential_analyzers+=(treesitter ast_grep) ;;
        properties|env|config|ini|toml|conf)
            potential_analyzers+=(treesitter ast_grep) ;;
        "")
            case "$basename" in
                Chart|values|helmfile) potential_analyzers+=(helm_chart) ;;
                Dockerfile*|dockerfile*) potential_analyzers+=(treesitter ast_grep) ;;
                *) ;;
            esac ;;
    esac
    
    local available_analyzers=()
    for analyzer in "${potential_analyzers[@]}"; do
        analyzer_exists "$analyzer" && available_analyzers+=("analyze_$analyzer")
    done
    printf "%s\n" "${available_analyzers[@]}"
}

get_verify_analyzers() {
    local file_ext="$1"
    local basename="$2"
    local potential_analyzers=(trivy)
    
    case "$file_ext" in
        py|pyx|pyi) potential_analyzers+=(ruff) ;;
        java) potential_analyzers+=(dprint) ;;
        js|jsx|ts|tsx|vue|svelte) potential_analyzers+=(dprint) ;;
        c|cc|cpp|cxx|h|hpp|hxx) potential_analyzers+=(dprint) ;;
        cs|fs|vb) potential_analyzers+=(dprint) ;;
        rs) potential_analyzers+=(dprint) ;;
        go) potential_analyzers+=(dprint) ;;
        sh|bash|zsh|fish) potential_analyzers+=(shellcheck) ;;
        pl|pm|perl|groovy|gradle|rb|rbx|php) potential_analyzers+=(dprint) ;;
        md|markdown|rst|adoc) potential_analyzers+=(dprint) ;;
        yaml|yml)
            potential_analyzers+=(dprint)
            case "$basename" in
                docker-compose*.yml|docker-compose*.yaml|compose*.yml|compose*.yaml) potential_analyzers+=(trivy) ;;
                *) ;;
            esac ;;
        json)
            case "$basename" in
                package*.json|composer.json) ;;
                tsconfig.json|jsconfig.json) ;;
                *) potential_analyzers+=(dprint) ;;
            esac ;;
        xml)
            potential_analyzers+=(dprint) ;;
        tf|hcl)
            potential_analyzers+=(terraform) ;;
        sql|ddl|dml)
            potential_analyzers+=(dprint) ;;
        properties|env|config|ini|toml|conf)
            potential_analyzers+=(dprint) ;;
        "")
            case "$basename" in
                Dockerfile*|dockerfile*) potential_analyzers+=(trivy hadolint dockerfile) ;;
                *) ;;
            esac ;;
    esac
    
    local available_analyzers=()
    for analyzer in "${potential_analyzers[@]}"; do
        analyzer_exists "$analyzer" && available_analyzers+=("analyze_$analyzer")
    done
    printf "%s\n" "${available_analyzers[@]}"
}

should_analyze_file() {
    local file_ext="$1" basename="$2"
    case "$file_ext" in
        # Binary/media files - SKIP
        jpg|jpeg|png|gif|bmp|ico|svg|webp|tiff|tif|pdf|doc|docx|xls|xlsx|ppt|pptx|odt|ods|odp|rtf|zip|tar|gz|bz2|xz|7z|rar|exe|dll|so|dylib|bin|iso|img|dmg|msi|deb|rpm|apk|ipa|jar|war|ear|class|o|obj|a|lib|pdb|ilk|exp|mp3|mp4|wav|avi|mov|mkv|flv|wmv|webm|m4v|3gp|ogg|flac|aac|wma) return 1 ;;
        # Text files with minimal analysis value - SKIP  
        md|markdown|rst|adoc|txt) return 1 ;;
        # Code files - ANALYZE
        py|pyx|pyi|java|js|jsx|ts|tsx|vue|svelte|c|cc|cpp|cxx|h|hpp|hxx|cs|fs|vb|rs|go|sh|bash|zsh|fish|pl|pm|perl|groovy|gradle|rb|rbx|php|yaml|yml|json|xml|toml|properties|env|config|ini|conf|tf|hcl|sql|ddl|dml|feature) return 0 ;;
        "") case "$basename" in Dockerfile*|dockerfile*|Jenkinsfile*|jenkinsfile*|.gitlab-ci.yml|gitlab-ci.yml|pom.xml|build.gradle*|gradle.*|package*.json|*lock*|Cargo.*|go.mod|go.sum|requirements*.txt|Pipfile*|setup.py|setup.cfg|composer.*|Makefile*|makefile*|docker-compose*|compose*|Chart.*|values*.yaml|values*.yml|helmfile*|.editorconfig|.gitignore|.dockerignore) return 0 ;; *) return 1 ;; esac ;;
        *) return 1 ;;
    esac
}