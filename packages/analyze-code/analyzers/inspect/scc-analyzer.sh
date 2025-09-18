#!/bin/bash
# =============================================================================
# SCC ANALYZER - Enhanced Code Statistics and Complexity
# Provides detailed code metrics with per-function complexity estimation
# =============================================================================

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_scc")

analyze_scc() {
    local scc_path="${GIT_BASH_ROOT}/home/portx/packages/scc/scc.exe"
    local ctags_path="${GIT_BASH_ROOT}/home/portx/packages/ctags/ctags.exe"
    local gojq_path="/c/App/Git/home/portx/packages/gojq/gojq.exe"
    
    # Check if SCC is available
    if [[ ! -f "$scc_path" ]]; then
        return_error '{"analyzer":"scc","status":"unavailable","path":"'"$scc_path"'"}'
        return
    fi
    
    # Get basic SCC metrics
    local scc_output
    if ! scc_output=$(timeout "${ANALYZER_TIMEOUT}" "$scc_path" --format json "${FILE_PATH}" 2>/dev/null); then
        return_error '{"analyzer":"scc","status":"execution_failed","file":"'"$FILE_PATH"'"}'
        return
    fi
    
    # Parse SCC JSON to extract basic metrics
    local total_complexity total_lines total_code language_name
    total_complexity=$(echo "$scc_output" | "$gojq_path" -r '.[0].Complexity // 0' 2>/dev/null)
    total_lines=$(echo "$scc_output" | "$gojq_path" -r '.[0].Lines // 0' 2>/dev/null)
    total_code=$(echo "$scc_output" | "$gojq_path" -r '.[0].Code // 0' 2>/dev/null)
    language_name=$(echo "$scc_output" | "$gojq_path" -r '.[0].Name // "Unknown"' 2>/dev/null)
    
    # Get function-level analysis using ctags if available
    local functions_json="[]"
    local function_count=0
    if [[ -f "$ctags_path" && -f "${FILE_PATH}" ]]; then
        local ctags_output
        if ctags_output=$(timeout 10 "$ctags_path" --output-format=json --fields=+n --kinds-all='*' "${FILE_PATH}" 2>/dev/null); then
            # Extract functions and estimate complexity per function
            local temp_functions=()
            while IFS= read -r line; do
                [[ -n "$line" ]] || continue
                local func_name func_line func_kind
                func_name=$(echo "$line" | "$gojq_path" -r '.name // ""' 2>/dev/null)
                func_line=$(echo "$line" | "$gojq_path" -r '.line // 0' 2>/dev/null)
                func_kind=$(echo "$line" | "$gojq_path" -r '.kind // ""' 2>/dev/null)
                
                # Only include functions, not variables or other symbols  
                # Shell uses 'f' for functions, others use different codes
                if [[ "$func_kind" =~ ^(f|function|func|method|procedure|subroutine)$ && -n "$func_name" ]]; then
                    local escaped_name escaped_kind
                    escaped_name=$(printf '%s' "$func_name" | sed 's/\\/\\\\/g; s/"/\\"/g')
                    escaped_kind=$(printf '%s' "$func_kind" | sed 's/\\/\\\\/g; s/"/\\"/g')
                    temp_functions+=("{\"name\":\"$escaped_name\",\"line\":$func_line,\"kind\":\"$escaped_kind\",\"estimated_complexity\":1}")
                fi
            done <<< "$ctags_output"
            
            function_count=${#temp_functions[@]}
            if [[ $function_count -gt 0 ]]; then
                # Distribute total complexity across functions
                local avg_complexity=1
                if [[ $total_complexity -gt 0 ]]; then
                    avg_complexity=$((total_complexity / function_count))
                    [[ $avg_complexity -lt 1 ]] && avg_complexity=1
                fi
                
                # Update each function with calculated complexity
                for i in "${!temp_functions[@]}"; do
                    temp_functions[$i]=$(echo "${temp_functions[$i]}" | sed "s/\"estimated_complexity\":1/\"estimated_complexity\":$avg_complexity/")
                done
                
                functions_json="[$(IFS=,; echo "${temp_functions[*]}")]"
            fi
        fi
    fi
    
    # Generate enhanced JSON output with proper escaping
    local escaped_file_path escaped_language
    escaped_file_path=$(printf '%s' "${FILE_PATH}" | sed 's/\\/\\\\/g; s/"/\\"/g')
    escaped_language=$(printf '%s' "$language_name" | sed 's/\\/\\\\/g; s/"/\\"/g')
    
    local scc_result
    scc_result=$(printf '{"analyzer":"scc","file":"%s","language":"%s","metrics":{"total_lines":%d,"code_lines":%d,"total_complexity":%d,"function_count":%d,"avg_complexity_per_function":%d},"raw_scc_data":%s,"function_analysis":%s,"analysis_notes":"Enhanced SCC with per-function complexity estimation"}' \
        "$escaped_file_path" \
        "$escaped_language" \
        "$total_lines" \
        "$total_code" \
        "$total_complexity" \
        "$function_count" \
        "$((total_complexity > 0 && function_count > 0 ? total_complexity / function_count : 0))" \
        "$scc_output" \
        "$functions_json")
    
    return_success "$scc_result"
}