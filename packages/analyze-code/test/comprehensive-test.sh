#!/bin/bash
# =============================================================================
# COMPREHENSIVE ANALYZE-CODE TESTING SCRIPT
# Tests analyze-code tool vs original hook across multiple file formats
# =============================================================================

# Test configuration
TEST_DIR="c:/Work/Git"
NEW_ANALYZER="c:/App/Git/home/portx/packages/analyze-code/analyze-code.sh"
OLD_HOOK="c:/Users/damian/.claude/hooks/analyze-hook/analyze-hook.sh"
RESULTS_DIR="c:/App/Git/home/portx/packages/analyze-code/test/results"
GOJQ="/c/App/Git/home/portx/packages/gojq/gojq.exe"

# Create results directory
mkdir -p "$RESULTS_DIR"

# Test result files
NEW_RESULTS="$RESULTS_DIR/new_analyzer_results.txt"
OLD_RESULTS="$RESULTS_DIR/old_hook_results.txt"
COMPARISON_REPORT="$RESULTS_DIR/comparison_report.txt"

# Clear previous results
> "$NEW_RESULTS"
> "$OLD_RESULTS"
> "$COMPARISON_REPORT"

echo "======================================="
echo "COMPREHENSIVE ANALYZE-CODE TESTING"
echo "======================================="
echo "Test Directory: $TEST_DIR"
echo "New Analyzer: $NEW_ANALYZER"
echo "Original Hook: $OLD_HOOK"
echo "Results Directory: $RESULTS_DIR"
echo "======================================="
echo

# Function to extract analyzer counts from JSON
extract_counts() {
    local json_output="$1"
    local expected=$(echo "$json_output" | $GOJQ -r '.analyzers | length // 0' 2>/dev/null || echo "0")
    local succeeded=$(echo "$json_output" | $GOJQ -r '[.analyzers[] | select(.status == "success")] | length // 0' 2>/dev/null || echo "0")
    local failed=$(echo "$json_output" | $GOJQ -r '[.analyzers[] | select(.status == "error")] | length // 0' 2>/dev/null || echo "0")
    echo "$expected,$succeeded,$failed"
}

# Function to test new analyzer
test_new_analyzer() {
    local file_path="$1"
    local mode="$2"
    
    echo "NEW_ANALYZER|$mode|$file_path|" >> "$NEW_RESULTS"
    
    # Test both inspect and verify modes
    local output
    output=$("$NEW_ANALYZER" "$file_path" "$mode" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && -n "$output" ]]; then
        local counts=$(extract_counts "$output")
        echo "NEW_ANALYZER|$mode|$file_path|SUCCESS|$counts|$output" >> "$NEW_RESULTS"
    else
        echo "NEW_ANALYZER|$mode|$file_path|FAILED|0,0,0|Exit: $exit_code, Output: $output" >> "$NEW_RESULTS"
    fi
}

# Function to test original hook  
test_old_hook() {
    local file_path="$1"
    local mode="$2"
    
    echo "OLD_HOOK|$mode|$file_path|" >> "$OLD_RESULTS"
    
    # Create hook input
    local hook_input='{"tool": "Read", "params": {"file_path": "'$file_path'"}}'
    
    local output
    output=$(echo "$hook_input" | "$OLD_HOOK" "$mode" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 && -n "$output" ]]; then
        # Count analyzer results from hook output
        local analyzer_count=$(echo "$output" | grep -c "analyzer.*:" || echo "0")
        echo "OLD_HOOK|$mode|$file_path|SUCCESS|$analyzer_count,?,?|$output" >> "$OLD_RESULTS"
    else
        echo "OLD_HOOK|$mode|$file_path|FAILED|0,0,0|Exit: $exit_code, Output: $output" >> "$OLD_RESULTS"
    fi
}

# Discover test files
echo "Discovering test files..."
declare -a TEST_FILES
readarray -t TEST_FILES < <(find "$TEST_DIR" -type f \( \
    -name "*.py" -o -name "*.java" -o -name "*.js" -o -name "*.ts" -o \
    -name "*.jsx" -o -name "*.tsx" -o -name "*.c" -o -name "*.cpp" -o \
    -name "*.h" -o -name "*.cs" -o -name "*.rs" -o -name "*.go" -o \
    -name "*.sh" -o -name "*.bash" -o -name "*.yaml" -o -name "*.yml" -o \
    -name "*.json" -o -name "*.xml" -o -name "*.toml" -o -name "*.tf" -o \
    -name "*.sql" -o -name "*Dockerfile*" -o -name "package.json" -o \
    -name "Cargo.toml" -o -name "*.gradle" \) | head -20)

echo "Found ${#TEST_FILES[@]} test files"

# Test each file with both tools
total_files=${#TEST_FILES[@]}
current=0

for file_path in "${TEST_FILES[@]}"; do
    current=$((current + 1))
    echo "[$current/$total_files] Testing: $file_path"
    
    # Test both modes with new analyzer
    test_new_analyzer "$file_path" "inspect"
    test_new_analyzer "$file_path" "verify" 
    
    # Test both modes with old hook
    test_old_hook "$file_path" "inspect"
    test_old_hook "$file_path" "verify"
    
    echo "  ✓ Completed tests for $file_path"
done

echo
echo "======================================="
echo "GENERATING COMPARISON REPORT"
echo "======================================="

# Generate comparison report
{
    echo "COMPREHENSIVE ANALYZE-CODE vs ORIGINAL HOOK COMPARISON REPORT"
    echo "=============================================================="
    echo "Generated: $(date)"
    echo "Total files tested: $total_files"
    echo ""
    
    echo "SUMMARY STATISTICS:"
    echo "==================="
    
    # Count successes and failures for new analyzer
    new_inspect_success=$(grep "NEW_ANALYZER|inspect|.*|SUCCESS" "$NEW_RESULTS" | wc -l)
    new_inspect_failed=$(grep "NEW_ANALYZER|inspect|.*|FAILED" "$NEW_RESULTS" | wc -l)
    new_verify_success=$(grep "NEW_ANALYZER|verify|.*|SUCCESS" "$NEW_RESULTS" | wc -l)
    new_verify_failed=$(grep "NEW_ANALYZER|verify|.*|FAILED" "$NEW_RESULTS" | wc -l)
    
    # Count successes and failures for old hook
    old_inspect_success=$(grep "OLD_HOOK|inspect|.*|SUCCESS" "$OLD_RESULTS" | wc -l)
    old_inspect_failed=$(grep "OLD_HOOK|inspect|.*|FAILED" "$OLD_RESULTS" | wc -l)
    old_verify_success=$(grep "OLD_HOOK|verify|.*|SUCCESS" "$OLD_RESULTS" | wc -l)
    old_verify_failed=$(grep "OLD_HOOK|verify|.*|FAILED" "$OLD_RESULTS" | wc -l)
    
    echo "NEW ANALYZER:"
    echo "  Inspect mode: $new_inspect_success success, $new_inspect_failed failed"
    echo "  Verify mode:  $new_verify_success success, $new_verify_failed failed"
    echo ""
    echo "ORIGINAL HOOK:"
    echo "  Inspect mode: $old_inspect_success success, $old_inspect_failed failed"  
    echo "  Verify mode:  $old_verify_success success, $old_verify_failed failed"
    echo ""
    
    echo "DETAILED COMPARISON BY FILE:"
    echo "============================"
    
    # Compare results file by file
    for file_path in "${TEST_FILES[@]}"; do
        echo ""
        echo "FILE: $file_path"
        echo "--------------------------------------------"
        
        # Extract results for this file
        new_inspect=$(grep "NEW_ANALYZER|inspect|$file_path|" "$NEW_RESULTS" || echo "NEW_ANALYZER|inspect|$file_path|NOT_FOUND")
        new_verify=$(grep "NEW_ANALYZER|verify|$file_path|" "$NEW_RESULTS" || echo "NEW_ANALYZER|verify|$file_path|NOT_FOUND")
        old_inspect=$(grep "OLD_HOOK|inspect|$file_path|" "$OLD_RESULTS" || echo "OLD_HOOK|inspect|$file_path|NOT_FOUND")
        old_verify=$(grep "OLD_HOOK|verify|$file_path|" "$OLD_RESULTS" || echo "OLD_HOOK|verify|$file_path|NOT_FOUND")
        
        echo "INSPECT MODE:"
        echo "  New: $(echo "$new_inspect" | cut -d'|' -f4-5)"
        echo "  Old: $(echo "$old_inspect" | cut -d'|' -f4-5)"
        
        echo "VERIFY MODE:"
        echo "  New: $(echo "$new_verify" | cut -d'|' -f4-5)"
        echo "  Old: $(echo "$old_verify" | cut -d'|' -f4-5)"
    done
    
} > "$COMPARISON_REPORT"

echo "✓ Testing completed!"
echo "✓ Results saved to: $RESULTS_DIR"
echo "✓ Comparison report: $COMPARISON_REPORT"
echo ""
echo "To view the full comparison report:"
echo "  cat '$COMPARISON_REPORT'"