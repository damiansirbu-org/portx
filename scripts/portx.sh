#!/bin/bash
# PORTX Package Manager - Consolidated Script
# Imports packages into PORTX system: discover, validate, analyze dependencies, create wrappers, configure PATH
# Also provides tools aggregator functionality

# Enhanced error handling
set -euo pipefail

# Check if GIT_BASH_ROOT is set
if [[ -z "${GIT_BASH_ROOT:-}" ]]; then
    echo "ERROR: GIT_BASH_ROOT environment variable not set" >&2
    echo "This variable should be set by .bashrc" >&2
    exit 1
fi

# Get script directory for theme loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load theme system for consistent colors and icons - let it crash if not found
# shellcheck source=/dev/null
source "$SCRIPT_DIR/theme.sh"

# Logging functions using theme.sh color functions
log() { printf "%s%s%s\n" "$(color_primary)" "$1" "$(color_reset)"; }
error() { printf "%s%s%s\n" "$(color_error)" "$1" "$(color_reset)" >&2; }
success() { printf "%s%s%s\n" "$(color_success)" "$1" "$(color_reset)"; }
warning() { printf "%s%s%s\n" "$(color_warning)" "$1" "$(color_reset)"; }

# Configuration
# Convert Windows paths to MSYS format for bash commands
GIT_BASH_ROOT_POSIX="${GIT_BASH_ROOT//C:/\/c}"
PACKAGES_DIR="$GIT_BASH_ROOT_POSIX/home/portx/packages"
SH_WRAPPERS_DIR="$GIT_BASH_ROOT_POSIX/bin"
CMD_WRAPPERS_DIR="$GIT_BASH_ROOT_POSIX/cmd"
PORTX_PATH_CACHE="$HOME/.portx_path_cache"
PORTX_PACKAGES_CACHE="$HOME/.portx_packages_cache"
PORTX_TOOLS_CACHE="$HOME/.portx_tools_cache"
PORTX_IMPORT_LOG_FILE="$HOME/portx-packages-import.log"
# Legacy verify log file variable removed

# Function for debug logging (only to file)
debug_log() {
    local log_file="${1:-$PORTX_IMPORT_LOG_FILE}"
    local message="${2:-}"
    if [[ -z "$message" ]]; then
        message="$1"
        log_file="$PORTX_IMPORT_LOG_FILE"
    fi
    printf "[DEBUG] %s\n" "$message" >>"$log_file"
}

# Function for regular logging (to both screen and file)
info_log() {
    local log_file="${1:-$PORTX_IMPORT_LOG_FILE}"
    local message="$2"
    if [[ -z "$message" ]]; then
        message="$1"
        log_file="$PORTX_IMPORT_LOG_FILE"
    fi
    printf "%s\n" "$message" | tee -a "$log_file"
}

# Counters
TOTAL_PACKAGES=0
TOTAL_EXECUTABLES=0
VALID_PACKAGES=0
WRAPPER_PACKAGES=0
PATH_PACKAGES=0

# Arrays  
WRAPPER_PACKAGE_NAMES=()
PATH_PACKAGE_PATHS=()

# Legacy wrapper testing constants removed

# Schema validation error codes
declare -g SCHEMA_VALID=0
declare -g SCHEMA_INVALID=20
declare -g SCHEMA_FILE_MISSING=21
declare -g JSON_SYNTAX_ERROR=22

# Method: Validate package.json against portx schema
validate_package_json() {
    local package_json_path="$1"
    
    debug_log "Validating: $package_json_path"
    
    # Check if package.json exists
    if [[ ! -f "$package_json_path" ]]; then
        debug_log "ERROR: package.json not found: $package_json_path"
        return $SCHEMA_FILE_MISSING
    fi
    
    # Use native portx validator (no external dependencies)
    local validator_script="$GIT_BASH_ROOT_POSIX/home/portx/scripts/validate-json.sh"
    if [[ -f "$validator_script" ]]; then
        if "$validator_script" "$package_json_path" >/dev/null 2>&1; then
            debug_log "SUCCESS: Schema validation passed: $package_json_path"
            return $SCHEMA_VALID
        else
            debug_log "ERROR: Schema validation failed: $package_json_path"
            # Show detailed validation errors
            "$validator_script" "$package_json_path" 2>&1 | while read -r line; do
                debug_log "  $line"
            done
            return $SCHEMA_INVALID
        fi
    else
        debug_log "WARNING: Native validator not found, using basic JSON syntax check"
        # Fallback to basic JSON syntax validation
        if ! cat "$package_json_path" | jq empty >/dev/null 2>&1; then
            debug_log "ERROR: Invalid JSON syntax in: $package_json_path"
            return $JSON_SYNTAX_ERROR
        fi
        return $SCHEMA_VALID
    fi
}

# Method: Test wrapper functionality with comprehensive error categorization
# Legacy test_wrapper_works() function removed - import does not test wrappers
test_wrapper_works_REMOVED() {
    # Function removed - import does not test wrappers, only validates executables exist
    return 1
}

# Method: Get executables from package.json (preferred) with defaultArgs
get_executables_from_json() {
    local pkg_dir="$1"
    local json_file="$pkg_dir/package.json"

    if [[ -f "$json_file" ]]; then
        # NEW SCHEMA: Extract executables from bin object: "path|defaultArgs"
        # First try new schema (bin object)
        local bin_executables
        bin_executables=$(parse_json_with_comments "$json_file" '.bin // {} | to_entries[]? | "\(.value.path)|\(.value.defaultArgs // "")"')
        
        if [[ -n "$bin_executables" ]]; then
            echo "$bin_executables"
            return
        fi
        
        # LEGACY FALLBACK: Extract from old tools array for backward compatibility
        parse_json_with_comments "$json_file" '.tools[]? | select(.executable) | "\(.executable)|\(.defaultArgs // "")"'
    fi
}

# Method: Get executables by scanning directory (for validation)
get_scanned_executables() {
    local pkg_dir="$1"
    debug_log "Scanning for executables in: $pkg_dir"
    
    # Find executables in package directory and subdirectories
    # Support Windows executables only: .exe, .bat, .cmd
    local result
    result=$(find "$pkg_dir" \
        \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) \
        -type f -exec basename {} \; 2>/dev/null | sort -u)
    
    # Also find extensionless executables (like 'liquibase', 'az')
    local extensionless
    extensionless=$(find "$pkg_dir" -type f ! -name "*.txt" ! -name "*.md" ! -name "*.json" \
        ! -name "*.dll" ! -name "*.so" ! -name "*.conf" ! -name "*.config" ! -name "*.xml" \
        ! -name "*.ini" ! -name "*.log" ! -name "*.zip" ! -name "*.tar*" ! -name "*.gz" \
        ! -name "*.*" -executable -exec basename {} \; 2>/dev/null | sort -u)
    
    # Combine both results and remove duplicates
    result=$(printf "%s\n%s\n" "$result" "$extensionless" | grep -v "^$" | sort -u)
    
    debug_log "Found executables: $result"
    echo "$result"
}

# Method: Parse package JSON for declared tools
parse_package_manual() {
    local pkg_dir="$1"
    local json_file="$pkg_dir/package.json"

    if [[ ! -f "$json_file" ]]; then
        echo ""
        return
    fi

    # NEW SCHEMA: Extract executables from bin object
    local bin_executables
    bin_executables=$(parse_json_with_comments "$json_file" '.bin // {} | to_entries[]? | .value.path' | sort -u)
    
    if [[ -n "$bin_executables" ]]; then
        echo "$bin_executables"
        return
    fi

    # LEGACY FALLBACK: Extract executables from JSON tools array
    parse_json_with_comments "$json_file" '.tools[]?.executable // empty' | sort -u
}

# Method: Get package import type (path, wrap, or auto/default)
# Clean JSON by stripping comments and unnatural characters for jq processing
# Research-based solution: Stack Overflow + GNU sed + Unix tr best practices
clean_json_for_jq() {
    local json_file="$1"
    # Stack Overflow proven pattern + GNU sed multi-line comments + tr control chars
    sed -e '/^[[:blank:]]*#/d' -e 's|//.*||' -e 's|/\*.*\*/||g' "$json_file" | \
    tr -d '\000-\011\013-\037\177'
}

# Helper function to parse JSON with comments
parse_json_with_comments() {
    local json_file="$1"
    local jq_filter="$2"
    
    # Special handling for importType - direct extraction avoids jq parsing issues
    if [[ "$jq_filter" == '.importType // empty' ]]; then
        grep '"importType"' "$json_file" | sed 's|.*"importType"[[:space:]]*:[[:space:]]*"||' | sed 's|".*||' | head -1
    else
        clean_json_for_jq "$json_file" | "$GIT_BASH_ROOT_POSIX/home/portx/packages/jq/jq.exe" -r "$jq_filter" 2>/dev/null || echo ""
    fi
}

get_import_type() {
    local pkg_dir="$1"
    local json_file="$pkg_dir/package.json"

    if [[ ! -f "$json_file" ]]; then
        echo "auto" # No package.json, use default behavior
        return
    fi

    # Check importType field using comment-aware JSON parser
    local import_type
    import_type=$(parse_json_with_comments "$json_file" '.importType // empty')

    case "$import_type" in
        "path")
            echo "path"
            ;;
        "wrap")
            echo "wrap"
            ;;
        *)
            echo "auto" # Default behavior: try wrappers, fallback to path
            ;;
    esac
}

# Method: Validate package integrity
# Legacy validate_package() function removed - use validate_package_comprehensive() instead  
validate_package_REMOVED() {
    # Legacy function removed - use validate_package_comprehensive() instead
    return 1
}

# Method: Comprehensive package validation with schema and executable verification
validate_package_comprehensive() {
    local pkg_dir="$1"
    local pkg_name="$2"
    local json_file="$pkg_dir/package.json"
    
    printf "    Validating: %s\n" "$pkg_name"
    debug_log "=== COMPREHENSIVE VALIDATION: $pkg_name ==="
    debug_log "Package directory: $pkg_dir"
    debug_log "JSON file: $json_file"
    
    # STEP 1: Check package.json exists
    if [[ ! -f "$json_file" ]]; then
        printf "%sCRITICAL ERROR: Missing package.json%s\n" "$(color_error)" "$(color_reset)" >&2
        printf "Package: %s\n" "$pkg_name" >&2
        printf "Path: %s\n" "$pkg_dir" >&2
        printf "Cannot proceed - package.json is required for all packages\n" >&2
        debug_log "FATAL: Missing package.json for $pkg_name"
        return 1
    fi
    debug_log "✓ package.json exists"
    
    # STEP 2: Validate JSON schema with comprehensive validation
    printf "      Checking JSON schema...\n"
    debug_log "Running comprehensive schema validation..."
    if ! bash "$SCRIPT_DIR/validate-json.sh" "$json_file" >/dev/null 2>&1; then
        local validation_output
        validation_output=$(bash "$SCRIPT_DIR/validate-json.sh" "$json_file" 2>&1)
        
        printf "%sCRITICAL ERROR: Invalid package.json schema%s\n" "$(color_error)" "$(color_reset)" >&2
        printf "Package: %s\n" "$pkg_name" >&2
        printf "Path: %s\n" "$json_file" >&2
        printf "\n" >&2
        printf "Schema validation failed - package MUST be 100%% compliant\n" >&2
        printf "Validation errors:\n" >&2
        while IFS= read -r line; do
            printf "  %s\n" "$line" >&2
        done <<<"$validation_output"
        printf "\n" >&2
        printf "Fix the schema issues and re-run import\n" >&2
        debug_log "FATAL: Schema validation failed for $pkg_name"
        debug_log "Validation output: $validation_output"
        return 1
    fi
    debug_log "✓ JSON schema validation passed"
    
    # STEP 3: Parse executables and verify each one exists
    printf "      Checking executable files...\n"
    debug_log "Parsing executables from package.json..."
    
    local declared_executables
    declared_executables=$(parse_package_manual "$pkg_dir")
    
    if [[ -z "$declared_executables" ]]; then
        debug_log "No executables declared in package.json, checking for any files..."
        local scanned_executables
        scanned_executables=$(get_scanned_executables "$pkg_dir")
        if [[ -z "$scanned_executables" ]]; then
            warning "Package $pkg_name has no executables (documentation package?)"
            debug_log "✓ No executables found (acceptable for documentation packages)"
            return 0
        fi
        debug_log "Found undeclared executables: $scanned_executables"
    fi
    
    # STEP 4: Verify each declared executable exists at specified path
    if [[ -n "$declared_executables" ]]; then
        local exe_count=0
        local exe_verified=0
        while IFS= read -r exe_path; do
            [[ -z "$exe_path" ]] && continue
            # Strip carriage returns from exe_path (Windows line ending issue)
            exe_path="${exe_path//$'\r'/}"
            exe_count=$((exe_count + 1))
            
            local full_exe_path="$pkg_dir/$exe_path"
            debug_log "Checking executable: $exe_path -> $full_exe_path"
            printf "        Verifying: %s\n" "$exe_path"
            
            debug_log "Testing file existence: $full_exe_path"
            
            if [[ ! -f "$full_exe_path" ]]; then
                printf "%sCRITICAL ERROR: Missing executable file%s\n" "$(color_error)" "$(color_reset)" >&2
                printf "Package: %s\n" "$pkg_name" >&2
                printf "Declared path: %s\n" "$exe_path" >&2
                printf "Full path: %s\n" "$full_exe_path" >&2
                printf "\n" >&2
                printf "All declared executables MUST exist at their specified paths\n" >&2
                printf "Check package.json paths and directory structure\n" >&2
                debug_log "FATAL: Missing executable $exe_path in package $pkg_name"
                debug_log "Expected at: $full_exe_path"
                return 1
            fi
            exe_verified=$((exe_verified + 1))
            debug_log "✓ Verified executable: $exe_path"
        done <<<"$declared_executables"
        
        printf "      %sAll %d executables verified%s\n" "$(color_pale_green)" "$exe_verified" "$(color_reset)"
        debug_log "✓ All $exe_verified/$exe_count executables verified successfully"
    fi
    
    debug_log "✓ COMPREHENSIVE VALIDATION PASSED: $pkg_name"
    return 0
}

# Method: Check if command conflicts with existing binaries
has_command_conflict() {
    local cmd_name="$1"

    # Check if command exists in system PATH (Git Bash bin/)
    if command -v "$cmd_name" >/dev/null 2>&1; then
        return 0 # Conflict found
    fi

    return 1 # No conflict
}

# Method: Create bash wrapper scripts only
create_bash_wrappers() {
    local pkg_dir="$1"
    local pkg_name="$2"
    local executables

    # Primary: Use package.json executables with defaultArgs
    executables=$(get_executables_from_json "$pkg_dir")

    # Fallback: If no package.json executables, scan directory (no defaultArgs)
    if [[ -z "$executables" ]]; then
        debug_log "    No executables in package.json, falling back to directory scan"
        local scanned_exes
        scanned_exes=$(get_scanned_executables "$pkg_dir")
        if [[ -n "$scanned_exes" ]]; then
            # Convert to "executable|" format (no defaultArgs)
            executables=""
            while IFS= read -r exe; do
                executables+="${exe}|"$'\n'
            done <<<"$scanned_exes"
            debug_log "    Found $(echo "$scanned_exes" | wc -l) executables by scanning"
        else
            debug_log "    No executables found by scanning, skipping package"
            return 1
        fi
    fi

    debug_log "    Found executables in $pkg_name: $(echo "$executables" | wc -l) files"
    if [[ -z "$executables" ]]; then
        debug_log "    No executables found in package"
        return 1
    fi

    local created_wrappers=0

    # Create bash wrappers - parse executable|defaultArgs format
    while IFS='|' read -r exe_name default_args; do
        if [[ -n "$exe_name" ]]; then
            local cmd_name
            cmd_name="$(basename "${exe_name%.*}")"
            local exe_file="$pkg_dir/$exe_name"

            if [[ ! -f "$exe_file" ]]; then
                debug_log "      SKIPPED: Executable does not exist: $exe_file"
                continue
            fi

            if has_command_conflict "$cmd_name"; then
                debug_log "      WARNING: $cmd_name conflicts with existing command, but creating wrapper anyway"
            fi

            local wrapper_sh="$SH_WRAPPERS_DIR/$cmd_name"
            
            # Create shell wrapper for Git Bash with defaultArgs
            mkdir -p "$SH_WRAPPERS_DIR"
            local posix_exe_path="$GIT_BASH_ROOT_POSIX/home/portx/packages/$pkg_name/$exe_name"
            if [[ -n "$default_args" && "$default_args" != "" ]]; then
                cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name with defaultArgs
exec "$posix_exe_path" $default_args "\$@"
WRAPPER_EOF
            else
                cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name
exec "$posix_exe_path" "\$@"
WRAPPER_EOF
            fi
            chmod +x "$wrapper_sh"
            printf "    BASH: %s -> %s\n" "$cmd_name" "$wrapper_sh" >&2
            debug_log "      Created bash wrapper for: $cmd_name"
            debug_log "      Target exe: $exe_file"
            created_wrappers=$((created_wrappers + 1))
        fi
    done <<<"$executables"

    # Return 0 if any wrappers created, 1 if none created
    [[ $created_wrappers -gt 0 ]]
}

# Method: Create cmd wrapper scripts only  
create_cmd_wrappers() {
    local pkg_dir="$1"
    local pkg_name="$2"
    local executables

    # Primary: Use package.json executables with defaultArgs
    executables=$(get_executables_from_json "$pkg_dir")

    # Fallback: If no package.json executables, scan directory (no defaultArgs)
    if [[ -z "$executables" ]]; then
        debug_log "    No executables in package.json, falling back to directory scan"
        local scanned_exes
        scanned_exes=$(get_scanned_executables "$pkg_dir")
        if [[ -n "$scanned_exes" ]]; then
            # Convert to "executable|" format (no defaultArgs)
            executables=""
            while IFS= read -r exe; do
                executables+="${exe}|"$'\n'
            done <<<"$scanned_exes"
            debug_log "    Found $(echo "$scanned_exes" | wc -l) executables by scanning"
        else
            debug_log "    No executables found by scanning, skipping package"
            return 1
        fi
    fi

    debug_log "    Found executables in $pkg_name: $(echo "$executables" | wc -l) files"
    if [[ -z "$executables" ]]; then
        debug_log "    No executables found in package"
        return 1
    fi

    local created_wrappers=0

    # Create cmd wrappers - parse executable|defaultArgs format
    while IFS='|' read -r exe_name default_args; do
        if [[ -n "$exe_name" ]]; then
            local cmd_name
            cmd_name="$(basename "${exe_name%.*}")"
            local exe_file="$pkg_dir/$exe_name"

            if [[ ! -f "$exe_file" ]]; then
                debug_log "      SKIPPED: Executable does not exist: $exe_file"
                continue
            fi

            if has_command_conflict "$cmd_name"; then
                debug_log "      WARNING: $cmd_name conflicts with existing command, but creating wrapper anyway"
            fi

            local wrapper_cmd="$CMD_WRAPPERS_DIR/$cmd_name.cmd"
            
            # Create .cmd wrapper for Windows with defaultArgs  
            mkdir -p "$CMD_WRAPPERS_DIR"
            if [[ -n "$default_args" && "$default_args" != "" ]]; then
                printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s with defaultArgs\n"C:\\App\\Git\\home\\portx\\packages\\%s\\%s" %s %%*\n' "$pkg_name" "$pkg_name" "$exe_name" "$default_args" >"$wrapper_cmd"
            else
                printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s\n"C:\\App\\Git\\home\\portx\\packages\\%s\\%s" %%*\n' "$pkg_name" "$pkg_name" "$exe_name" >"$wrapper_cmd"
            fi
            printf "    CMD:  %s -> %s\n" "$cmd_name" "$wrapper_cmd" >&2
            debug_log "      Created cmd wrapper for: $cmd_name"
            debug_log "      Target exe: $exe_file"
            created_wrappers=$((created_wrappers + 1))
        fi
    done <<<"$executables"

    # Return 0 if any wrappers created, 1 if none created
    [[ $created_wrappers -gt 0 ]]
}

# Method: Create wrapper scripts (import only - no testing) - LEGACY FUNCTION
create_wrappers() {
    local pkg_dir="$1"
    local pkg_name="$2"
    local executables

    # Primary: Use package.json executables with defaultArgs
    executables=$(get_executables_from_json "$pkg_dir")

    # Fallback: If no package.json executables, scan directory (no defaultArgs)
    if [[ -z "$executables" ]]; then
        debug_log "    No executables in package.json, falling back to directory scan"
        local scanned_exes
        scanned_exes=$(get_scanned_executables "$pkg_dir")
        if [[ -n "$scanned_exes" ]]; then
            # Convert to "executable|" format (no defaultArgs)
            executables=""
            while IFS= read -r exe; do
                executables+="${exe}|"$'\n'
            done <<<"$scanned_exes"
            debug_log "    Found $(echo "$scanned_exes" | wc -l) executables by scanning"
        else
            debug_log "    No executables found by scanning, skipping package"
            return 1
        fi
    fi

    debug_log "    Found executables in $pkg_name: $(echo "$executables" | wc -l) files"
    if [[ -z "$executables" ]]; then
        debug_log "    No executables found in package"
        return 1
    fi

    local created_wrappers=0

    # Create wrappers - parse executable|defaultArgs format
    while IFS='|' read -r exe_name default_args; do
        if [[ -n "$exe_name" ]]; then
            local cmd_name
            cmd_name="$(basename "${exe_name%.*}")"
            local exe_file="$pkg_dir/$exe_name"

            # Clean up empty default_args
            [[ -z "$default_args" ]] && default_args=""

            debug_log "      Processing executable: $exe_name -> $cmd_name (args: '$default_args')"

            # Check for command conflicts before creating wrappers
            if has_command_conflict "$cmd_name"; then
                debug_log "      WARNING: $cmd_name conflicts with existing command, but creating wrapper anyway"
            fi

            local wrapper_cmd="$CMD_WRAPPERS_DIR/$cmd_name.cmd"
            local wrapper_sh="$SH_WRAPPERS_DIR/$cmd_name"

            # Create .cmd wrapper for Windows with defaultArgs  
            mkdir -p "$CMD_WRAPPERS_DIR"
            if [[ -n "$default_args" && "$default_args" != "" ]]; then
                printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s with defaultArgs\n"C:\\App\\Git\\home\\portx\\packages\\%s\\%s" %s %%*\n' "$pkg_name" "$pkg_name" "$exe_name" "$default_args" >"$wrapper_cmd"
            else
                printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s\n"C:\\App\\Git\\home\\portx\\packages\\%s\\%s" %%*\n' "$pkg_name" "$pkg_name" "$exe_name" >"$wrapper_cmd"
            fi

            # Create shell wrapper for Git Bash with defaultArgs
            local posix_exe_path="$GIT_BASH_ROOT_POSIX/home/portx/packages/$pkg_name/$exe_name"
            if [[ -n "$default_args" && "$default_args" != "" ]]; then
                cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name with defaultArgs
exec "$posix_exe_path" $default_args "\$@"
WRAPPER_EOF
            else
                cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name
exec "$posix_exe_path" "\$@"
WRAPPER_EOF
            fi
            chmod +x "$wrapper_sh"

            debug_log "      Created wrappers for: $cmd_name"
            debug_log "      Target exe: $exe_file"

            created_wrappers=$((created_wrappers + 2)) # 1 sh + 1 cmd file
        fi
    done <<<"$executables"

    # Return 0 if any wrappers created, 1 if none created
    [[ $created_wrappers -gt 0 ]]
}

# Method: Add package to PATH configuration
add_to_path() {
    local pkg_path="$1"
    local pkg_name="$2"

    # Add to PATH_PACKAGE_PATHS array for cache generation
    PATH_PACKAGE_PATHS+=("$pkg_path")
    debug_log "Added $pkg_path to PATH_PACKAGE_PATHS array"
    return 0
}

# ===== BOOLEAN EXPRESSION PARSER FOR TAG FILTERING =====

# Global variables for parser state
declare -g PARSER_TOKENS=()
declare -g PARSER_POS=0

# Method: Tokenize boolean expression into array of tokens
tokenize_expression() {
    local expression="$1"
    PARSER_TOKENS=()
    PARSER_POS=0
    
    # Remove extra whitespace and normalize
    expression=$(echo "$expression" | sed 's/[[:space:]]*&[[:space:]]*/\&/g' | sed 's/[[:space:]]*|[[:space:]]*/|/g' | sed 's/[[:space:]]*![[:space:]]*/!/g')
    
    local i=0
    local token=""
    
    while [[ $i -lt ${#expression} ]]; do
        local char="${expression:$i:1}"
        
        case "$char" in
            '&'|'|'|'!'|'('|')')
                # End current token if exists
                if [[ -n "$token" ]]; then
                    PARSER_TOKENS+=("$token")
                    token=""
                fi
                # Add operator/bracket as token
                PARSER_TOKENS+=("$char")
                ;;
            ' '|$'\t')
                # End current token on whitespace
                if [[ -n "$token" ]]; then
                    PARSER_TOKENS+=("$token")
                    token=""
                fi
                ;;
            *)
                # Add character to current token
                token="$token$char"
                ;;
        esac
        ((i++))
    done
    
    # Add final token if exists
    if [[ -n "$token" ]]; then
        PARSER_TOKENS+=("$token")
    fi
}

# Method: Get current token
get_current_token() {
    if [[ $PARSER_POS -lt ${#PARSER_TOKENS[@]} ]]; then
        echo "${PARSER_TOKENS[$PARSER_POS]}"
    else
        echo ""
    fi
}

# Method: Advance to next token
advance_token() {
    ((PARSER_POS++))
}

# Method: Parse OR expressions (lowest precedence)
parse_or_expression() {
    local package_tags_array=("$@")
    
    local result
    if ! parse_and_expression "${package_tags_array[@]}"; then
        result=1
    else
        result=0
    fi
    
    while [[ "$(get_current_token)" == "|" ]]; do
        advance_token
        if parse_and_expression "${package_tags_array[@]}"; then
            result=0  # OR: if any operand is true, result is true
        fi
    done
    
    return $result
}

# Method: Parse AND expressions (medium precedence)
parse_and_expression() {
    local package_tags_array=("$@")
    
    local result
    if ! parse_not_expression "${package_tags_array[@]}"; then
        result=1
    else
        result=0
    fi
    
    while [[ "$(get_current_token)" == "&" ]]; do
        advance_token
        if ! parse_not_expression "${package_tags_array[@]}"; then
            result=1  # AND: if any operand is false, result is false
        fi
    done
    
    return $result
}

# Method: Parse NOT expressions (highest precedence)
parse_not_expression() {
    local package_tags_array=("$@")
    
    if [[ "$(get_current_token)" == "!" ]]; then
        advance_token
        if parse_term "${package_tags_array[@]}"; then
            return 1  # NOT: invert result
        else
            return 0
        fi
    else
        parse_term "${package_tags_array[@]}"
    fi
}

# Method: Parse terms (tag names and parentheses)
parse_term() {
    local package_tags_array=("$@")
    local token
    token=$(get_current_token)
    
    if [[ "$token" == "(" ]]; then
        advance_token
        local result
        if parse_or_expression "${package_tags_array[@]}"; then
            result=0
        else
            result=1
        fi
        
        # Expect closing parenthesis
        if [[ "$(get_current_token)" == ")" ]]; then
            advance_token
        fi
        
        return $result
    elif [[ -n "$token" && "$token" != "&" && "$token" != "|" && "$token" != "!" && "$token" != ")" ]]; then
        advance_token
        # Use fuzzy tag matching for the term
        evaluate_tag_fuzzy "$token" "${package_tags_array[@]}"
    else
        return 1  # Invalid token
    fi
}

# Method: Ultra-fast fuzzy tag matching using pure bash
evaluate_tag_fuzzy() {
    local tag_pattern="$1"
    shift
    local package_tags_array=("$@")
    local pattern_lower="${tag_pattern,,}"
    
    for tag in "${package_tags_array[@]}"; do
        if [[ "${tag,,}" == *"$pattern_lower"* ]]; then
            return 0  # Match found
        fi
    done
    return 1  # No match
}

# Method: Main boolean expression evaluator
parse_boolean_expression() {
    local expression="$1"
    shift
    local package_tags_array=("$@")
    
    # Handle empty expression (match everything)
    if [[ -z "$expression" ]]; then
        return 0
    fi
    
    # Tokenize and parse
    tokenize_expression "$expression"
    PARSER_POS=0
    
    parse_or_expression "${package_tags_array[@]}"
}

# ===== SMART LRU CACHE MANAGEMENT =====

# Method: Get cached result for tag filter expression
get_cached_result() {
    local query_key="$1"
    local cache_file="$HOME/.portx_tag_cache"
    
    if [[ -f "$cache_file" ]]; then
        grep "^${query_key}:" "$cache_file" 2>/dev/null | tail -1 | cut -d':' -f3- || true
    fi
}

# Method: Save result to cache with LRU management
save_to_cache() {
    local query_key="$1"
    local result="$2"
    local cache_file="$HOME/.portx_tag_cache"
    local temp_file="$cache_file.tmp"
    
    # Handle permanent "no_tags" entry
    if [[ "$query_key" == "no_tags" ]]; then
        # Remove old no_tags entry if exists
        if [[ -f "$cache_file" ]]; then
            grep -v "^no_tags:" "$cache_file" > "$temp_file" 2>/dev/null || touch "$temp_file"
        else
            touch "$temp_file"
        fi
        # Add permanent no_tags entry
        echo "no_tags:permanent:${result}" >> "$temp_file"
        mv "$temp_file" "$cache_file"
        return 0
    fi
    
    # Handle regular LRU entries
    local timestamp
    timestamp=$(date +%s)
    
    # Create temp file with existing entries except the one we're updating
    if [[ -f "$cache_file" ]]; then
        grep -v "^${query_key}:" "$cache_file" > "$temp_file" 2>/dev/null || touch "$temp_file"
    else
        touch "$temp_file"
    fi
    
    # Add new entry
    echo "${query_key}:${timestamp}:${result}" >> "$temp_file"
    
    # Keep no_tags (permanent) + 10 most recent tagged queries
    {
        grep "^no_tags:" "$temp_file" 2>/dev/null || true
        grep -v "^no_tags:" "$temp_file" 2>/dev/null | sort -t: -k2 -n | tail -10
    } > "$cache_file"
    
    rm -f "$temp_file"
}

# Import packages function (main package processing logic - no verification)
import_packages() {
    # Clear the log file at start
    echo "PORTX Package Import - $(date)" >"$PORTX_IMPORT_LOG_FILE"
    debug_log "Starting package import scan..."

    printf "Importing portx packages\n" >&2
    printf "Scanning packages for import types...\n" >&2

    # Cleanup at beginning - remove old cache files and wrappers
    rm -f "$PORTX_PATH_CACHE" "$PORTX_PACKAGES_CACHE" "$PORTX_TOOLS_CACHE"

    # Remove PORTX wrapper files from both bin and cmd directories
    # Safe deletion: only remove PORTX-tagged wrappers (.sh and .cmd files)
    for wrapper_dir in "$SH_WRAPPERS_DIR" "$CMD_WRAPPERS_DIR"; do
        if [[ -d "$wrapper_dir" ]]; then
            for file in "$wrapper_dir"/*; do
                if [[ -f "$file" ]] && head -n 3 "$file" 2>/dev/null | grep -q "PORTX-WRAPPER"; then
                    debug_log "      Removing PORTX wrapper: $file"
                    rm -f "$file"
                fi
            done
        fi
    done
    mkdir -p "$SH_WRAPPERS_DIR"

    # Main processing loop - comprehensive validation before import
    for pkg_path in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_path" ]]; then
            pkg_name="$(basename "$pkg_path")"
            TOTAL_PACKAGES=$((TOTAL_PACKAGES + 1))
            
            printf "  Processing: %s\n" "$pkg_name"
            debug_log "=== PROCESSING PACKAGE: $pkg_name ==="
            debug_log "Package path: $pkg_path"

            # COMPREHENSIVE VALIDATION: Schema + executable verification
            if ! validate_package_comprehensive "$pkg_path" "$pkg_name"; then
                debug_log "Package $pkg_name failed comprehensive validation - SKIPPING"
                continue
            fi

            VALID_PACKAGES=$((VALID_PACKAGES + 1))
            import_type=$(get_import_type "$pkg_path" 2>/dev/null || echo "auto")
            debug_log "Package $pkg_name validated successfully, importType: $import_type"

            case "$import_type" in
                "path")
                    # Force PATH mode - skip wrapper creation entirely
                    printf "  PATH: %s\n" "$pkg_name" >&2
                    debug_log "Forcing PATH mode for $pkg_name"
                    add_to_path "$pkg_path" "$pkg_name"
                    PATH_PACKAGES=$((PATH_PACKAGES + 1))
                    ;;
                "none")
                    # Documentation package - skip import entirely
                    printf "  SKIP: %s (documentation only)\n" "$pkg_name" >&2
                    debug_log "Skipping documentation package $pkg_name"
                    ;;
                *)
                    # Default wrapper creation logic  
                    debug_log "Creating wrappers for $pkg_name"
                    
                    # Create bash wrapper (always)
                    debug_log "About to create bash wrappers for $pkg_name"
                    if create_bash_wrappers "$pkg_path" "$pkg_name"; then
                        debug_log "Created bash wrappers for $pkg_name"
                        WRAPPER_PACKAGES=$((WRAPPER_PACKAGES + 1))
                        WRAPPER_PACKAGE_NAMES+=("$pkg_name")
                    else
                        debug_log "Failed to create bash wrappers for $pkg_name"
                    fi
                    
                    # Create .cmd wrapper (always)
                    debug_log "About to create cmd wrappers for $pkg_name"
                    if create_cmd_wrappers "$pkg_path" "$pkg_name"; then
                        debug_log "Created cmd wrappers for $pkg_name"
                    else
                        debug_log "Failed to create cmd wrappers for $pkg_name"
                    fi
                    ;;
            esac
        fi
    done

    # Count total executables after processing
    TOTAL_EXECUTABLES=0
    for pkg_path in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_path" ]]; then
            pkg_executables=$(get_scanned_executables "$pkg_path" | wc -l)
            TOTAL_EXECUTABLES=$((TOTAL_EXECUTABLES + pkg_executables))
        fi
    done

    # Build PATH configuration silently
    path_config=""

    # Add cmd (our wrappers)
    path_config="$CMD_WRAPPERS_DIR"

    # Add package directories for packages with dependencies
    for pkg_path in "${PATH_PACKAGE_PATHS[@]}"; do
        path_config="$path_config:$pkg_path"
    done

    # Save configuration with comprehensive header
    {
        echo "#!/bin/bash"
        echo "# PORTX PATH Cache"
        echo "# =========================="
        echo "#"
        echo "# PURPOSE: PORTX tools PATH integration"
        echo "# This provides fast access to all PORTX tools and packages"
        echo "#"
        echo "# GENERATION INFO:"
        echo "#   Generated: $(date '+%a, %b %d, %Y %l:%M:%S %p')"
        echo "#   Git Bash Directory: $GIT_BASH_ROOT"
        echo "#   Packages Directory: $PACKAGES_DIR"
        echo "#"
        echo "# TOOL COUNTS:"
        echo "#   Git for Windows: $(find "$GIT_BASH_ROOT_POSIX" -name "*.exe" -not -path "*/home/portx/packages/*" 2>/dev/null | wc -l) executables"
        echo "#   PORTX Wrappers: $(find "$CMD_WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l) wrappers"
        echo "#   PORTX Packages: $TOTAL_PACKAGES directories, $TOTAL_EXECUTABLES executables"
        echo "#   Total: $(($(find "$GIT_BASH_ROOT_POSIX" -name "*.exe" -not -path "*/home/portx/packages/*" 2>/dev/null | wc -l) + $(find "$CMD_WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l) + TOTAL_EXECUTABLES)) tools"
        echo "#"
        echo "# USAGE: This file is automatically sourced by .bashrc on shell startup."
        echo "# To regenerate: rm ~/.portx_cache or run 'portx import'"
        echo "#"
        echo "# CACHE INVALIDATION: Delete this file if any of the following change:"
        echo "#   - PORTX packages are added/removed/updated"
        echo "#   - PORTX installation is moved or modified"
        echo ""
        echo "# Git Bash Home: $GIT_BASH_ROOT"
        echo ""
        echo "# Build PORTX PACKAGES PATH"
        echo "PACKAGES_PATH=\"\""

        # Add package directories with executable counts
        for pkg_path in "${PATH_PACKAGE_PATHS[@]}"; do
            pkg_name="$(basename "$pkg_path")"
            exe_count=$(find "$pkg_path" -maxdepth 1 -name "*.exe" 2>/dev/null | wc -l)
            echo "PACKAGES_PATH=\"\$PACKAGES_PATH:$pkg_path\"  # $exe_count executables"
        done

        echo "# PORTX packages added: $PATH_PACKAGES directories"
        echo ""
        echo "# NOTE: .bashrc controls PATH integration using PACKAGES_PATH"
        echo ""
        echo "# PORTX PATH statistics"

        # Calculate Git for Windows stats (directories with executables / total executables)  
        GFW_DIRS=$(find "$GIT_BASH_ROOT_POSIX/bin" "$GIT_BASH_ROOT_POSIX/mingw64/bin" "$GIT_BASH_ROOT_POSIX/usr/bin" -name "*.exe" -printf '%h\n' 2>/dev/null | sort -u | wc -l)
        GFW_EXECUTABLES=$(find "$GIT_BASH_ROOT_POSIX" -name "*.exe" -not -path "*/home/portx/packages/*" 2>/dev/null | wc -l)
        PORTX_WRAPPERS_COUNT=$(find "$CMD_WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l)
        TOTAL_COUNT=$((GFW_EXECUTABLES + PORTX_WRAPPERS_COUNT + TOTAL_EXECUTABLES))
        TOTAL_DIRS=$((GFW_DIRS + PATH_PACKAGES))

        # Raw structured data - following best practices
        # Generate environment info directly (avoid function dependency)
        env_info=""
        if [[ -n "$MSYSTEM" ]]; then
            env_info="MSYS2-$MSYSTEM"
        elif [[ -n "$CYGWIN" ]]; then
            env_info="Cygwin"
        elif [[ "$OSTYPE" == "msys" ]]; then
            env_info="MSYS"
        elif [[ -n "$WSL_DISTRO_NAME" ]]; then
            env_info="WSL-$WSL_DISTRO_NAME"
        else
            env_info="Unknown"
        fi
        # Add terminal type if available
        if [[ -n "$TERM" ]]; then
            env_info="$env_info/$TERM"
        fi
        echo "export PORTX_ENV_TYPE=\"$env_info\""
        echo "export GFW_DIRS=$GFW_DIRS"
        echo "export GFW_EXECUTABLES=$GFW_EXECUTABLES" 
        echo "export PORTX_PKG_DIRS=$TOTAL_PACKAGES"
        echo "export PORTX_PKG_EXECUTABLES=$TOTAL_EXECUTABLES"
        echo "export PORTX_TOTAL_EXECUTABLES=$TOTAL_COUNT"
        echo "export PORTX_TOTAL_DIRS=$TOTAL_DIRS"
        echo "export PORTX_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
        echo "export PATH_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
        echo ""
    } >"$PORTX_PATH_CACHE"

    # Count actual wrapper files created
    local bash_wrappers=$(find "$SH_WRAPPERS_DIR" -name "*" -type f 2>/dev/null | wc -l)
    local cmd_wrappers=$(find "$CMD_WRAPPERS_DIR" -name "*.cmd" -type f 2>/dev/null | wc -l)
    local total_wrappers=$((bash_wrappers + cmd_wrappers))
    
    printf "Imported %d packages, %d executables, %d PATH packages, %d wrapper packages (%d total wrappers: %d bash + %d cmd)\n" \
        "$TOTAL_PACKAGES" "$TOTAL_EXECUTABLES" "$PATH_PACKAGES" "$WRAPPER_PACKAGES" "$total_wrappers" "$bash_wrappers" "$cmd_wrappers" >&2
}

# Verify packages function (validation and wrapper testing)
# Legacy verify_packages() function removed - use import with validate_package_comprehensive() instead
verify_packages_REMOVED() {
    # Legacy verify function removed - use 'portx packages import' instead for validation
    echo "ERROR: verify command removed. Use 'portx packages import' for package validation." >&2
    return 1
}

# ===== TOOLS AGGREGATOR FUNCTIONALITY (from portx.sh backup) =====

# Show manual function
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
        echo "Try: portx packages list"
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

# List all tools in flat format - one line separated by comma with boolean tag filtering
list_tools_flat() {
    local filter_expression="$1"
    local cache_key="${filter_expression:-no_tags}"
    
    # Try cache first using smart LRU cache
    local cached_result
    cached_result=$(get_cached_result "$cache_key")
    if [[ -n "$cached_result" ]]; then
        echo "$cached_result"
        return 0
    fi
    
    # Generate fresh result
    local all_tools=()
    
    # Check if packages directory exists
    if [[ ! -d "$PACKAGES_DIR" ]]; then
        return 1
    fi
    
    # Check if jq is available
    local JQ_CMD=""
    if command -v jq >/dev/null 2>&1; then
        JQ_CMD="jq"
    elif command -v jq.cmd >/dev/null 2>&1; then
        JQ_CMD="jq.cmd"
    else
        return 1
    fi
    
    for pkg_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_dir" && -f "$pkg_dir/package.json" ]]; then
            # If filter expression is provided, filter at tool level (checking both tool and package tags)
            if [[ -n "$filter_expression" ]]; then
                # Use jq to extract tools with combined package+tool tags, then filter in bash
                while IFS='|' read -r exe_name tag_list; do
                    if [[ -n "$exe_name" ]]; then
                        # Parse combined tags into bash array for boolean evaluation
                        local combined_tags=()
                        if [[ -n "$tag_list" ]]; then
                            # Split comma-separated tags and clean them
                            IFS=',' read -ra tag_array <<< "$tag_list"
                            for tag in "${tag_array[@]}"; do
                                # Remove carriage returns and whitespace
                                tag="${tag//$'\r'/}"
                                tag=$(echo "$tag" | xargs)
                                if [[ -n "$tag" ]]; then
                                    combined_tags+=("$tag")
                                fi
                            done
                        fi
                        
                        # Check if this tool's combined tags match the filter expression
                        if [[ ${#combined_tags[@]} -gt 0 ]]; then
                            # Fast path for simple single tag filters (90% of cases)
                            if [[ "$filter_expression" != *"|"* && "$filter_expression" != *"&"* && "$filter_expression" != *"("* ]]; then
                                # Simple tag match - just check if tag exists in array
                                local found=false
                                for tag in "${combined_tags[@]}"; do
                                    if [[ "$tag" == "$filter_expression" ]]; then
                                        found=true
                                        break
                                    fi
                                done
                                if [[ "$found" == true ]]; then
                                    exe_name="${exe_name//$'\r'/}"
                                    all_tools+=("$exe_name")
                                fi
                            else
                                # Complex boolean expression - use parser
                                if parse_boolean_expression "$filter_expression" "${combined_tags[@]}"; then
                                    exe_name="${exe_name//$'\r'/}"
                                    all_tools+=("$exe_name")
                                fi
                            fi
                        fi
                    fi
                done < <($JQ_CMD -r '. as $root | .tools[]? | select(.executable) | "\(.executable)|\(((.tags // []) + ($root.tags // [])) | unique | join(","))"' "$pkg_dir/package.json" 2>/dev/null)
            else
                # No filter - extract all executables
                while IFS= read -r exe; do
                    if [[ -n "$exe" ]]; then
                        # Remove carriage returns
                        exe="${exe//$'\r'/}"
                        all_tools+=("$exe")
                    fi
                done < <($JQ_CMD -r '.tools[]?.executable // empty' "$pkg_dir/package.json" 2>/dev/null)
            fi
        fi
    done
    
    # Sort and output tools with comma delimiter
    local temp_file
    temp_file=$(mktemp)
    printf '%s\n' "${all_tools[@]}" > "$temp_file"
    
    # Use dos2unix to clean line endings, then sort and deduplicate
    dos2unix "$temp_file" 2>/dev/null || true
    local result
    result=$(sort -u "$temp_file" | tr '\n' ',' | sed 's/,$//')
    
    # Save to smart LRU cache
    save_to_cache "$cache_key" "$result"
    
    # Output result
    echo "$result"
    
    rm -f "$temp_file"
}



# List all packages in hierarchical format (package -> tools)
list_packages() {
    set +e # Disable strict error handling for this function
    
    # Check if cache exists and use it
    if [[ -f "$PORTX_PACKAGES_CACHE" ]]; then
        cat "$PORTX_PACKAGES_CACHE"
        return 0
    fi
    
    # Generate output and save to cache
    _generate_packages_list | tee "$PORTX_PACKAGES_CACHE"
    set -e # Re-enable strict error handling
}

# Terminal width and column layout constants
readonly DEFAULT_TERMINAL_WIDTH=160
readonly MIN_TERMINAL_WIDTH=80

# Helper function to detect terminal width
_detect_terminal_width() {
    local width
    # Try to detect terminal width
    if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        width=$(tput cols 2>/dev/null || echo "$DEFAULT_TERMINAL_WIDTH")
    elif [[ -n "${COLUMNS:-}" ]]; then
        width="$COLUMNS"
    else
        width="$DEFAULT_TERMINAL_WIDTH"  # Default to modern terminal width
    fi
    
    # Ensure minimum width
    if [[ $width -lt $MIN_TERMINAL_WIDTH ]]; then
        width="$MIN_TERMINAL_WIDTH"
    fi
    
    echo "$width"
}

# Helper function to calculate actual maximum width needed for tool names
_calculate_max_name_width() {
    local max_width=0
    local current_width
    
    # Determine jq command
    local JQ_CMD=""
    if command -v jq >/dev/null 2>&1; then
        JQ_CMD="jq"
    elif command -v jq.cmd >/dev/null 2>&1; then
        JQ_CMD="jq.cmd"
    else
        echo "30"  # fallback to reasonable width
        return
    fi
    
    for pkg_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_dir" && -f "$pkg_dir/package.json" ]]; then
            # Check package name width (no version)
            local pkg_name
            pkg_name=$(basename "$pkg_dir")
            current_width=${#pkg_name}
            if [[ $current_width -gt $max_width ]]; then
                max_width=$current_width
            fi
            
            # Check tool name widths (add 2 for "- " prefix)
            while IFS='|' read -r executable description tags; do
                if [[ -n "$executable" ]]; then
                    current_width=$((${#executable} + 2))  # Add 2 for "- " prefix
                    if [[ $current_width -gt $max_width ]]; then
                        max_width=$current_width
                    fi
                fi
            done < <($JQ_CMD -r '.tools[]? | "\(.executable // "")|\(.description // "")|\((.tags // []) | join(", "))"' "$pkg_dir/package.json" 2>/dev/null)
        fi
    done
    
    # Add some padding but ensure minimum width
    local result=$((max_width + 2))
    if [[ $result -lt 25 ]]; then
        result=25
    fi
    echo "$result"
}

# Helper function to return 2-column widths based on actual data
_get_column_widths() {
    local actual_name_width
    actual_name_width=$(_calculate_max_name_width)
    local desc_width=$((120 - actual_name_width - 1))
    echo "$actual_name_width:$desc_width"
}

# Helper function to wrap text with color escape sequence handling
_wrap_text() {
    local text="$1"
    local content_width="$2"  # Width available for content (without prefix)
    local first_line_prefix="$3"
    local continuation_prefix="$4"
    
    # If text fits within content width, return it (hashtag coloring disabled for now)
    if [[ ${#text} -le $content_width ]]; then
        printf "%s%s\n" "$first_line_prefix" "$text"
        return
    fi
    
    # Split into words for careful wrapping
    local words
    read -ra words <<< "$text"
    local current_line=""
    local is_first_line=true
    
    for word in "${words[@]}"; do
        # Check if adding word would exceed width
        local test_line
        if [[ -z "$current_line" ]]; then
            test_line="$word"
        else
            test_line="$current_line $word"
        fi
        
        if [[ ${#test_line} -le $content_width ]]; then
            current_line="$test_line"
        else
            # Output current line (hashtag coloring disabled for now)
            if [[ -n "$current_line" ]]; then
                if $is_first_line; then
                    printf "%s%s\n" "$first_line_prefix" "$current_line"
                    is_first_line=false
                else
                    printf "%s%s\n" "$continuation_prefix" "$current_line"
                fi
            fi
            current_line="$word"
        fi
    done
    
    # Output final line (hashtag coloring disabled for now)
    if [[ -n "$current_line" ]]; then
        if $is_first_line; then
            printf "%s%s\n" "$first_line_prefix" "$current_line"
        else
            printf "%s%s\n" "$continuation_prefix" "$current_line"
        fi
    fi
}

# Helper function to format a single tool entry with 2 columns using text wrapping
_format_tool_entry() {
    local executable="$1"
    local description="$2"
    local tags="$3"
    local name_width="$4"
    local desc_width="$5"
    
    # Prepare tool name with minus prefix
    local display_name="- $executable"
    
    # Concatenate description + tags in brackets: description [tag1, tag2, tag3]
    local combined_content="$description"
    # Strip carriage returns and whitespace from tags
    tags=$(echo "$tags" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -n "$tags" && "$tags" != "" ]]; then
        combined_content="$description [$tags]"
    fi
    
    # Create the prefixes for first line and continuation lines
    local first_line_prefix
    local continuation_prefix
    
    printf -v first_line_prefix "%-*s " "$name_width" "$display_name"
    printf -v continuation_prefix "%*s " "$name_width" ""
    
    
    # Use wrapping function to format the combined content
    _wrap_text "$combined_content" "$desc_width" "$first_line_prefix" "$continuation_prefix"
}

# Internal function to generate the packages list
_generate_packages_list() {
    
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

    # Get fixed column widths
    local column_widths
    column_widths=$(_get_column_widths)
    
    local name_width desc_width
    IFS=':' read -r name_width desc_width <<< "$column_widths"

    for pkg_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_dir" && -f "$pkg_dir/package.json" ]]; then
            local pkg_name
            pkg_name=$(basename "$pkg_dir")

            # Extract package metadata safely
            local pkg_description=""
            local tool_count=0

            pkg_description=$($JQ_CMD -r '.description // ""' "$pkg_dir/package.json" 2>/dev/null || echo "")
            tool_count=$($JQ_CMD -r '.tools // [] | length' "$pkg_dir/package.json" 2>/dev/null || echo "0")

            # Skip packages with no tools
            if [[ "$tool_count" -eq 0 ]]; then
                continue
            fi

            ((total_packages++))
            total_tools=$((total_tools + tool_count))

            # Display package header using authoritative left-aligned padding approach
            pkg_header="$pkg_name"
            printf "%s%-*s%s %s\n" "$(color_primary)" "$name_width" "$pkg_header" "$(color_reset)" "$pkg_description"

            # Format tools using the new 2-column layout
            while IFS='|' read -r executable description tags; do
                if [[ -n "$executable" ]]; then
                    _format_tool_entry "$executable" "$description" "$tags" \
                        "$name_width" "$desc_width"
                fi
            done < <($JQ_CMD -r '.tools[]? | "\(.executable // "")|\(.description // "")|\((.tags // []) | join(", "))"' "$pkg_dir/package.json" 2>/dev/null)
            echo
        fi
    done

    echo "Summary: $total_packages packages, $total_tools total tools"
}

# Search tools by pattern (simplified version - manual parsing removed)
search_tools() {
    local pattern="$1"
    local matches=0

    printf "%sSearching for '%s'...%s\n" "$(color_primary)" "$pattern" "$(color_reset)" >&2

    printf "\n%sSearch Results for '%s'%s\n" "$(color_success)" "$pattern" "$(color_reset)"
    echo

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
            local pkg_name
            pkg_name=$(basename "$pkg_dir")

            # Search in tools using jq
            while IFS='|' read -r executable description; do
                if [[ -n "$executable" ]] && echo "$executable $description" | grep -qi "$pattern"; then
                    printf "%-20s %-25s %s\n" "$executable" "($pkg_name)" "$description"
                    ((matches++))
                fi
            done < <($JQ_CMD -r '.tools[]? | "\(.executable // "")|\(.description // "")"' "$pkg_dir/package.json" 2>/dev/null)
        fi
    done

    echo
    printf "%sFound %d matches%s\n" "$(color_primary)" "$matches" "$(color_reset)"
}

# Show count statistics
show_tools_count() {
    local total_tools=0
    local total_packages=0
    declare -A package_counts

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
            ((total_packages++))
            local pkg_name
            pkg_name=$(basename "$pkg_dir")
            local package_tool_count=0

            package_tool_count=$($JQ_CMD -r '.tools // [] | length' "$pkg_dir/package.json" 2>/dev/null || echo "0")
            total_tools=$((total_tools + package_tool_count))
            package_counts["$pkg_name"]=$package_tool_count
        fi
    done

    printf "\n%sPORTX Tools Statistics%s\n" "$(color_success)" "$(color_reset)"
    printf "%sTotal Packages: %d%s\n" "$(color_primary)" "$total_packages" "$(color_reset)"
    printf "%sTotal Tools: %d%s\n" "$(color_primary)" "$total_tools" "$(color_reset)"
    echo

    echo
    printf "%sTop Packages by Tool Count:%s\n" "$(color_warning)" "$(color_reset)"
    for package in "${!package_counts[@]}"; do
        if [[ ${package_counts[$package]} -gt 0 ]]; then
            printf "  %-20s %d tools\n" "$package" "${package_counts[$package]}"
        fi
    done | sort -k3 -nr | head -10
}

# Handle packages commands (renamed from tools)
handle_packages_command() {
    local command="${1:-list}"

    case "$command" in
        import)
            import_packages
            ;;
        # verify command removed - use import instead
        list | ls)
            list_packages
            ;;
        search | find)
            if [[ -z "$2" ]]; then
                error "Search pattern required"
                echo "Usage: portx packages search <pattern>"
                exit 1
            fi
            search_tools "$2"
            ;;
        count | stats)
            show_tools_count
            ;;
        help | --help | -h)
            echo "PORTX Package Manager"
            echo
            echo "Usage: portx packages <command> [options]"
            echo
            echo "Commands:"
            echo "  import            Import and configure all packages"
            # verify command removed
            echo "  list              List all available tools"
            echo "  search PATTERN    Search tools by name or description"
            echo "  count             Show tool count statistics"
            echo "  help              Show this help message"
            echo
            echo "Examples:"
            echo "  portx packages import"
            # verify command removed
            echo "  portx packages list"
            echo "  portx packages search git"
            echo "  portx packages count"
            ;;
        *)
            error "Unknown packages command: $command"
            echo "Try: portx packages help"
            exit 1
            ;;
    esac
}

# Show help
show_help() {
    echo "PORTX Package Manager"
    echo
    echo "Usage: portx <command> [arguments]"
    echo
    echo "Commands:"
    echo "  packages [command]  Access PORTX tools aggregator"
    echo "  tools [--tags=...]  List all tools (flat, space-separated), optionally filter by tags"
    echo "  man <package>       Show package manual"
    echo "  help               Show this help"
    echo
    echo "Examples:"
    echo "  portx packages import"
    echo "  portx packages verify"
    echo "  portx packages list"
    echo "  portx packages search git"
    echo "  portx tools"
    echo "  portx tools --tags=bash"
    echo "  portx tools --tags=bash,security"
    echo "  portx man ag"
}

# Main script logic
main() {
    # Parse command
    local command="${1:-help}"

    case "$command" in
        "packages")
            # Handle packages command with all remaining arguments
            shift # Remove 'packages' from arguments
            handle_packages_command "$@"
            ;;
        "tools")
            # Parse --tags= argument
            local filter_tags=""
            for arg in "$@"; do
                if [[ "$arg" =~ ^--tags=(.+)$ ]]; then
                    filter_tags="${BASH_REMATCH[1]}"
                    break
                fi
            done
            list_tools_flat "$filter_tags"
            ;;
        "man" | "manual")
            show_manual "$2"
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
