#!/bin/bash
# PORTX Package Manager - Consolidated Script
# Imports packages into PORTX system: discover, validate, analyze dependencies, create wrappers, configure PATH
# Also provides tools aggregator functionality

# Enhanced error handling - temporarily disabled for debugging
# set -euo pipefail

# Universal logging system - ALWAYS logs everything
LOG_FILE="$GIT_BASH_ROOT/home/portx/portx-packages-import.log"

# Initialize log file - delete existing on script start
if [[ -f "$LOG_FILE" ]]; then
	rm -f "$LOG_FILE"
fi

# Debug logging - only to file
debug() {
	command printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

# Check if GIT_BASH_ROOT is set
if [[ -z "${GIT_BASH_ROOT:-}" ]]; then
	error "GIT_BASH_ROOT environment variable not set"
	info "This variable should be set by .bashrc"
	exit 1
fi

# Ensure GFW tools are in PATH
export PATH="/c/App/Git/bin:$PATH"

# Get script directory for theme loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load theme system for consistent colors and icons - let it crash if not found
# shellcheck source=/dev/null
source "$SCRIPT_DIR/theme.sh"

# Semantic logging functions - plain text to log file + colored console output
info() { command printf "%s\n" "$1" >> "$LOG_FILE"; command printf "%s%s%s\n" "$(color_primary)" "$1" "$(color_reset)"; }
error() { command printf "%s\n" "$1" >> "$LOG_FILE"; command printf "%s%s%s\n" "$(color_error)" "$1" "$(color_reset)" >&2; }
success() { command printf "%s\n" "$1" >> "$LOG_FILE"; command printf "%s%s%s\n" "$(color_pale_green)" "$1" "$(color_reset)"; }
warning() { command printf "%s\n" "$1" >> "$LOG_FILE"; command printf "%s%s%s\n" "$(color_warning)" "$1" "$(color_reset)"; }

# Configuration
# Wrapper creation control flags
CREATE_SHELL_WRAPPERS=true # Set to true to enable bash/shell wrapper creation
CREATE_CMD_WRAPPERS=true   # Set to true to enable CMD wrapper creation

# WSL Environment Detection
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
	IS_WSL=true
else
	IS_WSL=false
fi

# Convert Windows paths to appropriate format for bash commands
if [[ "$IS_WSL" == "true" ]]; then
	GIT_BASH_ROOT_POSIX="${GIT_BASH_ROOT//C:/\/mnt\/c}"
else
	GIT_BASH_ROOT_POSIX="${GIT_BASH_ROOT//C:/\/c}"
fi

# Windows paths for CMD wrappers (always use Windows format)
GIT_BASH_ROOT_WINDOWS="${GIT_BASH_ROOT//\//\\\\}"
PACKAGES_DIR="$GIT_BASH_ROOT_POSIX/home/portx/packages"
SH_WRAPPERS_DIR="$GIT_BASH_ROOT_POSIX/bin"
CMD_WRAPPERS_DIR="$GIT_BASH_ROOT_POSIX/cmd"
PORTX_PATH_CACHE="$HOME/.portx_path_cache"
PORTX_PACKAGES_CACHE="$HOME/.portx_packages_cache"
PORTX_TOOLS_CACHE="$HOME/.portx_tools_cache"

# Tool path variables - point to real package locations
ES_EXE="$PACKAGES_DIR/everything/es.exe"
FD_EXE="$PACKAGES_DIR/fd/fd.exe"
JQ_EXE="$PACKAGES_DIR/jq/jq.exe"


# Counters
TOTAL_PACKAGES=0
TOTAL_EXECUTABLES=0
VALID_PACKAGES=0
WRAPPER_PACKAGES=0
PATH_PACKAGES=0

# Arrays
WRAPPER_PACKAGE_NAMES=()
PATH_PACKAGE_PATHS=()


# Schema validation error codes
declare -g SCHEMA_VALID=0
declare -g SCHEMA_INVALID=20
declare -g SCHEMA_FILE_MISSING=21
declare -g JSON_SYNTAX_ERROR=22

# Method: Validate portx.json against portx schema
validate_portx_json() {
	local portx_json_path="$1"

	debug "Validating: $portx_json_path"

	# Check if portx.json exists
	if [[ ! -f "$portx_json_path" ]]; then
		debug "ERROR: portx.json not found: $portx_json_path"
		return $SCHEMA_FILE_MISSING
	fi

	# Use native portx validator (no external dependencies)
	local validator_script="$GIT_BASH_ROOT_POSIX/home/portx/scripts/validate-json.sh"
	if [[ -f "$validator_script" ]]; then
		if "$validator_script" "$portx_json_path" >/dev/null 2>&1; then
			debug "SUCCESS: Schema validation passed: $portx_json_path"
			return $SCHEMA_VALID
		else
			debug "ERROR: Schema validation failed: $portx_json_path"
			# Show detailed validation errors
			"$validator_script" "$portx_json_path" 2>&1 | while read -r line; do
				debug "  $line"
			done
			return $SCHEMA_INVALID
		fi
	else
		debug "WARNING: Native validator not found, using basic JSON syntax check"
		# Fallback to basic JSON syntax validation
		if ! cat "$portx_json_path" | jq empty >/dev/null 2>&1; then
			debug "ERROR: Invalid JSON syntax in: $portx_json_path"
			return $JSON_SYNTAX_ERROR
		fi
		return $SCHEMA_VALID
	fi
}

# Method: Get executables from portx.json (preferred) with defaultArgs
get_executables_from_json() {
	local pkg_dir="$1"
	local json_file="$pkg_dir/portx.json"

	debug "=== GET_EXECUTABLES_FROM_JSON START ==="
	debug "Package dir: $pkg_dir"
	debug "JSON file: $json_file"

	if [[ -f "$json_file" ]]; then
		debug "JSON file exists, parsing"
		# NEW SCHEMA: Extract executables from bin object: "path|defaultArgs"
		# First try new schema (bin object)
		local bin_executables
		bin_executables=$(parse_json_with_comments "$json_file" '.bin // {} | to_entries[]? | "\(.value.path)|\(.value.defaultArgs // "")"')
		debug "New schema result: '$bin_executables'"

		if [[ -n "$bin_executables" ]]; then
			debug "Using new schema result"
			command echo "$bin_executables"
			debug "=== GET_EXECUTABLES_FROM_JSON END ==="
			return
		fi

		debug "New schema empty, trying legacy fallback"
		# LEGACY FALLBACK: Extract from old tools array for backward compatibility
		local legacy_result
		legacy_result=$(parse_json_with_comments "$json_file" '.tools[]? | select(.executable) | "\(.executable)|\(.defaultArgs // "")"')
		debug "Legacy schema result: '$legacy_result'"
		command echo "$legacy_result"
		debug "=== GET_EXECUTABLES_FROM_JSON END ==="
	else
		debug "JSON file does not exist"
		debug "=== GET_EXECUTABLES_FROM_JSON END ==="
	fi
}

# Method: Parse package JSON for declared tools
parse_package_manual() {
	local pkg_dir="$1"
	local json_file="$pkg_dir/portx.json"

	if [[ ! -f "$json_file" ]]; then
		command echo ""
		return
	fi

	# NEW SCHEMA: Extract executables from bin object
	local bin_executables
	bin_executables=$(parse_json_with_comments "$json_file" '.bin // {} | to_entries[]? | .value.path' | sort -u)

	if [[ -n "$bin_executables" ]]; then
		command echo "$bin_executables"
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
	# FIXED: Only remove lines that start with comment markers, not inline comments
	# This preserves URLs like s3://bucket and # characters in strings
	sed -e '/^[[:blank:]]*#/d' -e '/^[[:blank:]]*\/\//d' "$json_file" |
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
		# FIXED: No longer mask jq errors - let them fail properly
		clean_json_for_jq "$json_file" | "$JQ_EXE" -r "$jq_filter" 2>/dev/null
	fi
}

get_import_type() {
	local pkg_dir="$1"
	local json_file="$pkg_dir/portx.json"

	if [[ ! -f "$json_file" ]]; then
		command echo "auto" # No portx.json, use default behavior
		return
	fi

	# Check importType field using comment-aware JSON parser
	local import_type
	import_type=$(parse_json_with_comments "$json_file" '.importType // empty')

	case "$import_type" in
	"path")
		command echo "path"
		;;
	"wrap")
		command echo "wrap"
		;;
	"none")
		command echo "none"
		;;
	"wrapAndPath")
		command echo "wrapAndPath"
		;;
	*)
		command echo "auto" # Default behavior: try wrappers, fallback to path
		;;
	esac
}

# Method: Comprehensive package validation with schema and executable verification
validate_package_comprehensive() {
	local pkg_dir="$1"
	local pkg_name="$2"
	local json_file="$pkg_dir/portx.json"

	info "    Validating: $pkg_name"
	debug "=== COMPREHENSIVE VALIDATION: $pkg_name ==="
	debug "Package directory: $pkg_dir"
	debug "JSON file: $json_file"

	# STEP 1: Check portx.json exists
	if [[ ! -f "$json_file" ]]; then
		debug "Validation error: Missing portx.json for package $pkg_name at $pkg_dir"
		error "Missing portx.json file"
		info "Package: $pkg_name"
		info "Expected file: $json_file"
		info "Error: portx.json configuration file not found"
		info "Cannot proceed - portx.json is required for all packages"
		debug "Validation failed: Missing portx.json for $pkg_name"
		return 1
	fi
	debug "portx.json exists"

	# STEP 2: Validate JSON schema with comprehensive validation
	info "      Verifying JSON schema"
	debug "Running comprehensive schema validation"
	if ! bash "$SCRIPT_DIR/validate-json.sh" "$json_file" >/dev/null 2>&1; then
		local validation_output
		validation_output=$(bash "$SCRIPT_DIR/validate-json.sh" "$json_file" 2>&1)

		debug "Validation error: Invalid portx.json schema for package $pkg_name at $json_file"
		debug "Schema validation errors: $validation_output"
		error "Invalid portx.json schema"
		info "Package: $pkg_name"
		info "Path: $json_file"
		info ""
		info "Schema validation failed - package MUST be 100%% compliant"
		printf "Validation errors:\n" >&2
		while IFS= read -r line; do
			info "  $line"
		done <<<"$validation_output"
		info ""
		info "Fix the schema issues and re-run import"
		debug "Validation failed: Schema validation failed for $pkg_name"
		debug "Validation output: $validation_output"
		return 1
	fi
	debug "JSON schema validation passed"
	success "      JSON schema validated successfully"

	# STEP 3: Check importType and skip executable validation for PATH/NONE packages
	local import_type
	import_type=$(get_import_type "$pkg_dir")
	debug "Package import type: '$import_type'"

	if [[ "$import_type" == "path" || "$import_type" == "none" ]]; then
		debug "Skipping executable validation for $import_type importType"
		info "      Skipping executable validation for $import_type importType"
		debug "COMPREHENSIVE VALIDATION PASSED: $pkg_name"
		return 0
	fi

	# wrapAndPath also needs executable validation
	if [[ "$import_type" == "wrapAndPath" ]]; then
		debug "wrapAndPath package requires executable validation"
	fi

	# STEP 4: Parse executables and verify each one exists (for wrap/auto packages only)
	info "      Verifying executable file paths"
	debug "Parsing executables from portx.json"

	local declared_executables
	declared_executables=$(parse_package_manual "$pkg_dir")

	if [[ -z "$declared_executables" ]]; then
		error "No executables declared for package $pkg_name"
		info "Error: portx.json contains no executable declarations"
		info "Expected: .bin object with executable definitions"
		info "Package cannot be imported without executable declarations"
		debug "Package validation failed: no executables found in portx.json"
		return 1
	fi

	# STEP 5: Verify each declared executable exists at specified path
	if [[ -n "$declared_executables" ]]; then
		local exe_count=0
		local exe_verified=0
		while IFS= read -r exe_path; do
			[[ -z "$exe_path" ]] && continue
			# Strip carriage returns from exe_path (Windows line ending issue)
			exe_path="${exe_path//$'\r'/}"
			exe_count=$((exe_count + 1))

			local full_exe_path="$pkg_dir/$exe_path"
			debug "Checking executable: $exe_path -> $full_exe_path"
			info "        Verifying: $exe_path"

			debug "Testing file existence: $full_exe_path"

			if [[ ! -f "$full_exe_path" ]]; then
				error "Missing executable file: $exe_path"
				info "Package: $pkg_name"
				info "Expected path: $full_exe_path"
				info "Error: File does not exist at declared location"
				info ""
				info "All declared executables MUST exist at their specified paths"
				info "Check portx.json paths and directory structure"
				debug "Validation failed: Missing executable $exe_path in package $pkg_name"
				debug "Expected at: $full_exe_path"
				return 1
			fi
			exe_verified=$((exe_verified + 1))
			debug "Verified executable: $exe_path"
		done <<<"$declared_executables"

		success "      All $exe_verified executables found at correct paths"
		debug "All $exe_verified/$exe_count executables verified successfully"
	fi

	debug "COMPREHENSIVE VALIDATION PASSED: $pkg_name"
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

	debug "=== CREATE_BASH_WRAPPERS START ==="
	debug "Package dir: $pkg_dir"
	debug "Package name: $pkg_name"

	# Use ONLY portx.json declared executables
	executables=$(get_executables_from_json "$pkg_dir")
	debug "Raw executables from JSON: '$executables'"

	if [[ -z "$executables" ]]; then
		debug "    No executables declared in portx.json, skipping package"
		return 1
	fi

	debug "    Found executables in $pkg_name: $(echo "$executables" | wc -l) files"
	if [[ -z "$executables" ]]; then
		debug "    No executables found in package"
		return 1
	fi

	local created_wrappers=0

	# Create bash wrappers - parse executable|defaultArgs format
	debug "Processing executables line by line"
	while IFS='|' read -r exe_name default_args; do
		# Sanitize default_args - remove any newlines or whitespace
		default_args=$(echo "$default_args" | tr -d '\n\r' | xargs)
		debug "--- Processing line: exe_name='$exe_name' default_args='$default_args' (sanitized) ---"
		if [[ -n "$exe_name" ]]; then
			local cmd_name
			cmd_name="$(basename "${exe_name%.*}")"
			debug "Command name: $cmd_name"
			local exe_file="$pkg_dir/$exe_name"
			debug "Executable file path: $exe_file"

			if [[ ! -f "$exe_file" ]]; then
				debug "      SKIPPED: Executable does not exist: $exe_file"
				continue
			fi

			if has_command_conflict "$cmd_name"; then
				debug "      WARNING: $cmd_name conflicts with existing command, but creating wrapper anyway"
			fi

			local wrapper_sh="$SH_WRAPPERS_DIR/$cmd_name"
			debug "Wrapper path: $wrapper_sh"

			# Create shell wrapper for Git Bash with defaultArgs
			mkdir -p "$SH_WRAPPERS_DIR"
			local posix_exe_path="$GIT_BASH_ROOT_POSIX/home/portx/packages/$pkg_name/$exe_name"

			# Create dynamic wrapper that detects environment at runtime
			debug "Creating wrapper template"
			debug "=== COMPREHENSIVE WRAPPER GENERATION LOG ==="
			debug "GIT_BASH_ROOT: '$GIT_BASH_ROOT'"
			debug "WSL_DETECTED: $([[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null && echo "YES" || echo "NO")"
			debug "PACKAGES_ROOT_PATH_WSL: '/mnt$GIT_BASH_ROOT/home/portx/packages'"
			debug "PACKAGES_ROOT_PATH_GITBASH: '$GIT_BASH_ROOT/home/portx/packages'"
			debug "PACKAGE_NAME: '$pkg_name'"
			debug "EXE_RELATIVE_PATH: '$exe_name'"
			debug "COMMAND_NAME: '$cmd_name'"
			debug "DEFAULT_ARGS_RAW: '$default_args'"
			debug "WRAPPER_OUTPUT_PATH: '$wrapper_sh'"
			debug "IS_SHELL_SCRIPT: $([[ "$exe_name" == *.sh ]] && echo "YES" || echo "NO")"
			debug "HAS_ARGUMENTS: $([[ -n "$default_args" && "$default_args" != "" ]] && echo "YES" || echo "NO")"
			debug "EXPECTED_EXECUTABLE_WSL: '/mnt$GIT_BASH_ROOT/home/portx/packages/$pkg_name/$exe_name'"
			debug "EXPECTED_EXECUTABLE_GITBASH: '$GIT_BASH_ROOT/home/portx/packages/$pkg_name/$exe_name'"
			debug "=== END COMPREHENSIVE LOG ==="

			if [[ "$exe_name" == *.sh ]]; then
				if [[ -n "$default_args" && "$default_args" != "" ]]; then
					debug "Using shell template WITH default args"
					cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name/$cmd_name
if [[ -n "\${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PACKAGES_ROOT_PATH="/mnt$GIT_BASH_ROOT/home/portx/packages"
else
    PACKAGES_ROOT_PATH="$GIT_BASH_ROOT/home/portx/packages"
fi
PACKAGE_NAME="$pkg_name"
EXE_RELATIVE_PATH="$exe_name"
ARGS="$default_args"
EXECUTABLE_PATH="\$PACKAGES_ROOT_PATH/\$PACKAGE_NAME/\$EXE_RELATIVE_PATH"
exec bash "\$EXECUTABLE_PATH" \${ARGS:+\$ARGS }"\$@"
WRAPPER_EOF
				else
					debug "Using shell template WITHOUT default args"
					cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name/$cmd_name
if [[ -n "\${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PACKAGES_ROOT_PATH="/mnt$GIT_BASH_ROOT/home/portx/packages"
else
    PACKAGES_ROOT_PATH="$GIT_BASH_ROOT/home/portx/packages"
fi
PACKAGE_NAME="$pkg_name"
EXE_RELATIVE_PATH="$exe_name"
EXECUTABLE_PATH="\$PACKAGES_ROOT_PATH/\$PACKAGE_NAME/\$EXE_RELATIVE_PATH"
exec bash "\$EXECUTABLE_PATH" "\$@"
WRAPPER_EOF
				fi
			else
				if [[ -n "$default_args" && "$default_args" != "" ]]; then
					debug "Using clean wrapper template WITH arguments"
					debug "=== CLEAN WRAPPER CONSTRUCTION ==="
					debug "PACKAGES_ROOT_PATH: /mnt$GIT_BASH_ROOT/home/portx/packages OR $GIT_BASH_ROOT/home/portx/packages"
					debug "PACKAGE_NAME: '$pkg_name'"
					debug "EXE_RELATIVE_PATH: '$exe_name'"
					debug "ARGS: '$default_args'"
					debug "=== WRITING CLEAN TEMPLATE ==="
					cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name/$cmd_name
if [[ -n "\${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PACKAGES_ROOT_PATH="/mnt$GIT_BASH_ROOT/home/portx/packages"
else
    PACKAGES_ROOT_PATH="$GIT_BASH_ROOT/home/portx/packages"
fi
PACKAGE_NAME="$pkg_name"
EXE_RELATIVE_PATH="$exe_name"
ARGS="$default_args"
EXECUTABLE_PATH="\$PACKAGES_ROOT_PATH/\$PACKAGE_NAME/\$EXE_RELATIVE_PATH"
exec "\$EXECUTABLE_PATH" \${ARGS:+\$ARGS }"\$@"
WRAPPER_EOF
					debug "=== TEMPLATE WRITTEN - CHECKING RESULT ==="
					debug "Actual exec line written: $(tail -1 "$wrapper_sh" | grep "exec")"
				else
					debug "Using clean wrapper template WITHOUT arguments"
					cat >"$wrapper_sh" <<WRAPPER_EOF
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for $pkg_name/$cmd_name
if [[ -n "\${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PACKAGES_ROOT_PATH="/mnt$GIT_BASH_ROOT/home/portx/packages"
else
    PACKAGES_ROOT_PATH="$GIT_BASH_ROOT/home/portx/packages"
fi
PACKAGE_NAME="$pkg_name"
EXE_RELATIVE_PATH="$exe_name"
EXECUTABLE_PATH="\$PACKAGES_ROOT_PATH/\$PACKAGE_NAME/\$EXE_RELATIVE_PATH"
exec "\$EXECUTABLE_PATH" "\$@"
WRAPPER_EOF
				fi
			fi
			debug "=== WRAPPER CREATION COMPLETED ==="
			debug "Final wrapper file: '$wrapper_sh'"
			debug "File size: $(wc -c < "$wrapper_sh") bytes"
			debug "File permissions: $(ls -l "$wrapper_sh" | cut -d' ' -f1)"
			debug "=== WRAPPER CONTENT VERIFICATION ==="
			debug "$(cat "$wrapper_sh" | sed 's/^/  /')"
			debug "=== WRAPPER EXEC LINE ANALYSIS ==="
			local exec_line=$(grep "exec" "$wrapper_sh")
			debug "Exec statement: '$exec_line'"
			debug "Contains EXECUTABLE_PATH: $(echo "$exec_line" | grep -q "EXECUTABLE_PATH" && echo "YES" || echo "NO")"
			# Check if wrapper has proper argument handling (either with ARGS expansion or direct "$@")
			local has_args_expansion=$(echo "$exec_line" | grep -q '\${ARGS:+' && echo "YES" || echo "NO")
			local has_direct_args=$(echo "$exec_line" | grep -q '"$@"' && echo "YES" || echo "NO")
			debug "Has ARGS expansion: $has_args_expansion"
			debug "Has direct \$@ handling: $has_direct_args"
			debug "Proper argument handling: $([[ "$has_args_expansion" == "YES" || "$has_direct_args" == "YES" ]] && echo "YES" || echo "NO")"
			debug "=== END WRAPPER VERIFICATION ==="
			chmod +x "$wrapper_sh"

			# Validate wrapper with shellcheck using full path
			debug "Validating wrapper with shellcheck"
			debug "=== VALIDATION TOOL PATH CONSTRUCTION ==="
			local validation_packages_root
			if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
				validation_packages_root="/mnt$GIT_BASH_ROOT/home/portx/packages"
			else
				validation_packages_root="$GIT_BASH_ROOT/home/portx/packages"
			fi
			local shellcheck_path="$validation_packages_root/shellcheck/shellcheck.exe"
			debug "VALIDATION_PACKAGES_ROOT: '$validation_packages_root'"
			debug "SHELLCHECK_PATH: '$shellcheck_path'"
			debug "SHELLCHECK_EXISTS: $([[ -f "$shellcheck_path" ]] && echo "YES" || echo "NO")"

			if [[ -f "$shellcheck_path" ]]; then
				local shellcheck_output
				debug "Running shellcheck validation: '$shellcheck_path' '$wrapper_sh'"
				if shellcheck_output=$("$shellcheck_path" "$wrapper_sh" 2>&1); then
					debug "Shellcheck PASSED for $cmd_name"
					success "      Wrapper validated successfully"
				else
					debug "Shellcheck FAILED for $cmd_name:"
					debug "$(color_error)$shellcheck_output$(color_reset)"
					error "      Wrapper validation failed - see debug log for details"
				fi
			else
				debug "Shellcheck not available at expected path, skipping validation"
				debug "Expected shellcheck path: '$shellcheck_path'"
				warning "      Wrapper validation skipped (shellcheck not available)"
			fi

			info "    BASH: $cmd_name -> $wrapper_sh"
			debug "      Created bash wrapper for: $cmd_name"
			debug "      Target exe: $exe_file"
			created_wrappers=$((created_wrappers + 1))
		fi
	done <<<"$executables"

	debug "=== CREATE_BASH_WRAPPERS END ==="

	# Return 0 if any wrappers created, 1 if none created
	[[ $created_wrappers -gt 0 ]]
}

# Method: Create cmd wrapper scripts only
create_cmd_wrappers() {
	local pkg_dir="$1"
	local pkg_name="$2"
	local executables

	# Use ONLY portx.json declared executables
	executables=$(get_executables_from_json "$pkg_dir")

	if [[ -z "$executables" ]]; then
		debug "    No executables declared in portx.json, skipping package"
		return 1
	fi

	debug "    Found executables in $pkg_name: $(echo "$executables" | wc -l) files"
	if [[ -z "$executables" ]]; then
		debug "    No executables found in package"
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
				debug "      SKIPPED: Executable does not exist: $exe_file"
				continue
			fi

			if has_command_conflict "$cmd_name"; then
				debug "      WARNING: $cmd_name conflicts with existing command, but creating wrapper anyway"
			fi

			local wrapper_cmd="$CMD_WRAPPERS_DIR/$cmd_name.cmd"

			# Create .cmd wrapper for Windows with defaultArgs
			mkdir -p "$CMD_WRAPPERS_DIR"

			# For .sh files, use Git Bash; for others, call directly
			if [[ "$exe_name" == *.sh ]]; then
				if [[ -n "$default_args" && "$default_args" != "" ]]; then
					command printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s with defaultArgs\n"%s\\bin\\bash.exe" "%s\\home\\portx\\packages\\%s\\%s" %s %%*\n' "$pkg_name" "$GIT_BASH_ROOT_WINDOWS" "$GIT_BASH_ROOT_WINDOWS" "$pkg_name" "$exe_name" "$default_args" >"$wrapper_cmd"
				else
					command printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s\n"%s\\bin\\bash.exe" "%s\\home\\portx\\packages\\%s\\%s" %%*\n' "$pkg_name" "$GIT_BASH_ROOT_WINDOWS" "$GIT_BASH_ROOT_WINDOWS" "$pkg_name" "$exe_name" >"$wrapper_cmd"
				fi
			else
				if [[ -n "$default_args" && "$default_args" != "" ]]; then
					command printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s with defaultArgs\n"%s\\home\\portx\\packages\\%s\\%s" %s %%*\n' "$pkg_name" "$GIT_BASH_ROOT_WINDOWS" "$pkg_name" "$exe_name" "$default_args" >"$wrapper_cmd"
				else
					command printf '@echo off\nrem PORTX-WRAPPER: Auto-generated wrapper for %s\n"%s\\home\\portx\\packages\\%s\\%s" %%*\n' "$pkg_name" "$GIT_BASH_ROOT_WINDOWS" "$pkg_name" "$exe_name" >"$wrapper_cmd"
				fi
			fi
			info "    CMD:  $cmd_name -> $wrapper_cmd"
			debug "      Created cmd wrapper for: $cmd_name"
			debug "      Target exe: $exe_file"
			created_wrappers=$((created_wrappers + 1))
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
	debug "Added $pkg_path to PATH_PACKAGE_PATHS array"
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
	expression=$(command echo "$expression" | sed 's/[[:space:]]*&[[:space:]]*/\&/g' | sed 's/[[:space:]]*|[[:space:]]*/|/g' | sed 's/[[:space:]]*![[:space:]]*/!/g')

	local i=0
	local token=""

	while [[ $i -lt ${#expression} ]]; do
		local char="${expression:$i:1}"

		case "$char" in
		'&' | '|' | '!' | '(' | ')')
			# End current token if exists
			if [[ -n "$token" ]]; then
				PARSER_TOKENS+=("$token")
				token=""
			fi
			# Add operator/bracket as token
			PARSER_TOKENS+=("$char")
			;;
		' ' | $'\t')
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
		command echo "${PARSER_TOKENS[$PARSER_POS]}"
	else
		command echo ""
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
			result=0 # OR: if any operand is true, result is true
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
			result=1 # AND: if any operand is false, result is false
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
			return 1 # NOT: invert result
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
		return 1 # Invalid token
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
			return 0 # Match found
		fi
	done
	return 1 # No match
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
			grep -v "^no_tags:" "$cache_file" >"$temp_file" 2>/dev/null || touch "$temp_file"
		else
			touch "$temp_file"
		fi
		# Add permanent no_tags entry
		command echo "no_tags:permanent:${result}" >>"$temp_file"
		mv "$temp_file" "$cache_file"
		return 0
	fi

	# Handle regular LRU entries
	local timestamp
	timestamp=$(date +%s)

	# Create temp file with existing entries except the one we're updating
	if [[ -f "$cache_file" ]]; then
		grep -v "^${query_key}:" "$cache_file" >"$temp_file" 2>/dev/null || touch "$temp_file"
	else
		touch "$temp_file"
	fi

	# Add new entry
	command echo "${query_key}:${timestamp}:${result}" >>"$temp_file"

	# Keep no_tags (permanent) + 10 most recent tagged queries
	{
		grep "^no_tags:" "$temp_file" 2>/dev/null || true
		grep -v "^no_tags:" "$temp_file" 2>/dev/null | sort -t: -k2 -n | tail -10
	} >"$cache_file"

	rm -f "$temp_file"
}

# Import single package function (process just one specific package)
import_package() {
	local target_package="$1"

	if [[ -z "$target_package" ]]; then
		error "Package name required"
		info "Usage: portx packages import-package <package_name>"
		exit 1
	fi

	local pkg_path="$PACKAGES_DIR/$target_package"

	if [[ ! -d "$pkg_path" ]]; then
		error "Package not found: $target_package"
		info "Error: Package directory does not exist"
		info "Available packages:"
		ls "$PACKAGES_DIR" | grep -v "^\." | head -10
		exit 1
	fi

	info "Importing single package: $target_package"

	# Process the specific package
	local pkg_name="$target_package"
	local json_file="$pkg_path/portx.json"

	if [[ ! -f "$json_file" ]]; then
		error "Missing portx.json for package: $pkg_name"
		return 1
	fi

	info "  Processing: $pkg_name"
	info "    Validating: $pkg_name"

	# Validate JSON schema
	info "      Verifying JSON schema"
	if ! "$SCRIPT_DIR/validate-json.sh" "$json_file" >/dev/null 2>&1; then
		error "Invalid portx.json schema"
		info "Package: $pkg_name"
		info "Path: $json_file"
		info ""
		info "Schema validation failed - package MUST be 100%% compliant"
		printf "Validation errors:\n" >&2
		"$SCRIPT_DIR/validate-json.sh" "$json_file" 2>&1 | sed 's/^/  /' >&2
		info "Fix the schema issues and re-run import"
		return 1
	fi
	success "      JSON schema validated successfully"

	# Get import type
	local import_type
	import_type=$(get_import_type "$pkg_path")

	info "      Import type: $import_type"

	case "$import_type" in
	"wrap" | "auto" | "wrapAndPath")
		# Validate and create wrappers
		info "      Verifying executable file paths"

		# Verify all executables exist
		local executables_exist=true
		local verified_count=0
		local total_executables
		total_executables=$(get_executables_from_json "$pkg_path" | wc -l)

		if [[ "$total_executables" -gt 0 ]]; then
			while IFS='|' read -r exe_name _; do
				if [[ -n "$exe_name" ]]; then
					local exe_file="$pkg_path/$exe_name"
					if [[ -f "$exe_file" ]]; then
						info "        Verifying: $exe_name"
						verified_count=$((verified_count + 1))
					else
						error "        MISSING: $exe_name"
						executables_exist=false
					fi
				fi
			done <<<"$(get_executables_from_json "$pkg_path")"
		fi

		if [[ "$executables_exist" == true ]] && [[ "$verified_count" -gt 0 ]]; then
			success "      All $verified_count executables found at correct paths"
		elif [[ "$verified_count" -eq 0 ]]; then
			info "Package $pkg_name has no executables (documentation package?)"
			return 0
		else
			error "Some executables missing for $pkg_name"
			return 1
		fi

		# Create wrappers (controlled by feature flags)
		if [[ "$CREATE_SHELL_WRAPPERS" == "true" ]]; then
			create_bash_wrappers "$pkg_path" "$pkg_name"
		fi
		if [[ "$CREATE_CMD_WRAPPERS" == "true" ]]; then
			create_cmd_wrappers "$pkg_path" "$pkg_name"
		fi
		;;

	"path")
		info "  PATH: $pkg_name"
		;;

	"none")
		info "  SKIP: $pkg_name (documentation only)"
		;;
	esac

	success "Successfully imported package: $target_package"
}

# Import packages function (main package processing logic - no verification)
import_packages() {
	debug "Starting package import scan"

	debug "Starting PORTX package import process"
	info "Importing portx packages"
	info "Scanning packages for import types"

	# Cleanup at beginning - remove old cache files and wrappers
	rm -f "$PORTX_PATH_CACHE" "$PORTX_PACKAGES_CACHE" "$PORTX_TOOLS_CACHE"

	# Remove PORTX wrapper files from both bin and cmd directories
	# Safe deletion: only remove PORTX-tagged wrappers (.sh and .cmd files)
	for wrapper_dir in "$SH_WRAPPERS_DIR" "$CMD_WRAPPERS_DIR"; do
		if [[ -d "$wrapper_dir" ]]; then
			for file in "$wrapper_dir"/*; do
				if [[ -f "$file" ]] && head -n 3 "$file" 2>/dev/null | grep -q "PORTX-WRAPPER"; then
					debug "      Removing PORTX wrapper: $file"
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

			info "  Processing: $pkg_name"
			debug "=== PROCESSING PACKAGE: $pkg_name ==="
			debug "Package path: $pkg_path"

			# COMPREHENSIVE VALIDATION: Schema + executable verification
			if ! validate_package_comprehensive "$pkg_path" "$pkg_name"; then
				debug "Package $pkg_name failed comprehensive validation - SKIPPING"
				continue
			fi

			VALID_PACKAGES=$((VALID_PACKAGES + 1))
			import_type=$(get_import_type "$pkg_path" 2>/dev/null || command echo "auto")
			debug "Package $pkg_name validated successfully, importType: $import_type"

			case "$import_type" in
			"path")
				# Force PATH mode - skip wrapper creation entirely
				info "  PATH: $pkg_name"
				debug "Adding package $pkg_name to PATH mode"
				debug "Forcing PATH mode for $pkg_name"
				add_to_path "$pkg_path" "$pkg_name"
				PATH_PACKAGES=$((PATH_PACKAGES + 1))
				;;
			"none")
				# Documentation package - skip import entirely
				info "  SKIP: $pkg_name (documentation only)"
				debug "Skipping documentation-only package: $pkg_name"
				debug "Skipping documentation package $pkg_name"
				;;
			"wrapAndPath")
				# Create wrappers AND add to PATH for maximum compatibility
				info "  WRAP+PATH: $pkg_name"
				debug "Creating wrappers AND adding to PATH for: $pkg_name"
				debug "Creating wrappers AND adding to PATH for $pkg_name"

				# Create wrappers first
				if [[ "$CREATE_SHELL_WRAPPERS" == "true" ]]; then
					if create_bash_wrappers "$pkg_path" "$pkg_name"; then
						debug "Created bash wrappers for $pkg_name"
						WRAPPER_PACKAGES=$((WRAPPER_PACKAGES + 1))
						WRAPPER_PACKAGE_NAMES+=("$pkg_name")
					fi
				fi
				if [[ "$CREATE_CMD_WRAPPERS" == "true" ]]; then
					if create_cmd_wrappers "$pkg_path" "$pkg_name"; then
						debug "Created cmd wrappers for $pkg_name"
					fi
				fi

				# Also add to PATH
				add_to_path "$pkg_path" "$pkg_name"
				PATH_PACKAGES=$((PATH_PACKAGES + 1))
				debug "Added $pkg_name to PATH (wrapAndPath mode)"
				;;
			*)
				# Default wrapper creation logic
				debug "Creating wrappers for $pkg_name"
				info "      Generating wrapper scripts"

				# Create bash wrapper (controlled by flag)
				if [[ "$CREATE_SHELL_WRAPPERS" == "true" ]]; then
					debug "About to create bash wrappers for $pkg_name"
					if create_bash_wrappers "$pkg_path" "$pkg_name"; then
						debug "Created bash wrappers for $pkg_name"
						WRAPPER_PACKAGES=$((WRAPPER_PACKAGES + 1))
						WRAPPER_PACKAGE_NAMES+=("$pkg_name")
					else
						debug "Failed to create bash wrappers for $pkg_name"
					fi
				else
					debug "Skipping bash wrapper creation (disabled)"
				fi

				# Create .cmd wrapper (controlled by flag)
				if [[ "$CREATE_CMD_WRAPPERS" == "true" ]]; then
					debug "About to create cmd wrappers for $pkg_name"
					if create_cmd_wrappers "$pkg_path" "$pkg_name"; then
						debug "Created cmd wrappers for $pkg_name"
					else
						debug "Failed to create cmd wrappers for $pkg_name"
					fi
				else
					debug "Skipping cmd wrapper creation (disabled)"
				fi

				;;
			esac
		fi
	done

	# Count total executables after processing
	TOTAL_EXECUTABLES=0
	for pkg_path in "$PACKAGES_DIR"/*; do
		if [[ -d "$pkg_path" ]]; then
			pkg_executables=$(get_executables_from_json "$pkg_path" | wc -l)
			TOTAL_EXECUTABLES=$((TOTAL_EXECUTABLES + pkg_executables))
		fi
	done


	# Save configuration with comprehensive header
	{
		command echo "#!/bin/bash"
		command echo "# PORTX PATH Cache"
		command echo "# =========================="
		command echo "#"
		command echo "# PURPOSE: PORTX tools PATH integration"
		command echo "# This provides fast access to all PORTX tools and packages"
		command echo "#"
		command echo "# GENERATION INFO:"
		command echo "#   Generated: $(date '+%a, %b %d, %Y %l:%M:%S %p')"
		command echo "#   Git Bash Directory: $GIT_BASH_ROOT"
		command echo "#   Packages Directory: $PACKAGES_DIR"
		command echo "#"
		command echo "# TOOL COUNTS:"
		command echo "#   Git for Windows: $("$ES_EXE" "$GIT_BASH_ROOT" ext:exe 2>/dev/null | grep -v "home.portx.packages" | wc -l) executables"
		command echo "#   PORTX Wrappers: $("$FD_EXE" "\.cmd$" "$CMD_WRAPPERS_DIR" -u 2>/dev/null | wc -l) wrappers"
		command echo "#   PORTX Packages: $TOTAL_PACKAGES directories, $TOTAL_EXECUTABLES executables"
		command echo "#   Total: $(($("$ES_EXE" "$GIT_BASH_ROOT" ext:exe 2>/dev/null | grep -v "home.portx.packages" | wc -l) + $("$FD_EXE" "\.cmd$" "$CMD_WRAPPERS_DIR" -u 2>/dev/null | wc -l) + TOTAL_EXECUTABLES)) tools"
		command echo "#"
		command echo "# USAGE: This file is automatically sourced by .bashrc on shell startup."
		command echo "# To regenerate: rm ~/.portx_cache or run 'portx import'"
		command echo "#"
		command echo "# CACHE INVALIDATION: Delete this file if any of the following change:"
		command echo "#   - PORTX packages are added/removed/updated"
		command echo "#   - PORTX installation is moved or modified"
		command echo ""
		command echo "# Git Bash Home: $GIT_BASH_ROOT"
		command echo ""
		command echo "# Build PORTX PACKAGES PATH"
		command echo "PACKAGES_PATH=\"\""

		# Add package directories with executable counts
		for pkg_path in "${PATH_PACKAGE_PATHS[@]}"; do
			pkg_name="$(basename "$pkg_path")"
			exe_count=$("$FD_EXE" "\.exe$" "$pkg_path" -d 1 -u 2>/dev/null | wc -l)
			command echo "PACKAGES_PATH=\"\$PACKAGES_PATH:$pkg_path\"  # $exe_count executables"
		done

		command echo "# PORTX packages added: $PATH_PACKAGES directories"
		command echo ""
		command echo "# NOTE: .bashrc controls PATH integration using PACKAGES_PATH"
		command echo ""
		command echo "# PORTX PATH statistics"

		# Calculate Git for Windows stats (directories with executables / total executables)
		GFW_DIRS=$("$FD_EXE" "\.exe$" "$GIT_BASH_ROOT_POSIX/bin" "$GIT_BASH_ROOT_POSIX/mingw64/bin" "$GIT_BASH_ROOT_POSIX/usr/bin" -u -x dirname 2>/dev/null | sort -u | wc -l)
		GFW_EXECUTABLES=$("$ES_EXE" "$GIT_BASH_ROOT" 2>/dev/null | grep "\.exe$" | grep -v "home.portx.packages" | wc -l)
		PORTX_WRAPPERS_COUNT=$("$FD_EXE" "\.cmd$" "$CMD_WRAPPERS_DIR" -u 2>/dev/null | wc -l)
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
		command echo "export PORTX_ENV_TYPE=\"$env_info\""
		command echo "export GFW_DIRS=$GFW_DIRS"
		command echo "export GFW_EXECUTABLES=$GFW_EXECUTABLES"
		command echo "export PORTX_PKG_DIRS=$TOTAL_PACKAGES"
		command echo "export PORTX_PKG_EXECUTABLES=$TOTAL_EXECUTABLES"
		command echo "export PORTX_TOTAL_EXECUTABLES=$TOTAL_COUNT"
		command echo "export PORTX_TOTAL_DIRS=$TOTAL_DIRS"
		command echo "export PORTX_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
		command echo "export PATH_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
		command echo ""
	} >"$PORTX_PATH_CACHE"

	# Count actual wrapper files created by extension and content
	local bash_wrappers=0
	local cmd_wrappers=0

	# Count bash wrappers containing PORTX-WRAPPER
	if [[ -d "$SH_WRAPPERS_DIR" ]]; then
		bash_wrappers=$("$FD_EXE" -t f . "$SH_WRAPPERS_DIR" -u -x grep -l "PORTX-WRAPPER" 2>/dev/null | wc -l)
	fi

	# Count cmd wrappers containing PORTX-WRAPPER
	if [[ -d "$CMD_WRAPPERS_DIR" ]]; then
		cmd_wrappers=$("$FD_EXE" "\.cmd$" "$CMD_WRAPPERS_DIR" -u -x grep -l "PORTX-WRAPPER" 2>/dev/null | wc -l)
	fi

	local total_wrappers=$((bash_wrappers + cmd_wrappers))

	success "Imported $TOTAL_PACKAGES packages, $TOTAL_EXECUTABLES executables, $PATH_PACKAGES PATH packages, $WRAPPER_PACKAGES wrapper packages ($total_wrappers total wrappers: $bash_wrappers bash + $cmd_wrappers cmd)"
}

# ===== TOOLS AGGREGATOR FUNCTIONALITY (from portx.sh backup) =====

# Show manual function
show_manual() {
	local package_name="$1"

	if [[ -z "$package_name" ]]; then
		error "Package name required"
		info "Usage: portx man <package_name>"
		exit 1
	fi

	local manual_file="$PACKAGES_DIR/$package_name/package-manual.md"

	if [[ ! -f "$manual_file" ]]; then
		error "Manual not found for package: $package_name"
		info "Package may not be installed or manual file is missing."
		info "Try: portx packages list"
		exit 1
	fi

	info "Showing manual for package: $package_name"
	info ""

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
		command echo "$cached_result"
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
		if [[ -d "$pkg_dir" && -f "$pkg_dir/portx.json" ]]; then
			# If filter expression is provided, filter at tool level (checking both tool and package tags)
			if [[ -n "$filter_expression" ]]; then
				# Use jq to extract tools with combined package+tool tags, then filter in bash
				while IFS='|' read -r exe_name tag_list; do
					if [[ -n "$exe_name" ]]; then
						# Parse combined tags into bash array for boolean evaluation
						local combined_tags=()
						if [[ -n "$tag_list" ]]; then
							# Split comma-separated tags and clean them
							IFS=',' read -ra tag_array <<<"$tag_list"
							for tag in "${tag_array[@]}"; do
								# Remove carriage returns and whitespace
								tag="${tag//$'\r'/}"
								tag=$(command echo "$tag" | xargs)
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
					# Use new schema (bin object) - no fallback, crash if not compliant
				done < <($JQ_CMD -r '. as $root | .bin | to_entries[] | "\(.key)|\(((.value.tags // []) + ($root.tags // [])) | unique | join(","))"' "$pkg_dir/portx.json" 2>/dev/null)
			else
				# No filter - extract all executables
				while IFS= read -r exe; do
					if [[ -n "$exe" ]]; then
						# Remove carriage returns
						exe="${exe//$'\r'/}"
						all_tools+=("$exe")
					fi
					# Use new schema (bin object) - no fallback, crash if not compliant
				done < <($JQ_CMD -r '.bin | keys[]' "$pkg_dir/portx.json" 2>/dev/null)
			fi
		fi
	done

	# Sort and output tools with comma delimiter
	local temp_file
	temp_file=$(mktemp)
	command printf '%s\n' "${all_tools[@]}" >"$temp_file"

	# Use dos2unix to clean line endings, then sort and deduplicate
	dos2unix "$temp_file" 2>/dev/null || true
	local result
	result=$(sort -u "$temp_file" | tr '\n' ',' | sed 's/,$//')

	# Save to smart LRU cache
	save_to_cache "$cache_key" "$result"

	# Output result
	command echo "$result"

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
		width=$(tput cols 2>/dev/null || command echo "$DEFAULT_TERMINAL_WIDTH")
	elif [[ -n "${COLUMNS:-}" ]]; then
		width="$COLUMNS"
	else
		width="$DEFAULT_TERMINAL_WIDTH" # Default to modern terminal width
	fi

	# Ensure minimum width
	if [[ $width -lt $MIN_TERMINAL_WIDTH ]]; then
		width="$MIN_TERMINAL_WIDTH"
	fi

	command echo "$width"
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
		command echo "30" # fallback to reasonable width
		return
	fi

	for pkg_dir in "$PACKAGES_DIR"/*; do
		if [[ -d "$pkg_dir" && -f "$pkg_dir/portx.json" ]]; then
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
					current_width=$((${#executable} + 2)) # Add 2 for "- " prefix
					if [[ $current_width -gt $max_width ]]; then
						max_width=$current_width
					fi
				fi
				# Use new schema (bin object) - no fallback, crash if not compliant
			done < <($JQ_CMD -r '.bin | to_entries[] | "\(.key)|\(.value.description // "")|\((.value.tags // []) | join(", "))"' "$pkg_dir/portx.json" 2>/dev/null)
		fi
	done

	# Add some padding but ensure minimum width
	local result=$((max_width + 2))
	if [[ $result -lt 25 ]]; then
		result=25
	fi
	command echo "$result"
}

# Helper function to return 2-column widths based on actual data
_get_column_widths() {
	local actual_name_width
	actual_name_width=$(_calculate_max_name_width)
	local desc_width=$((120 - actual_name_width - 1))
	command echo "$actual_name_width:$desc_width"
}

# Helper function to wrap text with color escape sequence handling
_wrap_text() {
	local text="$1"
	local content_width="$2" # Width available for content (without prefix)
	local first_line_prefix="$3"
	local continuation_prefix="$4"

	# If text fits within content width, return it (hashtag coloring disabled for now)
	if [[ ${#text} -le $content_width ]]; then
		command printf "%s%s\n" "$first_line_prefix" "$text"
		return
	fi

	# Split into words for careful wrapping
	local words
	read -ra words <<<"$text"
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
					info "$first_line_prefix$current_line"
					is_first_line=false
				else
					command printf "%s%s\n" "$continuation_prefix" "$current_line"
				fi
			fi
			current_line="$word"
		fi
	done

	# Output final line (hashtag coloring disabled for now)
	if [[ -n "$current_line" ]]; then
		if $is_first_line; then
			info "$first_line_prefix$current_line"
		else
			command printf "%s%s\n" "$continuation_prefix" "$current_line"
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
	tags=$(command echo "$tags" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	if [[ -n "$tags" && "$tags" != "" ]]; then
		combined_content="$description [$tags]"
	fi

	# Create the prefixes for first line and continuation lines
	local first_line_prefix
	local continuation_prefix

	command printf -v first_line_prefix "%-*s " "$name_width" "$display_name"
	command printf -v continuation_prefix "%*s " "$name_width" ""

	# Use wrapping function to format the combined content
	_wrap_text "$combined_content" "$desc_width" "$first_line_prefix" "$continuation_prefix"
}

# Internal function to generate the packages list
_generate_packages_list() {

	local total_tools=0
	local total_packages=0

	# Check if packages directory exists
	if [[ ! -d "$PACKAGES_DIR" ]]; then
		error "Packages directory not found: $PACKAGES_DIR"
		return 1
	fi

	# Check if jq is available
	local JQ_CMD=""
	if command -v jq >/dev/null 2>&1; then
		JQ_CMD="jq"
	elif command -v jq.cmd >/dev/null 2>&1; then
		JQ_CMD="jq.cmd"
	else
		error "jq not found in PATH - required for portx.json parsing"
		return 1
	fi

	# Get fixed column widths
	local column_widths
	column_widths=$(_get_column_widths)

	local name_width desc_width
	IFS=':' read -r name_width desc_width <<<"$column_widths"

	for pkg_dir in "$PACKAGES_DIR"/*; do
		if [[ -d "$pkg_dir" && -f "$pkg_dir/portx.json" ]]; then
			local pkg_name
			pkg_name=$(basename "$pkg_dir")

			# Extract package metadata safely
			local pkg_description=""
			local tool_count=0

			pkg_description=$($JQ_CMD -r '.description // ""' "$pkg_dir/portx.json" 2>/dev/null || command echo "")

			# Count tools from both new bin format and legacy tools format
			local bin_count
			local tools_count
			bin_count=$($JQ_CMD -r 'if .bin then .bin | keys | length else 0 end' "$pkg_dir/portx.json" 2>/dev/null || command echo "0")
			tools_count=$($JQ_CMD -r 'if .tools then .tools | length else 0 end' "$pkg_dir/portx.json" 2>/dev/null || command echo "0")
			tool_count=$((bin_count + tools_count))

			# Skip packages with no executables
			if [[ "$tool_count" -eq 0 ]]; then
				continue
			fi

			((total_packages++))
			total_tools=$((total_tools + tool_count))

			# Display package header using authoritative left-aligned padding approach
			pkg_header="$pkg_name"
			info "$(command printf "%-*s %s" "$name_width" "$pkg_header" "$pkg_description")"

			# Format tools using the new 2-column layout
			while IFS='|' read -r executable description tags; do
				if [[ -n "$executable" ]]; then
					_format_tool_entry "$executable" "$description" "$tags" \
						"$name_width" "$desc_width"
				fi
			done < <($JQ_CMD -r 'if .bin then .bin | to_entries[] | "\(.key)|\(.value.description // "")|\((.value.tags // []) | join(", "))" else empty end' "$pkg_dir/portx.json" 2>/dev/null)
			info ""
		fi
	done

	info "Summary: $total_packages packages, $total_tools total tools"
}

# Search tools by pattern (simplified version - manual parsing removed)
search_tools() {
	local pattern="$1"
	local matches=0

	info "Searching for '$pattern'..."

	info "Search Results for '$pattern'"
	info ""

	# Check if jq is available
	local JQ_CMD=""
	if command -v jq >/dev/null 2>&1; then
		JQ_CMD="jq"
	elif command -v jq.cmd >/dev/null 2>&1; then
		JQ_CMD="jq.cmd"
	else
		error "jq not found in PATH - required for portx.json parsing"
		return 1
	fi

	for pkg_dir in "$PACKAGES_DIR"/*; do
		if [[ -d "$pkg_dir" && -f "$pkg_dir/portx.json" ]]; then
			local pkg_name
			pkg_name=$(basename "$pkg_dir")

			# Search in tools using jq
			while IFS='|' read -r executable description; do
				if [[ -n "$executable" ]] && command echo "$executable $description" | grep -qi "$pattern"; then
					info "$(command printf "%-20s %-25s %s" "$executable" "($pkg_name)" "$description")"
					((matches++))
				fi
				# Use new schema (bin object) - no fallback, crash if not compliant
			done < <($JQ_CMD -r '.bin | to_entries[] | "\(.key)|\(.value.description // "")"' "$pkg_dir/portx.json" 2>/dev/null)
		fi
	done

	info ""
	info "Found $matches matches"
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
		error "jq not found in PATH - required for portx.json parsing"
		return 1
	fi

	for pkg_dir in "$PACKAGES_DIR"/*; do
		if [[ -d "$pkg_dir" && -f "$pkg_dir/portx.json" ]]; then
			((total_packages++))
			local pkg_name
			pkg_name=$(basename "$pkg_dir")
			local package_tool_count=0

			# Count from new schema (bin object) - no fallback, crash if not compliant
			package_tool_count=$($JQ_CMD -r '.bin | keys | length' "$pkg_dir/portx.json" 2>/dev/null || command echo "0")
			total_tools=$((total_tools + package_tool_count))
			package_counts["$pkg_name"]=$package_tool_count
		fi
	done

	printf "\n%sPORTX Tools Statistics%s\n" "$(color_success)" "$(color_reset)"
	info "Total Packages: $total_packages"
	info "Total Tools: $total_tools"
	info ""

	info ""
	info "Top Packages by Tool Count:"
	for package in "${!package_counts[@]}"; do
		if [[ ${package_counts[$package]} -gt 0 ]]; then
			info "$(command printf "  %-20s %d tools" "$package" "${package_counts[$package]}")"
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
	import-package)
		import_package "$2"
		;;
	# verify command removed - use import instead
	list | ls)
		list_packages
		;;
	search | find)
		if [[ -z "$2" ]]; then
			error "Search pattern required"
			info "Usage: portx packages search <pattern>"
			exit 1
		fi
		search_tools "$2"
		;;
	count | stats)
		show_tools_count
		;;
	help | --help | -h)
		info "PORTX Package Manager"
		info ""
		info "Usage: portx packages <command> [options]"
		info ""
		info "Commands:"
		info "  import            Import and configure all packages"
		info "  import-package    Import a specific package by name"
		info "  list              List all available tools"
		info "  search PATTERN    Search tools by name or description"
		info "  count             Show tool count statistics"
		info "  help              Show this help message"
		info ""
		info "Examples:"
		info "  portx packages import"
		info "  portx packages import-package analyze-code"
		info "  portx packages list"
		info "  portx packages search git"
		info "  portx packages count"
		;;
	*)
		error "Unknown packages command: $command"
		info "Try: portx packages help"
		exit 1
		;;
	esac
}

# Show help
show_help() {
	info "PORTX Package Manager"
	info ""
	info "Usage: portx <command> [arguments]"
	info ""
	info "Commands:"
	info "  packages [command]  Access PORTX tools aggregator"
	info "  tools [--tags=...]  List all tools (flat, space-separated), optionally filter by tags"
	info "  man <package>       Show package manual"
	info "  help               Show this help"
	info ""
	info "Examples:"
	info "  portx packages import"
	info "  portx packages verify"
	info "  portx packages list"
	info "  portx packages search git"
	info "  portx tools"
	info "  portx tools --tags=bash"
	info "  portx tools --tags=bash,security"
	info "  portx man ag"
}

# Main script logic
main() {
	# Parse command
	local command="${1:-help}"
	debug "Starting portx.sh with command: $command"

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
		info ""
		show_help
		exit 1
		;;
	esac
}

# Run main function with all arguments
main "$@"
