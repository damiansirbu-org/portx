#!/bin/bash
# PORTX Comprehensive Tool Testing Script
# Tests all executables using the same discovery logic as portx-tools
# Generates detailed reports with categorization and analysis

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Determine PORTX_ROOT using same logic as portx-tools
if [[ -f "C:/App/PORTX/doc/tools.md" ]]; then
    PORTX_ROOT="C:/App/PORTX"
elif [[ -n "$PORTX_ROOT" ]]; then
    PORTX_ROOT="$PORTX_ROOT"
elif [[ -n "${BASH_SOURCE[0]}" ]]; then
    PORTX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
    echo "❌ Error: Cannot locate PORTX installation"
    exit 1
fi

# File paths
REPORT_FILE="$PORTX_ROOT/tool-test-report.md"
SUMMARY_FILE="$PORTX_ROOT/tool-test-summary.md"
BROKEN_LIST="$PORTX_ROOT/broken-tools.txt"
TEMP_LOG="/tmp/portx-test-$$.log"

# Counters
declare -i TOTAL_TOOLS=0
declare -i WORKING_TOOLS=0
declare -i BROKEN_TOOLS=0
declare -i MISSING_TOOLS=0

# Arrays for categorization
declare -A BROKEN_BY_CATEGORY
declare -A WORKING_BY_CATEGORY
declare -A MISSING_BY_CATEGORY

# Tools that open GUIs/browsers - skip testing these
declare -A SKIP_TOOLS=(
    ["git-web--browse"]="opens-browser"
    ["git-instaweb"]="opens-browser"
    ["git-help"]="opens-browser"
    ["git-bisect--helper"]="opens-browser"
    ["git-checkout--worker"]="opens-browser"
    ["gitk"]="opens-gui"
    ["git-gui"]="opens-gui"
    ["winpty"]="interactive-tool"
    ["winpty-agent"]="interactive-tool"
    ["winpty-debugserver"]="interactive-tool"
)

# Special tool handling patterns
declare -A SPECIAL_TOOLS=(
    # SysInternals tools need -accepteula
    ["accesschk64"]="-accepteula"
    ["adrestore64"]="-accepteula"
    ["autorunsc64"]="-accepteula"
    ["clockres64"]="-accepteula"
    ["Contig64"]="-accepteula"
    ["Coreinfo64"]="-accepteula"
    ["FindLinks64"]="-accepteula"
    ["handle64"]="-accepteula"
    ["LogonSessions64"]="-accepteula"
    ["PendMoves64"]="-accepteula"
    ["PsExec64"]="-accepteula"
    ["PsGetsid64"]="-accepteula"
    ["PsList64"]="-accepteula"
    ["PsLoggedon64"]="-accepteula"
    ["pipelist64"]="-accepteula"
    ["procdump64"]="-accepteula"
    ["psfile64"]="-accepteula"
    ["psinfo64"]="-accepteula"
    ["pskill64"]="-accepteula"
    ["psping64"]="-accepteula"
    ["RegDelNull64"]="-accepteula"
    ["streams64"]="-accepteula"
    ["strings64"]="-accepteula"
    ["sync64"]="-accepteula"
    ["VolumeId64"]="-accepteula"
    ["whois64"]="-accepteula"
    ["hex2dec64"]="-accepteula"
    ["junction64"]="-accepteula"
    ["listdlls64"]="-accepteula"
    
    # Tools that show version/info without flags
    ["tcc"]="--version"
    ["tiny_impdef"]="no-args"
    ["tiny_libmaker"]="no-args"
    
    # Git tools that look for documentation
    ["git-bisect--helper"]="--help"
    ["git-checkout--worker"]="--help"
    
    # Tools that show usage info
    ["blocked-file-util"]="--help"
    ["hprof-conv"]="--help"
    
    # ClamAV tools need config
    ["clamd"]="--help"
    ["clamdscan"]="--help"
    ["clamscan"]="--help"
    ["freshclam"]="--help"
    ["sigtool"]="--help"
    ["clambc"]="--help"
    ["clamconf"]="--help"
    ["clamdtop"]="--help"
    ["clamsubmit"]="--help"
    
    # Network tools that may need elevated permissions
    ["bandwhich"]="--help"
    
    # Newman (Node.js based)
    ["newman"]="--version"
)

show_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}   PORTX Comprehensive Tool Testing${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo
}

# Function to scan directories and find all executables (same logic as PORTX path building)
scan_executables() {
    local base_dir="$1"
    local category="$2"
    local max_depth="${3:-4}"  # Changed default to 4 as requested
    
    if [[ ! -d "$base_dir" ]]; then
        echo "⚠️  Directory not found: $base_dir"
        return
    fi
    
    echo -e "📁 Scanning ${YELLOW}$category${NC} in $base_dir (depth: $max_depth)"
    
    # Find all .exe files up to specified depth, excluding .dll files
    while IFS= read -r -d '' exe_file; do
        test_executable "$exe_file" "$category"
    done < <(find "$base_dir" -maxdepth "$max_depth" -name "*.exe" -not -name "*.dll" -print0 2>/dev/null)
}

# Test individual executable with smart handling
test_executable() {
    local exe_path="$1"
    local category="$2"
    local exe_name=$(basename "$exe_path" .exe)
    local rel_path="${exe_path#$PORTX_ROOT/}"
    
    # Skip tools that open GUIs or browsers
    if [[ -n "${SKIP_TOOLS[$exe_name]}" ]]; then
        echo -e "   ⏭️  Skipping $exe_name (${SKIP_TOOLS[$exe_name]})"
        return
    fi
    
    # Skip git-core internal tools (they often try to open documentation)
    if [[ "$category" == "Git4Windows-Core" && "$exe_name" == git-* ]]; then
        echo -e "   ⏭️  Skipping $exe_name (git-core-internal)"
        return
    fi
    
    ((TOTAL_TOOLS++))
    
    # Show progress every 50 tools
    if (( TOTAL_TOOLS % 50 == 0 )); then
        echo -e "   📊 Tested: $TOTAL_TOOLS tools..."
    fi
    
    local test_result="BROKEN"
    local error_msg=""
    local test_output=""
    
    # Check if file exists and is executable
    if [[ ! -f "$exe_path" ]]; then
        test_result="MISSING"
        error_msg="File not found"
        ((MISSING_TOOLS++))
        MISSING_BY_CATEGORY["$category"]=$((${MISSING_BY_CATEGORY["$category"]:-0} + 1))
        log_result "$exe_name" "$category" "$rel_path" "$test_result" "$error_msg"
        return
    fi
    
    # Check for special tool handling
    local special_arg=""
    if [[ -n "${SPECIAL_TOOLS[$exe_name]}" ]]; then
        special_arg="${SPECIAL_TOOLS[$exe_name]}"
    fi
    
    # Test different command patterns based on tool type
    local test_commands=()
    
    if [[ "$special_arg" == "-accepteula" ]]; then
        # SysInternals tools
        test_commands=("-accepteula" "-accepteula /?" "-accepteula -h")
    elif [[ "$special_arg" == "no-args" ]]; then
        # Tools that show info without args
        test_commands=("" "--help" "-h" "--version")
    elif [[ -n "$special_arg" ]]; then
        # Specific argument provided
        test_commands=("$special_arg" "--version" "--help" "" "-h")
    else
        # Standard test patterns
        test_commands=("--version" "-V" "--help" "-h" "help" "" "-?" "/?")
    fi
    
    for cmd in "${test_commands[@]}"; do
        # Capture both stdout and stderr, with timeout
        local cmd_output
        local exit_code
        
        # Run command and capture output (prevent GUI apps from opening)
        if cmd_output=$(DISPLAY="" timeout 10s "$exe_path" $cmd </dev/null 2>&1); then
            exit_code=$?
            
            # Check if output indicates success (tool is responding with useful information)
            if [[ $exit_code -eq 0 ]] || 
               [[ "$cmd_output" == *"version"* ]] || [[ "$cmd_output" == *"Version"* ]] ||
               [[ "$cmd_output" == *"usage"* ]] || [[ "$cmd_output" == *"Usage"* ]] ||
               [[ "$cmd_output" == *"help"* ]] || [[ "$cmd_output" == *"Help"* ]] ||
               [[ "$cmd_output" == *"Copyright"* ]] || [[ "$cmd_output" == *"copyright"* ]] ||
               [[ "$cmd_output" == *"command"* ]] || [[ "$cmd_output" == *"Command"* ]] ||
               [[ "$cmd_output" == *"option"* ]] || [[ "$cmd_output" == *"Option"* ]] ||
               [[ "$cmd_output" == *"argument"* ]] || [[ "$cmd_output" == *"Argument"* ]] ||
               [[ "$cmd_output" == *"Tiny C Compiler"* ]] || [[ "$cmd_output" == *"tiny_impdef"* ]] ||
               [[ "$cmd_output" == *"blocked-file-util"* ]] || [[ "$cmd_output" == *"hprof-conv"* ]] ||
               [[ "$cmd_output" == *"Android"* ]] || [[ "$cmd_output" == *"Apache License"* ]] ||
               [[ "$cmd_output" == *"documentation file"* ]] || [[ "$cmd_output" == *"Commands:"* ]] ||
               [[ "$cmd_output" == *"General options:"* ]] || [[ "$cmd_output" == *"create export definition"* ]]; then
                test_result="WORKING"
                ((WORKING_TOOLS++))
                WORKING_BY_CATEGORY["$category"]=$((${WORKING_BY_CATEGORY["$category"]:-0} + 1))
                break
            fi
        else
            exit_code=$?
            cmd_output="Timeout or execution error"
        fi
    done
    
    # If still broken, try to get error details
    if [[ "$test_result" == "BROKEN" ]]; then
        # Capture first line of last error for brevity
        if [[ -n "$cmd_output" ]]; then
            error_msg=$(echo "$cmd_output" | head -1 | cut -c1-100)
        else
            error_msg="No response to standard flags"
        fi
        ((BROKEN_TOOLS++))
        BROKEN_BY_CATEGORY["$category"]=$((${BROKEN_BY_CATEGORY["$category"]:-0} + 1))
    fi
    
    log_result "$exe_name" "$category" "$rel_path" "$test_result" "$error_msg"
}

# Log test result
log_result() {
    local tool_name="$1"
    local category="$2" 
    local path="$3"
    local result="$4"
    local error="$5"
    
    # Write to temp log for processing
    echo "$result|$category|$tool_name|$path|$error" >> "$TEMP_LOG"
    
    # Show immediate feedback for broken tools only
    if [[ "$result" == "BROKEN" ]]; then
        echo -e "   ❌ ${RED}$tool_name${NC} ($category) - $error"
    elif [[ "$result" == "MISSING" ]]; then
        echo -e "   ❓ ${YELLOW}$tool_name${NC} ($category) - $error"
    fi
}

# Generate comprehensive markdown report
generate_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local success_rate=$(( (WORKING_TOOLS * 100) / TOTAL_TOOLS ))
    
    cat > "$REPORT_FILE" << EOF
# PORTX Tool Testing Report

**Generated:** $timestamp  
**PORTX Root:** $PORTX_ROOT

## 📊 Summary Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Tools** | $TOTAL_TOOLS | 100% |
| **Working Tools** | $WORKING_TOOLS | ${success_rate}% |
| **Broken Tools** | $BROKEN_TOOLS | $(( (BROKEN_TOOLS * 100) / TOTAL_TOOLS ))% |
| **Missing Tools** | $MISSING_TOOLS | $(( (MISSING_TOOLS * 100) / TOTAL_TOOLS ))% |

**Success Rate:** ${success_rate}%

$(if (( success_rate >= 95 )); then
    echo "✅ **Status: Excellent** - Success rate above 95%. Minor issues only."
elif (( success_rate >= 85 )); then
    echo "⚠️ **Status: Good** - Success rate above 85%. Focus on specific broken tools."
elif (( success_rate >= 70 )); then
    echo "⚠️ **Status: Moderate Issues** - Success rate below 85%. Several packages need attention."
else
    echo "🚨 **Status: Major Issues** - Success rate below 70%. Significant problems detected."
fi)

## 📂 Results by Category

EOF

    # Add category breakdown
    echo "### Working Tools by Category" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    for category in $(printf '%s\n' "${!WORKING_BY_CATEGORY[@]}" | sort); do
        echo "- **$category:** ${WORKING_BY_CATEGORY[$category]} tools" >> "$REPORT_FILE"
    done
    echo "" >> "$REPORT_FILE"
    
    # Broken tools section
    if (( BROKEN_TOOLS > 0 )); then
        echo "### 🚨 Broken Tools by Category" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        for category in $(printf '%s\n' "${!BROKEN_BY_CATEGORY[@]}" | sort); do
            echo "#### $category (${BROKEN_BY_CATEGORY[$category]} broken)" >> "$REPORT_FILE"
            echo "" >> "$REPORT_FILE"
            
            # List broken tools in this category
            while IFS='|' read -r result cat tool path error; do
                if [[ "$result" == "BROKEN" && "$cat" == "$category" ]]; then
                    echo "- **$tool** - $error" >> "$REPORT_FILE"
                fi
            done < "$TEMP_LOG"
            echo "" >> "$REPORT_FILE"
        done
    fi
    
    # Missing tools section  
    if (( MISSING_TOOLS > 0 )); then
        echo "### ❓ Missing Tools" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        while IFS='|' read -r result cat tool path error; do
            if [[ "$result" == "MISSING" ]]; then
                echo "- **$tool** ($cat) - $error" >> "$REPORT_FILE"
            fi
        done < "$TEMP_LOG"
        echo "" >> "$REPORT_FILE"
    fi
    
    # Analysis section
    echo "## 🔍 Analysis & Recommendations" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Check for critical broken tools
    local critical_tools=("git" "bash" "sh" "curl" "ssh" "make" "gcc" "grep" "sed" "awk")
    local critical_broken=""
    
    for critical in "${critical_tools[@]}"; do
        if grep -q "BROKEN|.*|$critical|" "$TEMP_LOG"; then
            critical_broken="$critical_broken $critical"
        fi
    done
    
    if [[ -n "$critical_broken" ]]; then
        echo "🚨 **Critical Priority:** Fix these essential tools:$critical_broken" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
    
    echo "### Recommendations" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "1. **Review broken tools list** above for specific error messages" >> "$REPORT_FILE"
    echo "2. **Check package documentation** in \`bin-tools/*/package-manual.md\`" >> "$REPORT_FILE"
    echo "3. **Verify dependencies** - especially for MSYS2 tools (DLL files)" >> "$REPORT_FILE"
    echo "4. **Consider alternatives** from working categories" >> "$REPORT_FILE"
    echo "5. **For SysInternals tools** - some require \`-accepteula\` flag on first run" >> "$REPORT_FILE"
    echo "6. **For ClamAV tools** - may need configuration files" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

# Generate broken tools list for easy processing
generate_broken_list() {
    echo "# PORTX Broken Tools List - $(date)" > "$BROKEN_LIST"
    echo "# Format: category|tool_name|relative_path|error_message" >> "$BROKEN_LIST"
    echo "" >> "$BROKEN_LIST"
    
    while IFS='|' read -r result cat tool path error; do
        if [[ "$result" == "BROKEN" ]]; then
            echo "$cat|$tool|$path|$error" >> "$BROKEN_LIST"
        fi
    done < "$TEMP_LOG"
}

# Main execution
main() {
    show_header
    
    echo -e "🎯 Testing all PORTX executables..."
    echo -e "📁 PORTX Root: ${CYAN}$PORTX_ROOT${NC}"
    echo -e "📏 Scan Depth: ${CYAN}4 levels${NC}"
    echo
    
    # Create temp log
    : > "$TEMP_LOG"
    
    # Scan focused directories only: /bin and /packages
    echo -e "${GREEN}Phase 1: PORTX Core Tools${NC}"
    scan_executables "$PORTX_ROOT/bin" "PORTX-Core" 1
    
    echo -e "\n${GREEN}Phase 2: Professional Packages${NC}"
    # Scan packages with package structure (each subdirectory is a package)
    if [[ -d "$PORTX_ROOT/packages" ]]; then
        for package_dir in "$PORTX_ROOT/packages"/*; do
            if [[ -d "$package_dir" ]]; then
                local package_name=$(basename "$package_dir")
                scan_executables "$package_dir" "Package-$package_name" 4  # Depth 4 for packages
            fi
        done
    fi
    
    echo -e "\n${CYAN}📊 Final Results:${NC}"
    echo -e "   Total: $TOTAL_TOOLS tools"
    echo -e "   ✅ Working: ${GREEN}$WORKING_TOOLS${NC}"
    echo -e "   ❌ Broken: ${RED}$BROKEN_TOOLS${NC}" 
    echo -e "   ❓ Missing: ${YELLOW}$MISSING_TOOLS${NC}"
    
    local success_rate=$(( (WORKING_TOOLS * 100) / TOTAL_TOOLS ))
    echo -e "   🎯 Success Rate: ${GREEN}${success_rate}%${NC}"
    echo
    
    # Generate reports
    echo -e "📝 Generating reports..."
    generate_report
    generate_broken_list
    
    # Show completion
    echo -e "${GREEN}✅ Testing complete!${NC}"
    echo
    echo -e "📄 Reports generated:"
    echo -e "   📋 Full report: ${CYAN}$REPORT_FILE${NC}"
    echo -e "   📝 Broken tools: ${CYAN}$BROKEN_LIST${NC}"
    echo
    
    # Clean up
    rm -f "$TEMP_LOG"
    
    # Show quick summary
    if (( BROKEN_TOOLS > 0 )); then
        echo -e "${YELLOW}🔧 Next steps:${NC}"
        echo -e "   1. Review the full report for detailed analysis"
        echo -e "   2. Check broken tools list for specific issues" 
        echo -e "   3. Run individual tool tests for diagnosis"
        echo
    fi
}

# Run main function
main "$@"