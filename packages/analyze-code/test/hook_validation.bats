#!/usr/bin/env bats

# HOOK VALIDATION TESTS
# Direct testing of analyze-hook.sh functionality

setup() {
    export BATS_TEST_DIRNAME="$(cd "$(dirname "${BATS_TEST_FILENAME}")" && pwd)"
    export HOOK_SCRIPT="$BATS_TEST_DIRNAME/../analyze-hook.sh"
    export TEST_FILES_DIR="$BATS_TEST_DIRNAME/files"
}

# Helper function to run hook with JSON input
run_hook_with_json() {
    local file_path="$1"
    local action="${2:-inspect}"
    
    echo "{\"params\": {\"file_path\": \"$file_path\", \"claude_cache_skip\": true}}" | "$HOOK_SCRIPT" "$action" 2>&1
}

# Helper function to run hook with skip parameters
run_hook_with_skip() {
    local file_path="$1"
    local action="${2:-inspect}"
    local hooks_skip="${3:-false}"
    local cache_skip="${4:-true}"
    
    echo "{\"params\": {\"file_path\": \"$file_path\", \"claude_hooks_skip\": $hooks_skip, \"claude_cache_skip\": $cache_skip}}" | "$HOOK_SCRIPT" "$action" 2>&1
}

@test "Hook exists and is executable" {
    [ -f "$HOOK_SCRIPT" ]
    [ -x "$HOOK_SCRIPT" ]
}

@test "Java file analysis produces meaningful output" {
    local java_file="$TEST_FILES_DIR/TestService.java"
    [ -f "$java_file" ]
    
    run run_hook_with_json "$java_file"
    
    # Should complete successfully (exit code 0 or 2 for analysis output)
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain analysis insights
    [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* ]]
    
    # Should contain actual Java analysis data
    [[ "$output" == *"TestService"* ]]
    [[ "$output" == *"java"* || "$output" == *"Java"* ]]
}

@test "C++ file analysis produces meaningful output" {
    local cpp_file="$TEST_FILES_DIR/DatabaseConnection.cpp"
    [ -f "$cpp_file" ]
    
    run run_hook_with_json "$cpp_file"
    
    # Should complete successfully 
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain analysis insights
    [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* ]]
    
    # Should contain C++ specific content
    [[ "$output" == *"DatabaseConnection"* ]]
}

@test "Python file analysis produces meaningful output" {
    local py_file="$TEST_FILES_DIR/json_helper.py"
    [ -f "$py_file" ]
    
    run run_hook_with_json "$py_file"
    
    # Should complete successfully
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain analysis insights
    [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* ]]
    
    # Should contain Python specific content
    [[ "$output" == *"JsonHelper"* || "$output" == *"python"* || "$output" == *"Python"* ]]
}

@test "JavaScript file analysis produces meaningful output" {
    local js_file="$TEST_FILES_DIR/tests.js"
    [ -f "$js_file" ]
    
    run run_hook_with_json "$js_file"
    
    # Should complete successfully
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain analysis insights
    [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* ]]
    
    # Should contain JavaScript specific content
    [[ "$output" == *"function"* || "$output" == *"javascript"* || "$output" == *"JavaScript"* ]]
}

@test "YAML file analysis produces meaningful output" {
    local yaml_file="$TEST_FILES_DIR/config.yaml"
    [ -f "$yaml_file" ]
    
    run run_hook_with_json "$yaml_file"
    
    # Should complete successfully
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain either analysis or configuration data
    [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* || "$output" == *"config"* ]]
}

@test "Helm Chart analysis produces meaningful output" {
    local chart_file="$TEST_FILES_DIR/chart/Chart.yaml"
    [ -f "$chart_file" ]
    
    run run_hook_with_json "$chart_file"
    
    # Should complete successfully
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain Helm or chart related content
    [[ "$output" == *"chart"* || "$output" == *"Chart"* || "$output" == *"helm"* || "$output" == *"Helm"* ]]
}

@test "Hook provides file content with line numbers" {
    local java_file="$TEST_FILES_DIR/TestService.java"
    
    run run_hook_with_json "$java_file"
    
    # Should include file content section
    [[ "$output" == *"FILE CONTENT"* ]]
    
    # Should have line numbers (bat format with ─────)
    [[ "$output" == *"─────"* ]]
    
    # Should contain actual file content
    [[ "$output" == *"public class TestService"* ]]
}

@test "Hook provides Claude workflow instructions" {
    local java_file="$TEST_FILES_DIR/TestService.java"
    
    run run_hook_with_json "$java_file"
    
    # Should include workflow instructions
    [[ "$output" == *"CLAUDE WORKFLOW"* ]]
    
    # Should mention bat command
    [[ "$output" == *"bat"* ]]
}

@test "Non-existent file handling" {
    local fake_file="/nonexistent/file.java"
    
    run run_hook_with_json "$fake_file"
    
    # Should handle gracefully with exit code 0 or 2 (hook sends to stderr but doesn't fail)
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain error message
    [[ "$output" == *"ERROR"* || "$output" == *"not found"* || "$output" == *"not readable"* ]]
}

@test "Multiple file types produce JSON analysis" {
    local files=(
        "$TEST_FILES_DIR/TestService.java"
        "$TEST_FILES_DIR/json_helper.py" 
        "$TEST_FILES_DIR/tests.js"
        "$TEST_FILES_DIR/config.yaml"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            run run_hook_with_json "$file"
            
            # Each file should produce some meaningful output
            [[ $status -eq 0 || $status -eq 2 ]]
            [[ ${#output} -gt 100 ]]  # Should have substantial output
            
            # Should contain analysis or file content
            [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* || "$output" == *"FILE CONTENT"* ]]
        fi
    done
}

@test "CLAUDE_HOOKS_SKIP parameter bypasses analysis" {
    local java_file="$TEST_FILES_DIR/TestService.java"
    [ -f "$java_file" ]
    
    # Test with hooks_skip=true - should bypass analysis
    run run_hook_with_skip "$java_file" "inspect" "true" "true"
    
    # Should exit with code 2 (bypass exit code)
    [[ $status -eq 2 ]]
    
    # Should not contain analysis insights (bypassed)
    [[ "$output" != *"DEEP ANALYSIS INSIGHTS"* ]]
}

@test "CLAUDE_CACHE_SKIP parameter forces fresh analysis" {
    local java_file="$TEST_FILES_DIR/TestService.java"
    [ -f "$java_file" ]
    
    # Test with cache_skip=true, hooks_skip=false - forces fresh analysis
    run run_hook_with_skip "$java_file" "inspect" "false" "true"
    
    # Should complete successfully
    [[ $status -eq 0 || $status -eq 2 ]]
    
    # Should contain analysis results (fresh analysis forced)
    [[ "$output" == *"DEEP ANALYSIS INSIGHTS"* || "$output" == *"FILE CONTENT"* ]]
}