#!/bin/bash
# =============================================================================
# RUFF ANALYZER MODULE
# Fast Python linter and code formatter using Ruff
# =============================================================================

# Tool configuration - use path from settings.sh
RUFF_TOOL="$RUFF_PATH"

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_ruff")

analyze_ruff() {
    # Check if ruff is available
    if [[ -z "$RUFF_TOOL" ]]; then
        echo '{"tool":"ruff","status":"unavailable","reason":"tool_not_found"}'
        return
    fi
    
    # Only analyze Python files
    if [[ ! "$FILE_EXT" =~ ^(py|pyi)$ ]]; then
        echo '{"tool":"ruff","status":"skipped","reason":"not_python","file_ext":"'"$FILE_EXT"'"}'
        return
    fi
    
    # Run ruff check with JSON output for comprehensive linting
    local result
    result=$(timeout "$ANALYZER_TIMEOUT" "$RUFF_TOOL" check --output-format=json "$FILE_PATH" 2>/dev/null)
    local exit_code=$?
    
    # ruff check returns:
    # 0 = no issues found
    # 1 = issues found
    # 2 = error/invalid usage
    
    if [[ $exit_code -eq 0 ]]; then
        # No issues found
        echo '{"tool":"ruff","status":"passed","issues":0,"file":"'"$FILE_PATH"'"}'
    elif [[ $exit_code -eq 1 && -n "$result" ]]; then
        # Issues found - parse JSON output
        local issue_count
        issue_count=$(echo "$result" | "$GOJQ_PATH" 'length' 2>/dev/null || echo "0")
        
        if [[ "$issue_count" -gt 0 ]]; then
            # Enhanced output with detailed issues
            local enhanced_result
            enhanced_result=$(echo "$result" | "$GOJQ_PATH" '. as $issues | {"tool":"ruff","status":"issues_found","issue_count":($issues | length),"file":"'"$FILE_PATH"'","issues":$issues}' 2>/dev/null)
            
            if [[ -n "$enhanced_result" ]]; then
                echo "$enhanced_result"
            else
                # Fallback if gojq fails
                echo '{"tool":"ruff","status":"issues_found","issue_count":'$issue_count',"file":"'"$FILE_PATH"'","raw_output":"'"${result//\"/\\\"}"'"}'
            fi
        else
            echo '{"tool":"ruff","status":"passed","issues":0,"file":"'"$FILE_PATH"'"}'
        fi
    elif [[ $exit_code -eq 1 && -z "$result" ]]; then
        # Exit code 1 but no output - likely means no issues
        echo '{"tool":"ruff","status":"passed","issues":0,"file":"'"$FILE_PATH"'"}'
    else
        # Error running ruff
        local error_msg="${result:-unknown_error}"
        echo '{"tool":"ruff","status":"analysis_failed","reason":"tool_error","error":"'"${error_msg//\"/\\\"}"'","exit_code":'$exit_code',"file":"'"$FILE_PATH"'"}'
    fi
}