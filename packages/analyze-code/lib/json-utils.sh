#!/bin/bash
# =============================================================================
# JSON UTILITIES - Centralized JSON Operations
# All JSON operations should use these functions for consistency
# =============================================================================

# Global JSON utilities path
JSON_GOJQ_PATH="${GOJQ_PATH:-/c/App/Git/home/portx/packages/gojq/gojq.exe}"

# =============================================================================
# CORE JSON UTILITIES
# =============================================================================

# Escape string for safe JSON inclusion using gojq
json_escape() {
    local input="$1"
    [[ -z "$input" ]] && { echo '""'; return; }
    printf '%s' "$input" | "$JSON_GOJQ_PATH" -Rs '.'
}

# Parse JSON value from string using jq path
json_get() {
    local json_string="$1"
    local path="$2"
    local default="${3:-null}"
    
    [[ -z "$json_string" ]] && { echo "$default"; return 1; }
    echo "$json_string" | "$JSON_GOJQ_PATH" -r "$path // $default" 2>/dev/null || echo "$default"
}

# Validate if string is valid JSON
json_validate() {
    local json_string="$1"
    [[ -z "$json_string" ]] && return 1
    echo "$json_string" | "$JSON_GOJQ_PATH" empty 2>/dev/null
}

# Pretty print JSON
json_pretty() {
    local json_string="$1"
    [[ -z "$json_string" ]] && return 1
    echo "$json_string" | "$JSON_GOJQ_PATH" '.'
}

# Compact JSON (remove whitespace)
json_compact() {
    local json_string="$1"
    [[ -z "$json_string" ]] && return 1
    echo "$json_string" | "$JSON_GOJQ_PATH" -c '.'
}

# Build simple JSON object with key-value pairs
# Usage: json_object "key1" "value1" "key2" "value2"
json_object() {
    local result="{"
    local first=true
    
    while [[ $# -gt 1 ]]; do
        local key="$1"
        local value="$2"
        shift 2
        
        if [[ "$first" == true ]]; then
            first=false
        else
            result+=","
        fi
        
        # Escape key and value
        local escaped_key
        local escaped_value
        escaped_key=$(json_escape "$key")
        escaped_value=$(json_escape "$value")
        
        result+="$escaped_key:$escaped_value"
    done
    
    result+="}"
    echo "$result"
}

# Legacy function names - redirect to new functions
escape_for_json() { json_escape "$@"; }

# Safe JSON merging for large objects - avoids argument length limits
json_merge_safe() {
    local base_file="$1"
    local new_json="$2"
    local analyzer_key="$3"
    
    # Create temp file for safe operation
    local temp_file="${base_file}.tmp$$"
    
    # Merge JSON using temp file approach
    echo "$new_json" | "$JSON_GOJQ_PATH" --slurpfile current "$base_file" \
        '. as $input | $current[0] + {($input.'$analyzer_key'): $input}' > "$temp_file" \
        && mv "$temp_file" "$base_file"
    
    # Always cleanup temp file
    rm -f "$temp_file" 2>/dev/null || true
}

# Cleanup temp files - call this on exit
json_cleanup() {
    local pattern="${1:-/tmp/*_$$*}"
    rm -f $pattern 2>/dev/null || true
}

# =============================================================================
# HOOK-SPECIFIC JSON UTILITIES
# =============================================================================

# Parse JSON input from stdin
parse_json_input() {
    local input
    input=$(cat)
    # Log only if LOG_FILE exists (avoid crashes in SKIP section)
    [[ -n "$LOG_FILE" ]] && echo "Raw input received: $input" >> "$LOG_FILE"
    FILE_PATH=$(echo "$input" | "$JSON_GOJQ_PATH" -r '.params.file_path // .tool_input.file_path // empty' 2>/dev/null)
    
    # Parse skip parameters - support both direct and nested in params
    CLAUDE_HOOKS_SKIP=$(echo "$input" | "$JSON_GOJQ_PATH" -r '.params.claude_hooks_skip // .claude_hooks_skip // "false"' 2>/dev/null)
    CLAUDE_CACHE_SKIP=$(echo "$input" | "$JSON_GOJQ_PATH" -r '.params.claude_cache_skip // .claude_cache_skip // "false"' 2>/dev/null)
    
    [[ -n "$LOG_FILE" ]] && echo "Parsed FILE_PATH: $FILE_PATH" >> "$LOG_FILE"
    [[ -n "$LOG_FILE" ]] && echo "Parsed CLAUDE_HOOKS_SKIP: $CLAUDE_HOOKS_SKIP" >> "$LOG_FILE"
    [[ -n "$LOG_FILE" ]] && echo "Parsed CLAUDE_CACHE_SKIP: $CLAUDE_CACHE_SKIP" >> "$LOG_FILE"
}


# Format analysis results - process new standardized return format
format_analysis_results() {
    local all_output=""
    
    for analyzer in "${APPLICABLE_ANALYZERS[@]}"; do
        # LOG: Show which analyzer is running
        log_info "ANALYZER EXECUTION: Running $analyzer"
        
        # Run analyzer and capture standardized return format
        local analyzer_result
        analyzer_result=$($analyzer 2>&1)
        if [[ -n "$analyzer_result" ]]; then
            # Fix Windows path escaping in JSON before parsing
            local fixed_json
            fixed_json=$(echo "$analyzer_result" | sed 's/\\\\/\\\\\\\\/g')
            
            # Parse the standardized return format
            local return_code
            local output_data
            return_code=$(echo "$fixed_json" | "$JSON_GOJQ_PATH" -r '.return_code // "ERROR"' 2>/dev/null)
            output_data=$(echo "$fixed_json" | "$JSON_GOJQ_PATH" -r '.output // ""' 2>/dev/null)
            
            if [[ "$return_code" == "SUCCESS" && -n "$output_data" ]]; then
                # LOG: Show analyzer completed successfully
                log_info "ANALYZER EXECUTION: $analyzer completed successfully with return_code=$return_code (${#output_data} chars output)"
                
                # Add separator between analyzers if we have previous output
                if [[ -n "$all_output" ]]; then
                    all_output+=$'\n'
                fi
                # Compact the JSON to single line
                local compacted_output
                compacted_output=$(echo "$output_data" | "$JSON_GOJQ_PATH" -c '.')
                all_output+=$(remove_ansi_codes "$compacted_output")
            else
                # LOG: Show analyzer failed 
                log_warn "ANALYZER EXECUTION: $analyzer failed with return_code=$return_code: $output_data"
                
                # ALWAYS include ALL analyzer results - success or error
                if [[ -n "$all_output" ]]; then
                    all_output+=$'\n'
                fi
                if [[ -n "$output_data" ]]; then
                    # Compact the JSON to single line
                    local compacted_output
                    compacted_output=$(echo "$output_data" | "$JSON_GOJQ_PATH" -c '.')
                    all_output+=$(remove_ansi_codes "$compacted_output")
                else
                    # Create error result if no output provided
                    all_output+="{\"analyzer\":\"${analyzer#analyze_}\",\"status\":\"error\",\"error\":\"No output from analyzer\"}"
                fi
            fi
        else
            # LOG: Show analyzer produced no output - create error result
            log_warn "ANALYZER EXECUTION: $analyzer produced no output"
            
            if [[ -n "$all_output" ]]; then
                all_output+=$'\n'
            fi
            all_output+="{\"analyzer\":\"${analyzer#analyze_}\",\"status\":\"error\",\"error\":\"Analyzer produced no output\"}"
        fi
    done
    
    echo "$all_output"
}