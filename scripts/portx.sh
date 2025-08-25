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

# Logging functions using printf
log() { printf "%s%s%s\n" "$(color_primary)" "$1" "$(color_reset)"; }
error() { printf "%s%s%s\n" "$(color_error)" "$1" "$(color_reset)" >&2; }
success() { printf "%s%s%s\n" "$(color_success)" "$1" "$(color_reset)"; }
warning() { printf "%s%s%s\n" "$(color_warning)" "$1" "$(color_reset)"; }

# Configuration
PACKAGES_DIR="$GIT_BASH_ROOT/home/portx/packages"
SH_WRAPPERS_DIR="$GIT_BASH_ROOT/bin"
CMD_WRAPPERS_DIR="$GIT_BASH_ROOT/cmd"
PORTX_PATH_CACHE="$HOME/.portx_path_cache"
PORTX_PACKAGES_CACHE="$HOME/.portx_packages_cache"
PORTX_TOOLS_CACHE="$HOME/.portx_tools_cache"
PORTX_IMPORT_LOG_FILE="$HOME/portx-packages-import.log"
PORTX_VERIFY_LOG_FILE="$HOME/portx-packages-verify.log"

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
CORRUPTED_PACKAGES=0
WRAPPER_PACKAGES=0
PATH_PACKAGES=0
EXECUTABLE_MISMATCHES=0

# Arrays
WRAPPER_PACKAGE_NAMES=()
PATH_PACKAGE_PATHS=()
CORRUPTED_PACKAGE_NAMES=()
MISMATCH_PACKAGE_NAMES=()

# Method: Test wrapper functionality to determine if standalone (for verify command)
test_wrapper_works() {
    local cmd_name="$1"

    debug_log "$PORTX_VERIFY_LOG_FILE" "      Testing wrapper for: $cmd_name"

    # Check if wrapper exists and is executable
    local wrapper_sh="$SH_WRAPPERS_DIR/$cmd_name"
    if [[ ! -f "$wrapper_sh" ]]; then
        debug_log "$PORTX_VERIFY_LOG_FILE" "      Wrapper file does not exist: $wrapper_sh"
        return 1
    fi

    if [[ ! -x "$wrapper_sh" ]]; then
        debug_log "$PORTX_VERIFY_LOG_FILE" "      Wrapper file is not executable: $wrapper_sh"
        return 1
    fi

    # Test basic wrapper execution using full path
    debug_log "$PORTX_VERIFY_LOG_FILE" "      Testing basic wrapper execution"
    local basic_test_output
    basic_test_output=$(timeout 3 "$wrapper_sh" 2>&1 || true)
    local basic_exit_code=$?
    debug_log "$PORTX_VERIFY_LOG_FILE" "      Basic execution exit code: $basic_exit_code"
    if [[ -n "$basic_test_output" ]]; then
        debug_log "$PORTX_VERIFY_LOG_FILE" "      Basic output: $(echo "$basic_test_output" | head -1)"
    fi

    # Check if timeout command exists
    if ! command -v timeout >/dev/null 2>&1; then
        debug_log "$PORTX_VERIFY_LOG_FILE" "      timeout command not available, using direct test"
        # Test without timeout - comprehensive flags for CLI and GUI tools
        for flag in "--help" "--version" "-h" "-v" "/?" "-?" "help" "version" "--usage" "/help" "/version"; do
            debug_log "$PORTX_VERIFY_LOG_FILE" "      Testing flag: $flag"
            if "$wrapper_sh" "$flag" >/dev/null 2>&1; then
                debug_log "$PORTX_VERIFY_LOG_FILE" "      Wrapper test SUCCESS with flag: $flag"
                return 0
            else
                debug_log "$PORTX_VERIFY_LOG_FILE" "      Flag $flag failed"
            fi
        done
    else
        debug_log "$PORTX_VERIFY_LOG_FILE" "      Using timeout for wrapper tests"
        # Test with timeout using wrapper full path - comprehensive flags for CLI and GUI tools
        for flag in "--help" "--version" "-h" "-v" "/?" "-?" "help" "version" "--usage" "/help" "/version"; do
            debug_log "$PORTX_VERIFY_LOG_FILE" "      Testing flag with timeout: $flag"
            if timeout 3 "$wrapper_sh" "$flag" >/dev/null 2>&1; then
                debug_log "$PORTX_VERIFY_LOG_FILE" "      Wrapper test SUCCESS with flag: $flag"
                return 0
            else
                debug_log "$PORTX_VERIFY_LOG_FILE" "      Timeout flag $flag failed (exit: $?)"
            fi
        done
    fi

    debug_log "$PORTX_VERIFY_LOG_FILE" "      Wrapper test FAILED for all flags"
    return 1
}

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

# Method: Get package import type (path, wrap, or auto/default)
get_import_type() {
    local pkg_dir="$1"
    local json_file="$pkg_dir/package.json"

    if [[ ! -f "$json_file" ]]; then
        echo "auto" # No package.json, use default behavior
        return
    fi

    # Check importType field
    local import_type
    import_type=$("$GIT_BASH_ROOT/home/portx/packages/jq/jq.exe" -r '.importType // empty' "$json_file" 2>/dev/null)

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
        return 0 # Conflict found
    fi

    return 1 # No conflict
}

# Method: Create wrapper scripts (import only - no testing)
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
            local cmd_name="${exe_name%.*}"
            local exe_file="$pkg_dir/$exe_name"

            # Clean up empty default_args
            [[ -z "$default_args" ]] && default_args=""

            debug_log "      Processing executable: $exe_name -> $cmd_name (args: '$default_args')"

            # Check for command conflicts before creating wrappers
            if has_command_conflict "$cmd_name"; then
                debug_log "      SKIPPED: $cmd_name conflicts with existing command"
                continue
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

    # Write only the path to the file, one per line
    echo "$pkg_path" >> "$PORTX_PATH_CACHE"
    return 0
}

# Import packages function (main package processing logic - no verification)
import_packages() {
    # Clear the log file at start
    echo "PORTX Package Import - $(date)" >"$PORTX_IMPORT_LOG_FILE"
    debug_log "Starting package import scan..."

    printf "Importing portx packages\n" >&2

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

    # Main processing loop - simple import without validation
    for pkg_path in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_path" ]]; then
            pkg_name="$(basename "$pkg_path")"
            TOTAL_PACKAGES=$((TOTAL_PACKAGES + 1))
            debug_log "Processing package: $pkg_name"

            # Simple validation: package.json exists and has executables
            local json_file="$pkg_path/package.json"
            if [[ ! -f "$json_file" ]]; then
                debug_log "SKIPPED: No package.json for $pkg_name"
                continue
            fi

            local discovered_exes
            discovered_exes=$(get_scanned_executables "$pkg_path")
            if [[ -z "$discovered_exes" ]]; then
                debug_log "SKIPPED: No executables found for $pkg_name"
                continue
            fi

            VALID_PACKAGES=$((VALID_PACKAGES + 1))
            import_type=$(get_import_type "$pkg_path")
            debug_log "Package $pkg_name has importType: $import_type"

            case "$import_type" in
                "path")
                    # Force PATH mode - skip wrapper creation entirely
                    debug_log "Forcing PATH mode for $pkg_name"
                    add_to_path "$pkg_path" "$pkg_name"
                    PATH_PACKAGES=$((PATH_PACKAGES + 1))
                    ;;
                "wrap")
                    # Force wrapper mode - create wrappers
                    debug_log "Forcing wrapper mode for $pkg_name"
                    if create_wrappers "$pkg_path" "$pkg_name"; then
                        debug_log "Created wrappers for $pkg_name"
                        WRAPPER_PACKAGES=$((WRAPPER_PACKAGES + 1))
                        WRAPPER_PACKAGE_NAMES+=("$pkg_name")
                    else
                        debug_log "WRAPPER CREATION FAILED for $pkg_name (forced wrap mode)"
                    fi
                    ;;
                "auto" | *)
                    # Default behavior: try wrappers, fallback to PATH
                    debug_log "Using auto mode for $pkg_name"
                    if create_wrappers "$pkg_path" "$pkg_name"; then
                        debug_log "Created wrappers for $pkg_name"
                        WRAPPER_PACKAGES=$((WRAPPER_PACKAGES + 1))
                        WRAPPER_PACKAGE_NAMES+=("$pkg_name")
                    else
                        debug_log "No wrappers created, adding $pkg_name to PATH"
                        add_to_path "$pkg_path" "$pkg_name"
                        PATH_PACKAGES=$((PATH_PACKAGES + 1))
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
        echo "#   Git Bash Core: $(find "$GIT_BASH_ROOT/mingw64/bin" -name "*.exe" 2>/dev/null | wc -l) executables"
        echo "#   PORTX Bin: $(find "$CMD_WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l) wrappers"
        echo "#   PORTX Packages: $TOTAL_PACKAGES directories, $TOTAL_EXECUTABLES executables"
        echo "#   Total: $(($(find "$GIT_BASH_ROOT/mingw64/bin" -name "*.exe" 2>/dev/null | wc -l) + $(find "$CMD_WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l) + TOTAL_EXECUTABLES)) tools"
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

        MINGW_COUNT=$(find "$GIT_BASH_ROOT/mingw64/bin" -name "*.exe" 2>/dev/null | wc -l)
        BIN_COUNT=$(find "$CMD_WRAPPERS_DIR" -name "*.cmd" 2>/dev/null | wc -l)
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
    } >"$PORTX_PATH_CACHE"

    printf "Imported %d packages, %d executables, %d paths, %d wrappers\n" \
        "$TOTAL_PACKAGES" "$TOTAL_EXECUTABLES" "$PATH_PACKAGES" "$WRAPPER_PACKAGES" >&2
}

# Verify packages function (validation and wrapper testing)
verify_packages() {
    # Clear the verify log file at start
    echo "PORTX Package Verification - $(date)" >"$PORTX_VERIFY_LOG_FILE"
    debug_log "$PORTX_VERIFY_LOG_FILE" "Starting package verification..."

    printf "Verifying portx packages\n" >&2

    local verified_packages=0
    local failed_packages=0
    local wrapper_tests_passed=0
    local wrapper_tests_failed=0

    # Validation: Compare package.json vs scanned executables and test wrappers
    debug_log "$PORTX_VERIFY_LOG_FILE" ""
    debug_log "$PORTX_VERIFY_LOG_FILE" "=== VALIDATION REPORT ==="

    for pkg_path in "$PACKAGES_DIR"/*; do
        if [[ -d "$pkg_path" ]]; then
            pkg_name="$(basename "$pkg_path")"
            debug_log "$PORTX_VERIFY_LOG_FILE" "Verifying package: $pkg_name"

            # Validate package integrity
            if validate_package "$pkg_path" "$pkg_name"; then
                ((verified_packages++))

                # Get executables from both sources
                json_executables=$(get_executables_from_json "$pkg_path" | cut -d'|' -f1 | sort)
                scanned_executables=$(get_scanned_executables "$pkg_path")

                if [[ -n "$json_executables" ]]; then
                    # Check for malformed package.json entries
                    malformed_count=$("$GIT_BASH_ROOT/home/portx/packages/jq/jq.exe" -r '.tools[]? | select(.description == "TODO: Add description" or (.description | test("TODO|todo|FIXME|fixme"))) | .executable' "$pkg_path/package.json" 2>/dev/null | wc -l)
                    if [[ "$malformed_count" -gt 0 ]]; then
                        debug_log "$PORTX_VERIFY_LOG_FILE" "MALFORMED: $pkg_name has $malformed_count tools with TODO/incomplete descriptions"
                    fi

                    # Compare lists
                    json_only=$(comm -23 <(echo "$json_executables") <(echo "$scanned_executables") 2>/dev/null)
                    scanned_only=$(comm -13 <(echo "$json_executables") <(echo "$scanned_executables") 2>/dev/null)

                    if [[ -n "$json_only" || -n "$scanned_only" ]]; then
                        debug_log "$PORTX_VERIFY_LOG_FILE" "MISMATCH in $pkg_name:"
                        if [[ -n "$json_only" ]]; then
                            debug_log "$PORTX_VERIFY_LOG_FILE" "  In package.json but not found: $json_only"
                        fi
                        if [[ -n "$scanned_only" ]]; then
                            debug_log "$PORTX_VERIFY_LOG_FILE" "  Found on disk but not in package.json: $scanned_only"
                        fi
                    else
                        debug_log "$PORTX_VERIFY_LOG_FILE" "OK: $pkg_name ($(echo "$json_executables" | wc -l) executables match)"
                    fi

                    # Test wrappers if they exist
                    while IFS= read -r exe_name; do
                        if [[ -n "$exe_name" ]]; then
                            local cmd_name="${exe_name%.*}"
                            if [[ -f "$GIT_BASH_ROOT/bin/$cmd_name" ]]; then
                                if test_wrapper_works "$cmd_name"; then
                                    debug_log "$PORTX_VERIFY_LOG_FILE" "WRAPPER OK: $cmd_name"
                                    ((wrapper_tests_passed++))
                                else
                                    debug_log "$PORTX_VERIFY_LOG_FILE" "WRAPPER FAILED: $cmd_name"
                                    ((wrapper_tests_failed++))
                                fi
                            fi
                        fi
                    done <<<"$json_executables"
                else
                    if [[ -n "$scanned_executables" ]]; then
                        debug_log "$PORTX_VERIFY_LOG_FILE" "MISSING package.json: $pkg_name has $(echo "$scanned_executables" | wc -l) executables"
                    fi
                fi
            else
                ((failed_packages++))
                debug_log "$PORTX_VERIFY_LOG_FILE" "VALIDATION FAILED: $pkg_name"
            fi
        fi
    done

    debug_log "$PORTX_VERIFY_LOG_FILE" "=== END VALIDATION REPORT ==="

    printf "Verified %d packages (%d failed), wrapper tests: %d passed, %d failed\n" \
        "$verified_packages" "$failed_packages" "$wrapper_tests_passed" "$wrapper_tests_failed" >&2
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

# List all tools in flat format - one line separated by comma
list_tools_flat() {
    local filter_tag="$1"
    
    # Create cache key - sort tags alphabetically if multiple
    local cache_key
    if [[ -z "$filter_tag" ]]; then
        cache_key="no_filter"
    else
        # Sort multiple tags alphabetically and join with underscore
        cache_key=$(echo "$filter_tag" | tr ',' '\n' | sort | tr '\n' '_' | sed 's/_$//')
    fi
    
    # Check if cache exists and use it
    if [[ -f "$PORTX_TOOLS_CACHE" ]] && grep -q "^${cache_key}:" "$PORTX_TOOLS_CACHE"; then
        grep "^${cache_key}:" "$PORTX_TOOLS_CACHE" | cut -d':' -f2-
        return 0
    fi
    
    # Generate output directly without intermediate functions
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
            # If filter is provided, check if package has any of the tags
            if [[ -n "$filter_tag" ]]; then
                local has_tag=false
                # Split filter_tag by comma and check each tag
                IFS=',' read -ra tags <<< "$filter_tag"
                for tag in "${tags[@]}"; do
                    tag=$(echo "$tag" | xargs) # trim whitespace
                    # Check if this tag exists in the package tags array
                    if $JQ_CMD -e --arg tag "$tag" '.tags[]? | select(. == $tag)' "$pkg_dir/package.json" >/dev/null 2>&1; then
                        has_tag=true
                        break
                    fi
                done
                if [[ "$has_tag" != true ]]; then
                    continue
                fi
            fi
            
            # Extract executables from package.json
            while IFS= read -r exe; do
                if [[ -n "$exe" ]]; then
                    # Remove carriage returns
                    exe="${exe//$'\r'/}"
                    all_tools+=("$exe")
                fi
            done < <($JQ_CMD -r '.tools[]?.executable // empty' "$pkg_dir/package.json" 2>/dev/null)
        fi
    done
    
    # Sort and output tools with comma delimiter
    local temp_file=$(mktemp)
    printf '%s\n' "${all_tools[@]}" > "$temp_file"
    
    # Use dos2unix to clean line endings, then sort and deduplicate
    dos2unix "$temp_file" 2>/dev/null || true
    local result=$(sort -u "$temp_file" | tr '\n' ',' | sed 's/,$//')
    
    # Output result
    echo "$result"
    
    # Save to cache with key
    echo "${cache_key}:${result}" >> "$PORTX_TOOLS_CACHE"
    
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

# Internal function to generate the packages list
_generate_packages_list() {
    
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
            local pkg_name
            pkg_name=$(basename "$pkg_dir")

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
            # shellcheck disable=SC2016
            $JQ_CMD -r '(.tags // []) as $tags | .tools[]? | "  |- " + (.executable // "" | . + (25 - length) * " " | .[0:25]) + " " + (.description // "") + if ($tags | length > 0) then " [" + ($tags | join(", ")) + "]" else "" end' "$pkg_dir/package.json" 2>/dev/null
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
        verify)
            verify_packages
            ;;
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
            echo "  verify            Verify package integrity and test wrappers"
            echo "  list              List all available tools"
            echo "  search PATTERN    Search tools by name or description"
            echo "  count             Show tool count statistics"
            echo "  help              Show this help message"
            echo
            echo "Examples:"
            echo "  portx packages import"
            echo "  portx packages verify"
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
