# BASH EDITING STANDARDS FOR GIT BASH WINDOWS
## Essential Rules and Best Practices (2025)

**Version:** 1.0  
**Environment:** Git Bash on Windows 10/11  
**Compatibility:** Focused on essential, widely-supported practices  
**Tool Integration:** 15+ PORTX tools for quality assurance  

---

## 📋 TABLE OF CONTENTS

1. [Environment Setup](#environment-setup)
2. [Script Structure](#script-structure)
3. [Syntax Standards](#syntax-standards)
4. [Variable Management](#variable-management)
5. [Error Handling](#error-handling)
6. [Formatting Guidelines](#formatting-guidelines)
7. [Tool Integration](#tool-integration)
8. [Git Bash Windows Compatibility](#git-bash-windows-compatibility)
9. [Quality Assurance Workflow](#quality-assurance-workflow)
10. [PORTX Tools Reference](#portx-tools-reference)

---

## 🔧 ENVIRONMENT SETUP

### Shell Selection
```bash
#!/bin/bash
# Always use bash for scripting
# Avoid sh, zsh, fish for consistency
```

### Environment Variables
```bash
# Essential Git Bash variables
export TERM=xterm-256color
export SHELL="/bin/bash"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

### Safety Settings (Critical)
```bash
set -o errexit    # Exit on command failure
set -o pipefail   # Exit on pipeline failures
# set -o nounset  # Optional: Exit on undefined variables
```

---

## 📝 SCRIPT STRUCTURE

### Five-Section Standard Structure
```bash
#!/bin/bash
# =============================================================================
# SCRIPT NAME
# Brief description of script purpose
# =============================================================================
#
# DESCRIPTION:
#   Detailed description of what this script does
#
# USAGE:
#   script_name [options] arguments
#
# AUTHOR: Your Name
# VERSION: 1.0.0
# =============================================================================

# SECTION 1: Constants and Configuration
readonly SCRIPT_DIR="$(dirname "$0")"
readonly VERSION="1.0.0"

# SECTION 2: Global Variables
declare script_mode="production"

# SECTION 3: Functions
main() {
    # Main program logic
    return 0
}

# SECTION 4: Error Handling
cleanup() {
    # Cleanup operations
    return 0
}

# SECTION 5: Main Execution
trap cleanup EXIT
main "$@"
```

---

## ⚙️ SYNTAX STANDARDS

### Conditional Testing
```bash
# ✅ CORRECT: Use [[ ]] for all tests
if [[ -f "${file}" ]]; then
    echo "File exists"
elif [[ -d "${directory}" ]]; then
    echo "Directory exists"
fi

# ✅ CORRECT: Arithmetic comparisons
if (( count > 10 )); then
    echo "Count is greater than 10"
fi

# ❌ AVOID: Old-style [ ] tests
if [ -f "$file" ]; then
    echo "Avoid this style"
fi
```

### Command Substitution
```bash
# ✅ CORRECT: Use $() syntax
current_date=$(date +%Y-%m-%d)
file_count=$(find . -name "*.sh" | wc -l)

# ❌ AVOID: Backticks
current_date=`date +%Y-%m-%d`
```

### Loop Constructs
```bash
# ✅ CORRECT: Array iteration
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    echo "Processing: ${file}"
done

# ✅ CORRECT: Range iteration
for (( i=1; i<=10; i++ )); do
    echo "Number: ${i}"
done
```

---

## 📊 VARIABLE MANAGEMENT

### Naming Conventions
```bash
# ✅ CORRECT: Consistent naming
readonly MAX_RETRIES=5          # Constants: ALL_CAPS
local user_name="john"          # Local vars: lowercase_underscore
export API_KEY="secret"         # Environment: ALL_CAPS
```

### Quoting Rules (Critical)
```bash
# ✅ CORRECT: Always quote variables
echo "User name: ${user_name}"
cp "${source_file}" "${destination_dir}/"
command --option="${config_value}"

# ✅ CORRECT: Array handling
declare -a files=("file1.txt" "file with spaces.txt")
for file in "${files[@]}"; do
    process_file "${file}"
done
```

### Variable Declaration
```bash
# ✅ CORRECT: Explicit declaration
declare -r SCRIPT_NAME="backup_tool"    # Readonly
declare -i counter=0                     # Integer
declare -a file_list=()                 # Array
declare -A config_map=()                # Associative array

# ✅ CORRECT: Local variables in functions
process_file() {
    local file_path="$1"
    local backup_dir="$2"
    # Function logic here
}
```

---

## 🚨 ERROR HANDLING

### Exit Codes
```bash
# Standard exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2
readonly EXIT_FILE_NOT_FOUND=3

# Usage
if [[ ! -f "${config_file}" ]]; then
    echo "Error: Configuration file not found: ${config_file}" >&2
    exit "${EXIT_FILE_NOT_FOUND}"
fi
```

### Error Reporting
```bash
# ✅ CORRECT: Send errors to stderr
error() {
    echo "ERROR: $*" >&2
}

warning() {
    echo "WARNING: $*" >&2
}

# Usage
error "Failed to create backup directory"
warning "Configuration file not found, using defaults"
```

### Safe Operations
```bash
# ✅ CORRECT: Check operations
if ! cd "${target_directory}"; then
    error "Failed to change directory to: ${target_directory}"
    exit "${EXIT_FAILURE}"
fi

# ✅ CORRECT: Command validation
if ! command -v rsync >/dev/null 2>&1; then
    error "rsync is required but not installed"
    exit "${EXIT_FAILURE}"
fi
```

---

## 🎨 FORMATTING GUIDELINES

### Indentation and Spacing
```bash
# Use 4 spaces for indentation (SHFMT standard)
if [[ condition ]]; then
    command1
    if [[ nested_condition ]]; then
        nested_command
    fi
fi

# Function formatting
function_name() {
    local param1="$1"
    local param2="$2"
    
    # Function body with proper spacing
    return 0
}
```

### Line Length and Breaking
```bash
# Keep lines under 80 characters
# Break long commands across lines
very_long_command \
    --option1 "value1" \
    --option2 "value2" \
    --option3 "value3"

# Pipeline breaking
cat "${input_file}" \
    | grep -v "^#" \
    | sort \
    | uniq > "${output_file}"
```

### Comments and Documentation
```bash
# Function documentation template
# process_backup() - Create incremental backup
#
# DESCRIPTION:
#   Creates an incremental backup of specified directory
#
# PARAMETERS:
#   $1 - source_directory: Directory to backup
#   $2 - backup_directory: Destination for backup
#
# RETURNS:
#   0 - Success
#   1 - Failure
#
# EXAMPLE:
#   process_backup "/home/user/data" "/backup/user"
process_backup() {
    local source_directory="$1"
    local backup_directory="$2"
    
    # Implementation here
    return 0
}
```

---

## 🔧 TOOL INTEGRATION

### ShellCheck Integration (Essential)
```bash
# .shellcheckrc configuration
source-path=SCRIPTDIR
external-sources=true
enable=quote-safe-variables
enable=check-unassigned-uppercase
disable=SC2034  # Unused variables (if needed)

# Run shellcheck
shellcheck --format=gcc --severity=warning *.sh
```

### SHFMT Formatting
```bash
# Format scripts with consistent style
shfmt -i 4 -ci -w *.sh

# Options:
# -i 4    : 4-space indentation
# -ci     : Continuous indentation for line breaks
# -w      : Write result to file
```

### Pre-commit Integration
```bash
#!/bin/bash
# pre-commit-hook.sh
# Quality checks before commit

echo "Running code quality checks..."

# 1. ShellCheck validation
if ! shellcheck --format=gcc *.sh; then
    echo "❌ ShellCheck failed"
    exit 1
fi

# 2. Format validation
if ! shfmt -d *.sh >/dev/null; then
    echo "❌ Format issues found. Run: shfmt -i 4 -ci -w *.sh"
    exit 1
fi

echo "✅ All quality checks passed"
```

---

## 🪟 GIT BASH WINDOWS COMPATIBILITY

### Path Handling
```bash
# ✅ CORRECT: Use POSIX paths in scripts
readonly CONFIG_DIR="/c/App/MyApp/config"
readonly LOG_FILE="/tmp/application.log"

# Convert Windows paths when needed
windows_to_posix() {
    local windows_path="$1"
    echo "${windows_path}" | sed 's|\\|/|g' | sed 's|^\([A-Z]\):|/\L\1|'
}

# Example: C:\Program Files -> /c/program files
```

### Environment Integration
```bash
# Git Bash specific variables
if [[ -n "${MSYSTEM}" ]]; then
    echo "Running in Git Bash MSYS2 environment: ${MSYSTEM}"
fi

# Windows integration
if command -v powershell.exe >/dev/null 2>&1; then
    echo "PowerShell available for Windows integration"
fi
```

### File Operations
```bash
# Handle Windows-specific considerations
create_file_safely() {
    local file_path="$1"
    local content="$2"
    
    # Ensure directory exists
    local dir_path
    dir_path="$(dirname "${file_path}")"
    if [[ ! -d "${dir_path}" ]]; then
        mkdir -p "${dir_path}"
    fi
    
    # Create file with proper line endings
    printf '%s\n' "${content}" > "${file_path}"
}
```

---

## ✅ QUALITY ASSURANCE WORKFLOW

### Development Workflow
```bash
# 1. Write script following standards
# 2. Run quality checks
quality_check() {
    local script_file="$1"
    
    echo "Checking: ${script_file}"
    
    # ShellCheck validation
    if ! shellcheck "${script_file}"; then
        echo "❌ ShellCheck failed"
        return 1
    fi
    
    # Format check
    if ! shfmt -d "${script_file}" >/dev/null; then
        echo "❌ Format issues found"
        return 1
    fi
    
    # Syntax check
    if ! bash -n "${script_file}"; then
        echo "❌ Syntax error"
        return 1
    fi
    
    echo "✅ Quality check passed"
    return 0
}

# 3. Apply formatting
format_script() {
    local script_file="$1"
    echo "Formatting: ${script_file}"
    shfmt -i 4 -ci -w "${script_file}"
}
```

### Validation Checklist
- [ ] Script has proper shebang (`#!/bin/bash`)
- [ ] All variables are quoted (`"${variable}"`)
- [ ] Functions have local variable declarations
- [ ] Error handling is implemented
- [ ] ShellCheck passes with no warnings
- [ ] SHFMT formatting is applied
- [ ] Script runs without syntax errors
- [ ] Documentation is complete

---

## 🛠️ PORTX TOOLS REFERENCE

### Primary Analysis Tools

#### 1. ShellCheck (v0.11.0) - Essential
```bash
# Basic usage
shellcheck script.sh

# Comprehensive check
shellcheck --format=gcc --severity=warning --external-sources *.sh

# Configuration file: .shellcheckrc
source-path=SCRIPTDIR
external-sources=true
enable=quote-safe-variables
```

#### 2. SHFMT (v3.12.0) - Formatting
```bash
# Check formatting
shfmt -d script.sh

# Apply formatting
shfmt -i 4 -ci -w script.sh

# Options:
# -d: Show diff instead of rewriting
# -i: Indentation (spaces or tabs)
# -ci: Continuous indentation for line breaks
```

#### 3. AST-GREP (v0.39.4) - Syntax Analysis
```bash
# Analyze bash constructs
ast-grep -l bash script.sh

# Pattern matching for code analysis
ast-grep --json 'function_name()' script.sh
```

### Code Quality Tools

#### 4. SCC (v3.5.0) - Code Metrics
```bash
# Analyze code complexity
scc script.sh

# Output: lines, code, comments, blanks, complexity
```

#### 5. TOKEI (v12.1.2) - Statistics
```bash
# Code statistics
tokei script.sh

# Detailed language breakdown
```

#### 6. CLOC (v2.06) - Line Counting
```bash
# Lines of code analysis
cloc script.sh

# Detailed breakdown by language
```

### Search and Analysis Tools

#### 7. Ripgrep (v13.0.0) - Pattern Search
```bash
# Search for patterns
rg 'TODO|FIXME|XXX' *.sh

# Find deprecated constructs
rg '\$\(' *.sh

# Case-insensitive search
rg -i 'error' *.sh
```

#### 8. FD (v10.2.0) - File Discovery
```bash
# Find shell scripts
fd -e sh -e bash

# Find by pattern
fd 'test.*\.sh$'
```

#### 9. AG (v2.2.0) - Silver Searcher
```bash
# Search in files
ag 'function.*\(' *.sh

# Show context
ag -C 3 'export' *.sh
```

### Documentation and Display

#### 10. BAT (v0.24.0) - Enhanced Display
```bash
# Syntax-highlighted display
bat script.sh

# Line numbers and Git integration
bat -n script.sh
```

#### 11. CTAGS (v6.2.0) - Symbol Analysis
```bash
# Generate tags for functions
ctags -x --language-force=sh script.sh

# Create tags file
ctags -R *.sh
```

### Development Tools

#### 12. DPRINT (v0.50.1) - Code Formatting
```bash
# Check formatting (requires config)
dprint check script.sh

# Configuration: dprint.json required
```

#### 13. ShellSpec (v0.28.1) - Testing Framework
```bash
# Run tests
shellspec

# Test specification format for bash scripts
```

### Security and System Analysis

#### 14. OSQuery (v5.18.1) - System Analysis
```bash
# Query system information
osqueryi "SELECT * FROM processes WHERE name LIKE '%bash%'"

# File system analysis
```

#### 15. YARA (v4.5.4) - Pattern Matching
```bash
# Pattern matching for security analysis
yara32 rules.yar script.sh

# Custom rule creation for bash analysis
```

---

## 📚 QUICK REFERENCE

### Essential Commands
```bash
# Quality check sequence
shellcheck --format=gcc *.sh
shfmt -d *.sh
bash -n *.sh

# Apply fixes
shfmt -i 4 -ci -w *.sh

# Code analysis
scc *.sh
rg 'TODO|FIXME' *.sh
fd -e sh
```

### Common ShellCheck Fixes
```bash
# SC2086: Quote variables
echo "${variable}"  # not: echo $variable

# SC2034: Unused variables
readonly UNUSED_VAR="value"  # or use _
_ = "${unused_value}"

# SC1091: Source file not found
# shellcheck source=/dev/null
source "${dynamic_file}"

# SC2155: Separate declare and assign
result=$(command)
readonly result
```

### Git Integration
```bash
# Pre-commit hook
#!/bin/bash
shellcheck --format=gcc *.sh && shfmt -d *.sh

# Makefile target
check-scripts:
    shellcheck *.sh
    shfmt -d *.sh
```

---

## 🎯 SUMMARY

This document provides **essential bash standards** for Git Bash Windows environment focusing on:

- **Compatibility** with Git Bash Windows limitations
- **Essential practices** avoiding niche features
- **Tool integration** using 15+ PORTX tools
- **Quality assurance** with automated checks
- **Professional standards** following industry best practices

Follow these standards for maintainable, portable, and high-quality bash scripts in Git Bash Windows environment.

---

**Last Updated:** 2025-08-22  
**Applies To:** Git Bash on Windows 10/11  
**Tool Versions:** See individual tool references above  
**Compliance:** GNU Bash, Google Style Guide, POSIX where applicable