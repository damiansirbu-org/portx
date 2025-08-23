#!/bin/bash
# PORTX Package Importer
# Imports packages into PORTX system: discover, validate, analyze dependencies, create wrappers, configure PATH
#
# Quality Assurance:
# - shellcheck: Static analysis for shell scripts
# - shfmt: Shell script formatting
# - shellspec: BDD testing framework for shell scripts
#
# To run quality checks:
# - shellcheck: $PACKAGES_DIR/shellcheck/shellcheck.exe scripts/analyze-packages.sh
# - shfmt format: $PACKAGES_DIR/shfmt/shfmt.exe -w -i 4 -ci scripts/analyze-packages.sh
# - shfmt check: $PACKAGES_DIR/shfmt/shfmt.exe -d -i 4 -ci scripts/analyze-packages.sh

set -euo pipefail

GIT_BASH_ROOT="${GIT_BASH_ROOT:-/c/App/Git}"
PACKAGES_DIR="$GIT_BASH_ROOT/home/portx/packages"
WRAPPERS_DIR="$GIT_BASH_ROOT/bin"
PORTX_PATH_FILE="$HOME/.portx_cache"
PORTX_LOG_FILE="$HOME/.portx_cache.log"

# Function for debug logging (only to file)
debug_log() {
    printf "[DEBUG] %s\n" "$1" >> "$PORTX_LOG_FILE"
}

# Function for regular logging (to both screen and file)
info_log() {
    printf "%s\n" "$1" | tee -a "$PORTX_LOG_FILE"
}

# Load theme system for consistent colors and icons - let it crash if not found
# shellcheck source=/dev/null
source "$HOME/scripts/theme.sh"

# Counters
TOTAL_PACKAGES=0
TOTAL_EXECUTABLES=0
VALID_PACKAGES=0
CORRUPTED_PACKAGES=0
WRAPPER_PACKAGES=0
PATH_PACKAGES=0
EXECUTABLE_MISMATCHES=0

# Arrays
WRAPPER_PACKAGE_NAMES=()
PATH_PACKAGE_PATHS=()
CORRUPTED_PACKAGE_NAMES=()
MISMATCH_PACKAGE_NAMES=()

# Clear the log file at start
echo "PORTX Package Import - $(date)" > "$PORTX_LOG_FILE"
debug_log "Starting package import scan..."

printf "Importing portx packages\n" >&2

# Cleanup at beginning - remove old cache and wrappers
rm -f "$HOME/.portx_cache"

# Only remove .cmd wrapper files, preserve all other executables
# Safe deletion: only remove PORTX-tagged wrappers
for file in "$WRAPPERS_DIR"/*; do
    if [[ -f "$file" ]] && head -n 3 "$file" 2>/dev/null | grep -q "PORTX-WRAPPER"; then
        rm -f "$file"
    fi
done
mkdir -p "$WRAPPERS_DIR"

# Removed should_skip_wrapper_test - no longer needed

# Method: Test wrapper functionality to determine if standalone
test_wrapper_works() {
    local cmd_name="$1"
    
    debug_log "      Testing wrapper for: $cmd_name"
    
    # Check if wrapper exists and is executable
    local wrapper_sh="$WRAPPERS_DIR/$cmd_name"
    if [[ ! -f "$wrapper_sh" ]]; then
        debug_log "      Wrapper file does not exist: $wrapper_sh"
        return 1
    fi
    
    if [[ ! -x "$wrapper_sh" ]]; then
        debug_log "      Wrapper file is not executable: $wrapper_sh"
        return 1
    fi
    
    # Test basic wrapper execution using full path
    debug_log "      Testing basic wrapper execution"
    local basic_test_output
    basic_test_output=$(timeout 3 "$wrapper_sh" 2>&1 || true)
    local basic_exit_code=$?
    debug_log "      Basic execution exit code: $basic_exit_code"
    if [[ -n "$basic_test_output" ]]; then
        debug_log "      Basic output: $(echo "$basic_test_output" | head -1)"
    fi
    
    # Check if timeout command exists
    if ! command -v timeout >/dev/null 2>&1; then
        debug_log "      timeout command not available, using direct test"
        # Test without timeout - comprehensive flags for CLI and GUI tools
        for flag in "--help" "--version" "-h" "-v" "/?" "-?" "help" "version" "--usage" "/help" "/version"; do
            debug_log "      Testing flag: $flag"
            if "$wrapper_sh" "$flag" >/dev/null 2>&1; then
                debug_log "      Wrapper test SUCCESS with flag: $flag"
                return 0
            else
                debug_log "      Flag $flag failed"
            fi
        done
    else
        debug_log "      Using timeout for wrapper tests"
        # Test with timeout using wrapper full path - comprehensive flags for CLI and GUI tools
        for flag in "--help" "--version" "-h" "-v" "/?" "-?" "help" "version" "--usage" "/help" "/version"; do
            debug_log "      Testing flag with timeout: $flag"
            local error_output
            error_output=$(timeout 3 "$wrapper_sh" "$flag" 2>&1 >/dev/null)
            local exit_code=$?
            if [[ $exit_code -eq 0 ]]; then
                debug_log "      Wrapper test SUCCESS with flag: $flag"
                return 0
            else
                debug_log "      Timeout flag $flag failed (exit: $exit_code)"
            fi
        done
    fi
    
    debug_log "      Wrapper test FAILED for all flags"
    return 1
}

# Method: Get all executables in package directory
# Method: Get executables from package.json (preferred) with defaultArgs
get_executables_from_json() {
    local pkg_dir="$1"
    local json_file="$pkg_dir/package.json"
    
    if [[ -f "$json_file" ]]; then
        # Extract executables with defaultArgs: "executable.exe|defaultArgs"
        "$GIT_BASH_ROOT/home/portx/packages/jq/jq.exe" -r '.tools[]? | select(.executable) | "\(.executable)|\(.defaultArgs // "")"' "$json_file" 2>/dev/null
    fi
}

# Method: Get executables by scanning directory (for validation)
get_scanned_executables() {
    local pkg_dir="$1"
    find "$pkg_dir" -maxdepth 1 -name "*.exe" -exec basename {} \; 2>/dev/null | sort
}

# Method: Parse package JSON for declared tools
parse_package_manual() {
    local pkg_dir="$1"
    local json_file="$pkg_dir/package.json"

    if [[ ! -f "$json_file" ]]; then
        echo ""
        return
    fi

    # Extract executables from JSON tools array
    jq.cmd -r '.tools[]?.executable // empty' "$json_file" 2>/dev/null | sort -u
}

# Method: Validate package integrity
validate_package() {
    local pkg_dir="$1"
    local pkg_name="$2"
    local json_file="$pkg_dir/package.json"
    local validation_status="VALID"
    local validation_issues=()

    # Silent analysis

    # Check 1: Package JSON exists
    if [[ ! -f "$json_file" ]]; then
        validation_issues+=("No package.json found")
        validation_status="CORRUPTED"
    fi

    # Check 2: Executables exist
    local discovered_exes
    discovered_exes=$(get_scanned_executables "$pkg_dir")
    if [[ -z "$discovered_exes" ]]; then
        validation_issues+=("No executables found")
        validation_status="CORRUPTED"
    fi

    # Check 3: Compare discovered vs declared executables
    if [[ -f "$json_file" ]] && [[ -n "$discovered_exes" ]]; then
        local declared_exes
        declared_exes=$(parse_package_manual "$pkg_dir")

        if [[ -n "$declared_exes" ]]; then
            local discovered_sorted
            local declared_sorted
            discovered_sorted=$(echo "$discovered_exes" | xargs -n1 basename | sort)
            declared_sorted=$(echo "$declared_exes" | sort)

            if [[ "$discovered_sorted" != "$declared_sorted" ]]; then
                validation_issues+=("Executable mismatch between discovery and manual")
                EXECUTABLE_MISMATCHES=$((EXECUTABLE_MISMATCHES + 1))
                MISMATCH_PACKAGE_NAMES+=("$pkg_name")
            fi
        fi
    fi

    # Silent validation results
    if [[ "$validation_status" == "VALID" ]]; then
        VALID_PACKAGES=$((VALID_PACKAGES + 1))
        return 0
    else
        CORRUPTED_PACKAGES=$((CORRUPTED_PACKAGES + 1))
        CORRUPTED_PACKAGE_NAMES+=("$pkg_name")
        return 1
    fi
}


# Method: Check if command conflicts with existing binaries
has_command_conflict() {
    local cmd_name="$1"
    
    # Check if command exists in system PATH (Git Bash bin/)
    if command -v "$cmd_name" >/dev/null 2>&1; then
        return 0  # Conflict found
    fi
    
    # bin-ext check removed - no longer used
    
    return 1  # No conflict
}

# Method: Create and test wrapper scripts - delete if they don't work
create_and_test_wrappers() {
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
            executables=$(echo "$scanned_exes" | sed 's/$/|/')
            debug_log "    Found $(echo "$scanned_exes" | wc -l) executables by scanning"
        else
            debug_log "    No executables found by scanning, skipping package"
            return 1
        fi
    fi
    local successful_wrappers=0
    local failed_wrappers=0

    debug_log "    Found executables in $pkg_name: $(echo "$executables" | wc -l) files"
    if [[ -z "$executables" ]]; then
        debug_log "    No executables found in package"
        return 1
    fi

    # Create and test wrappers - parse executable|defaultArgs format
    while IFS='|' read -r exe_name default_args; do
        if [[ -n "$exe_name" ]]; then
            local cmd_name="${exe_name%.*}"
            local exe_file="$pkg_dir/$exe_name"
            
            # Clean up empty default_args
            [[ -z "$default_args" ]] && default_args=""
            
            debug_log "      Processing executable: $exe_name -> $cmd_name (args: '$default_args')"
            
            # Skip conflict check - create wrappers regardless of existing commands
            
            local wrapper_cmd="$WRAPPERS_DIR/$cmd_name.cmd"
            local wrapper_sh="$WRAPPERS_DIR/$cmd_name"

            # Create .cmd wrapper for Windows with defaultArgs  
            if [[ -n "$default_args" && "$default_args" != "" ]]; then
                printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s with defaultArgs\n"C:\\App\\Git\\home\\portx\\packages\\%s\\%s" %s %%*\n' "$pkg_name" "$pkg_name" "$exe_name" "$default_args" >"$wrapper_cmd"
            else
                printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s\n"C:\\App\\Git\\home\\portx\\packages\\%s\\%s" %%*\n' "$pkg_name" "$pkg_name" "$exe_name" >"$wrapper_cmd"
            fi

            # Create shell wrapper for Git Bash with defaultArgs
            local posix_exe_path="$GIT_BASH_ROOT/home/portx/packages/$pkg_name/$exe_name"
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
            
            debug_log "      Created wrapper content:"
            debug_log "      Target exe: $exe_file"
            debug_log "      Wrapper path: $wrapper_sh"
            if [[ -f "$exe_file" ]]; then
                debug_log "      Target exe EXISTS"
            else
                debug_log "      Target exe NOT FOUND: $exe_file"
            fi

            # Test if wrapper actually works
            if test_wrapper_works "$cmd_name"; then
                successful_wrappers=$((successful_wrappers + 2))
            else
                # Wrapper failed - delete it
                rm -f "$wrapper_cmd" "$wrapper_sh" 2>/dev/null
                failed_wrappers=$((failed_wrappers + 1))
            fi
        fi
    done <<<"$executables"
    
    # Return 0 if any wrappers succeeded, 1 if all failed
    [[ $successful_wrappers -gt 0 ]]
}

# Method: Add package to PATH configuration
add_to_path() {
    local pkg_path="$1"
    local pkg_name="$2"

    PATH_PACKAGE_PATHS+=("$pkg_path")
    return 0
}

# Main processing loop - silent output to console
for pkg_path in "$PACKAGES_DIR"/*; do
    if [[ -d "$pkg_path" ]]; then
        pkg_name="$(basename "$pkg_path")"
        TOTAL_PACKAGES=$((TOTAL_PACKAGES + 1))
        debug_log "Processing package: $pkg_name"

        if validate_package "$pkg_path" "$pkg_name"; then
            # Try to create and test wrappers first
            if create_and_test_wrappers "$pkg_path" "$pkg_name"; then
                debug_log "Created working wrappers for $pkg_name"
                WRAPPER_PACKAGES=$((WRAPPER_PACKAGES + 1))
                WRAPPER_PACKAGE_NAMES+=("$pkg_name")
            else
                debug_log "Wrappers failed, adding $pkg_name to PATH"
                add_to_path "$pkg_path" "$pkg_name"
                PATH_PACKAGES=$((PATH_PACKAGES + 1))
            fi
        else
            debug_log "VALIDATION FAILED: Package $pkg_name failed validation, skipping"
        fi
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
path_config="$WRAPPERS_DIR"

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
    echo "#   Git Bash Core: $(find "$GIT_BASH_ROOT/mingw64/bin" -name "*.exe" 2>/dev/null | wc -l) executables"
    echo "#   PORTX Bin: $(find "$WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l) wrappers"
    echo "#   PORTX Packages: $TOTAL_PACKAGES directories, $TOTAL_EXECUTABLES executables"
    echo "#   Total: $(($(find "$GIT_BASH_ROOT/mingw64/bin" -name "*.exe" 2>/dev/null | wc -l) + $(find "$WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l) + TOTAL_EXECUTABLES)) tools"
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
    echo "# Build PORTX PATH"
    echo "COMPLETE_PATH=\"\""
    echo "COMPLETE_PATH=\"$WRAPPERS_DIR\""
    
    # Add package directories with executable counts
    for pkg_path in "${PATH_PACKAGE_PATHS[@]}"; do
        pkg_name="$(basename "$pkg_path")"
        exe_count=$(find "$pkg_path" -maxdepth 1 -name "*.exe" 2>/dev/null | wc -l)
        echo "COMPLETE_PATH=\"\$COMPLETE_PATH:$pkg_path\"  # $exe_count executables"
    done
    
    echo "# PORTX packages added: $PATH_PACKAGES directories"
    echo ""
    echo "# Export PORTX PATH (preserve original Windows PATH)"
    echo "export PATH=\"\$COMPLETE_PATH:\$PATH\""
    echo ""
    echo "# PORTX PATH statistics"
    
    MINGW_COUNT=$(find "$GIT_BASH_ROOT/mingw64/bin" -name "*.exe" 2>/dev/null | wc -l)
    BIN_COUNT=$(find "$WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l)
    TOTAL_COUNT=$((MINGW_COUNT + BIN_COUNT + TOTAL_EXECUTABLES))
    TOTAL_DIRS=$((PATH_PACKAGES + 1))
    
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
    echo "export PORTX_MINGW_DIRS=1"
    echo "export PORTX_MINGW_EXECUTABLES=$MINGW_COUNT"
    echo "export PORTX_BIN_DIRS=1" 
    echo "export PORTX_BIN_EXECUTABLES=$BIN_COUNT"
    echo "export PORTX_PKG_DIRS=$TOTAL_PACKAGES"
    echo "export PORTX_PKG_EXECUTABLES=$TOTAL_EXECUTABLES"
    echo "export PORTX_TOTAL_EXECUTABLES=$TOTAL_COUNT"
    echo "export PORTX_TOTAL_DIRS=$TOTAL_DIRS"
    echo "export PORTX_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
    
    # Legacy compatibility (will be removed after testing)
    echo "export MINGW_COUNT=$MINGW_COUNT"
    echo "export BIN_COUNT=$BIN_COUNT"
    echo "export PACKAGES_EXE_COUNT=$TOTAL_EXECUTABLES"
    echo "export PACKAGES_COUNT=$TOTAL_PACKAGES"
    echo "export TOTAL_EXE_COUNT=$TOTAL_COUNT"
    echo "export TOTAL_PATH_DIRS=$TOTAL_DIRS"
    echo "export PATH_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
    echo ""
} >"$PORTX_PATH_FILE"

# Validation: Compare package.json vs scanned executables (log only)
debug_log ""
debug_log "=== VALIDATION REPORT ==="
for pkg_path in "$PACKAGES_DIR"/*; do
    if [[ -d "$pkg_path" ]]; then
        pkg_name="$(basename "$pkg_path")"
        
        # Get executables from both sources
        json_executables=$(get_executables_from_json "$pkg_path" | cut -d'|' -f1 | sort)
        scanned_executables=$(get_scanned_executables "$pkg_path")
        
        if [[ -n "$json_executables" ]]; then
            # Check for malformed package.json entries
            malformed_count=$("$GIT_BASH_ROOT/home/portx/packages/jq/jq.exe" -r '.tools[]? | select(.description == "TODO: Add description" or (.description | test("TODO|todo|FIXME|fixme"))) | .executable' "$pkg_path/package.json" 2>/dev/null | wc -l)
            if [[ "$malformed_count" -gt 0 ]]; then
                debug_log "MALFORMED: $pkg_name has $malformed_count tools with TODO/incomplete descriptions"
            fi
            
            # Compare lists
            json_only=$(comm -23 <(echo "$json_executables") <(echo "$scanned_executables") 2>/dev/null)
            scanned_only=$(comm -13 <(echo "$json_executables") <(echo "$scanned_executables") 2>/dev/null)
            
            if [[ -n "$json_only" || -n "$scanned_only" ]]; then
                debug_log "MISMATCH in $pkg_name:"
                if [[ -n "$json_only" ]]; then
                    debug_log "  In package.json but not found: $json_only"
                fi
                if [[ -n "$scanned_only" ]]; then
                    debug_log "  Found on disk but not in package.json: $scanned_only"
                fi
            else
                debug_log "OK: $pkg_name ($(echo "$json_executables" | wc -l) executables match)"
            fi
        else
            if [[ -n "$scanned_executables" ]]; then
                debug_log "MISSING package.json: $pkg_name has $(echo "$scanned_executables" | wc -l) executables"
            fi
        fi
    fi
done
debug_log "=== END VALIDATION REPORT ==="

printf "Discovered %d packages, %d executables, %d paths, %d refs\n" \
    "$TOTAL_PACKAGES" "$TOTAL_EXECUTABLES" "$PATH_PACKAGES" "$WRAPPER_PACKAGES" >&2
