#!/usr/bin/env bats

# Comprehensive Analyzer Validation Tests
# Tests all analyzers against test files to ensure meaningful data output
# Based on validation rules defined in package.json

# Path configurations
TEST_FILES_DIR="c:/Users/damian/.claude/hooks/analyze-hook/test/files"
ANALYZER_SCRIPT="c:/Users/damian/.claude/hooks/analyze-hook/test/analyzer_test_adapter.sh"
GFW="/c/App/Git/bin"

# Load test helper functions
load 'test_helper'

setup() {
    # Ensure test files directory exists
    [ -d "$TEST_FILES_DIR" ]
    
    # Ensure analyzer script exists
    [ -f "$ANALYZER_SCRIPT" ]
    
    # Set up temporary directory for test outputs
    export BATS_TEST_TMPDIR="${BATS_TMPDIR}/analyzer_tests"
    mkdir -p "$BATS_TEST_TMPDIR"
}

teardown() {
    # Clean up temporary files
    rm -rf "$BATS_TEST_TMPDIR"
}

# Helper function to run analyzer and capture output
run_analyzer() {
    local analyzer="$1"
    local file="$2"
    local output_file="${BATS_TEST_TMPDIR}/output_${analyzer}_$(basename "$file").json"
    
    python3 "$ANALYZER_SCRIPT" --analyzer="$analyzer" --file="$file" > "$output_file" 2>&1
    echo "$output_file"
}

# Helper function to validate JSON structure
validate_json_structure() {
    local json_file="$1"
    
    # Check if file exists and is not empty
    [ -f "$json_file" ] || return 1
    [ -s "$json_file" ] || return 1
    
    # Validate JSON syntax
    cat "$json_file" | $GFW/gojq empty || return 1
    
    return 0
}

# Helper function to check for failure patterns
check_failure_patterns() {
    local output="$1"
    local failure_patterns=("no parser" "not found" "unavailable" "failed to analyze" 
                           "empty result" "timeout" "error:" "exception:" "null" "undefined")
    
    for pattern in "${failure_patterns[@]}"; do
        if grep -qi "$pattern" <<< "$output"; then
            return 1
        fi
    done
    return 0
}

# Helper function to validate required fields for ctags
validate_ctags_output() {
    local json_file="$1"
    local required_fields=("_type" "name" "path" "language" "line" "kind")
    
    # Check if JSON contains array of entries
    local entry_count=$(cat "$json_file" | $GFW/gojq 'length' 2>/dev/null)
    [ "$entry_count" -gt 0 ] || return 1
    
    # Validate required fields in first entry
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".[0].$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    return 0
}

# Helper function to validate required fields for scc
validate_scc_output() {
    local json_file="$1"
    local required_fields=("analyzer" "file" "language" "metrics")
    local metrics_fields=("total_lines" "code_lines" "total_complexity")
    
    # Validate top-level required fields
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    # Validate metrics sub-fields
    for field in "${metrics_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".metrics.$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    return 0
}

# Helper function to validate required fields for treesitter
validate_treesitter_output() {
    local json_file="$1"
    local required_fields=("analyzer" "language" "file" "ast_available")
    local code_elements=("functions" "variable_assignments")
    
    # Validate required fields
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    # Check if at least one code element is present
    local has_elements=false
    for element in "${code_elements[@]}"; do
        local element_count=$(cat "$json_file" | $GFW/gojq ".$element | length" 2>/dev/null)
        if [ "$element_count" -gt 0 ] 2>/dev/null; then
            has_elements=true
            break
        fi
    done
    
    [ "$has_elements" = true ] || return 1
    return 0
}

# Helper function to validate required fields for ast_grep
validate_ast_grep_output() {
    local json_file="$1"
    local required_fields=("analyzer" "language" "file" "analysis_summary")
    local summary_fields=("patterns_tried" "successful_patterns")
    
    # Validate required fields
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    # Validate summary fields
    for field in "${summary_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".analysis_summary.$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    return 0
}

# Helper function to validate required fields for shellcheck
validate_shellcheck_output() {
    local json_file="$1"
    local required_fields=("analyzer" "file" "status")
    local valid_statuses=("analyzed" "no_issues" "issues_found")
    
    # Validate required fields
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    # Validate status field contains valid value
    local status=$(cat "$json_file" | $GFW/gojq -r ".status" 2>/dev/null)
    for valid_status in "${valid_statuses[@]}"; do
        [ "$status" = "$valid_status" ] && return 0
    done
    
    return 1
}

# Helper function to validate required fields for dependency analyzer
validate_dependency_output() {
    local json_file="$1"
    local required_fields=("analyzer" "file" "language" "dependencies")
    local dependency_fields=("imports_in_this_file" "resolved_dependencies")
    
    # Validate required fields
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    # Validate dependency fields
    for field in "${dependency_fields[@]}"; do
        local field_exists=$(cat "$json_file" | $GFW/gojq ".dependencies | has(\"$field\")" 2>/dev/null)
        [ "$field_exists" = "true" ] || return 1
    done
    
    return 0
}

# Helper function to validate required fields for dependency_reverse analyzer
validate_dependency_reverse_output() {
    local json_file="$1"
    local required_fields=("analyzer" "file" "language" "reverse_analysis")
    local analysis_fields=("importers" "referrers" "total_reverse_deps")
    
    # Validate required fields
    for field in "${required_fields[@]}"; do
        local field_value=$(cat "$json_file" | $GFW/gojq ".$field" 2>/dev/null)
        [ "$field_value" != "null" ] && [ -n "$field_value" ] || return 1
    done
    
    # Validate analysis fields
    for field in "${analysis_fields[@]}"; do
        local field_exists=$(cat "$json_file" | $GFW/gojq ".reverse_analysis | has(\"$field\")" 2>/dev/null)
        [ "$field_exists" = "true" ] || return 1
    done
    
    return 0
}

# Test ctags analyzer on Java file
@test "ctags analyzer returns meaningful data for Java file" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local output_file=$(run_analyzer "ctags" "$test_file")
    
    # Validate JSON structure
    validate_json_structure "$output_file"
    
    # Check for failure patterns
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    
    # Validate ctags-specific output structure
    validate_ctags_output "$output_file"
}

# Test ctags analyzer on C++ file
@test "ctags analyzer returns meaningful data for C++ file" {
    local test_file="$TEST_FILES_DIR/DatabaseConnection.cpp"
    local output_file=$(run_analyzer "ctags" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ctags_output "$output_file"
}

# Test ctags analyzer on Python file
@test "ctags analyzer returns meaningful data for Python file" {
    local test_file="$TEST_FILES_DIR/json_helper.py"
    local output_file=$(run_analyzer "ctags" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ctags_output "$output_file"
}

# Test ctags analyzer on JavaScript file
@test "ctags analyzer returns meaningful data for JavaScript file" {
    local test_file="$TEST_FILES_DIR/tests.js"
    local output_file=$(run_analyzer "ctags" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ctags_output "$output_file"
}

# Test ctags analyzer on C# file
@test "ctags analyzer returns meaningful data for C# file" {
    local test_file="$TEST_FILES_DIR/UserService.cs"
    local output_file=$(run_analyzer "ctags" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ctags_output "$output_file"
}

# Test scc analyzer on Java file
@test "scc analyzer returns meaningful data for Java file" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local output_file=$(run_analyzer "scc" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_scc_output "$output_file"
}

# Test scc analyzer on C++ file
@test "scc analyzer returns meaningful data for C++ file" {
    local test_file="$TEST_FILES_DIR/DatabaseConnection.cpp"
    local output_file=$(run_analyzer "scc" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_scc_output "$output_file"
}

# Test scc analyzer on Python file
@test "scc analyzer returns meaningful data for Python file" {
    local test_file="$TEST_FILES_DIR/json_helper.py"
    local output_file=$(run_analyzer "scc" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_scc_output "$output_file"
}

# Test treesitter analyzer on Java file
@test "treesitter analyzer returns meaningful data for Java file" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local output_file=$(run_analyzer "treesitter" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_treesitter_output "$output_file"
}

# Test treesitter analyzer on Python file
@test "treesitter analyzer returns meaningful data for Python file" {
    local test_file="$TEST_FILES_DIR/json_helper.py"
    local output_file=$(run_analyzer "treesitter" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_treesitter_output "$output_file"
}

# Test treesitter analyzer on JavaScript file
@test "treesitter analyzer returns meaningful data for JavaScript file" {
    local test_file="$TEST_FILES_DIR/tests.js"
    local output_file=$(run_analyzer "treesitter" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_treesitter_output "$output_file"
}

# Test ast_grep analyzer on Java file
@test "ast_grep analyzer returns meaningful data for Java file" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local output_file=$(run_analyzer "ast_grep" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ast_grep_output "$output_file"
}

# Test ast_grep analyzer on Python file
@test "ast_grep analyzer returns meaningful data for Python file" {
    local test_file="$TEST_FILES_DIR/json_helper.py"
    local output_file=$(run_analyzer "ast_grep" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ast_grep_output "$output_file"
}

# Test ast_grep analyzer on JavaScript file
@test "ast_grep analyzer returns meaningful data for JavaScript file" {
    local test_file="$TEST_FILES_DIR/tests.js"
    local output_file=$(run_analyzer "ast_grep" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_ast_grep_output "$output_file"
}

# Test shellcheck analyzer on Bash file
@test "shellcheck analyzer returns meaningful data for Bash file" {
    local test_file="$TEST_FILES_DIR/execute_tests.sh"
    local output_file=$(run_analyzer "shellcheck" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_shellcheck_output "$output_file"
}

# Test dependency analyzer on Java file
@test "dependency analyzer returns meaningful data for Java file" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local output_file=$(run_analyzer "dependency" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_dependency_output "$output_file"
}

# Test dependency analyzer on Python file
@test "dependency analyzer returns meaningful data for Python file" {
    local test_file="$TEST_FILES_DIR/json_helper.py"
    local output_file=$(run_analyzer "dependency" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_dependency_output "$output_file"
}

# Test dependency analyzer on JavaScript file
@test "dependency analyzer returns meaningful data for JavaScript file" {
    local test_file="$TEST_FILES_DIR/tests.js"
    local output_file=$(run_analyzer "dependency" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_dependency_output "$output_file"
}

# Test dependency analyzer on C# file
@test "dependency analyzer returns meaningful data for C# file" {
    local test_file="$TEST_FILES_DIR/UserService.cs"
    local output_file=$(run_analyzer "dependency" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_dependency_output "$output_file"
}

# Test dependency_reverse analyzer on Java file
@test "dependency_reverse analyzer returns meaningful data for Java file" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local output_file=$(run_analyzer "dependency_reverse" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_dependency_reverse_output "$output_file"
}

# Test dependency_reverse analyzer on Python file
@test "dependency_reverse analyzer returns meaningful data for Python file" {
    local test_file="$TEST_FILES_DIR/json_helper.py"
    local output_file=$(run_analyzer "dependency_reverse" "$test_file")
    
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
    validate_dependency_reverse_output "$output_file"
}

# Test YAML/JSON file analysis
@test "analyzers handle YAML configuration file appropriately" {
    local test_file="$TEST_FILES_DIR/config.yaml"
    
    # Test with appropriate analyzers (not all analyzers support YAML)
    local output_file=$(run_analyzer "dependency" "$test_file")
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
}

# Test JSON file analysis
@test "analyzers handle JSON package file appropriately" {
    local test_file="$TEST_FILES_DIR/package.json"
    
    # Test with dependency analyzer which should handle JSON
    local output_file=$(run_analyzer "dependency" "$test_file")
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
}

# Test Helm chart analysis
@test "analyzers handle Helm chart YAML files appropriately" {
    local test_file="$TEST_FILES_DIR/chart/Chart.yaml"
    
    # Test with dependency analyzer which should handle YAML
    local output_file=$(run_analyzer "dependency" "$test_file")
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
}

# Test Helm values analysis
@test "analyzers handle Helm values YAML files appropriately" {
    local test_file="$TEST_FILES_DIR/chart/values.yaml"
    
    # Test with dependency analyzer which should handle YAML
    local output_file=$(run_analyzer "dependency" "$test_file")
    validate_json_structure "$output_file"
    local content=$(cat "$output_file")
    check_failure_patterns "$content"
}

# Cross-reference validation test
@test "cross-references between files are properly detected" {
    # Test that dependency analyzer detects cross-references
    local java_output=$(run_analyzer "dependency" "$TEST_FILES_DIR/TestService.java")
    local python_output=$(run_analyzer "dependency" "$TEST_FILES_DIR/json_helper.py")
    
    # Validate both outputs
    validate_json_structure "$java_output"
    validate_json_structure "$python_output"
    
    # Check that dependencies are detected (should contain references to other files)
    local java_deps_count=$(cat "$java_output" | $GFW/gojq '.dependencies.imports_in_this_file | length' 2>/dev/null)
    local python_deps_count=$(cat "$python_output" | $GFW/gojq '.dependencies.imports_in_this_file | length' 2>/dev/null)
    
    # At least one file should have detected dependencies
    [ "$java_deps_count" -gt 0 ] || [ "$python_deps_count" -gt 0 ]
}

# Performance validation test
@test "analyzers complete within reasonable time limits" {
    local test_file="$TEST_FILES_DIR/TestService.java"
    local start_time=$(date +%s)
    
    # Run multiple analyzers and ensure they complete within timeout
    local ctags_output=$(run_analyzer "ctags" "$test_file")
    local scc_output=$(run_analyzer "scc" "$test_file")
    local treesitter_output=$(run_analyzer "treesitter" "$test_file")
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Should complete within 30 seconds (reasonable timeout)
    [ "$duration" -lt 30 ]
    
    # All outputs should be valid
    validate_json_structure "$ctags_output"
    validate_json_structure "$scc_output"
    validate_json_structure "$treesitter_output"
}