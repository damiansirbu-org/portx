#!/bin/bash
# =============================================================================
# CTAGS ANALYZER MODULE
# Deep code analysis with comprehensive symbol extraction
# =============================================================================

# Tool configuration - use path from settings.sh
CTAGS_TOOL="$CTAGS_PATH"

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_ctags")

analyze_ctags() {
    # Check if CTags is available
    if ! command -v "$CTAGS_TOOL" >/dev/null 2>&1; then
        return_error '{"analyzer":"ctags","status":"unavailable","path":"'"$CTAGS_TOOL"'"}'
        return
    fi
    
    # Create analyzer-specific temporary directory
    local temp_dir="/tmp/ctags-analyzer-$$"
    mkdir -p "$temp_dir" 2>/dev/null
    
    # Get file size in lines to determine analysis mode
    local line_count
    line_count=$(wc -l < "$FILE_PATH" 2>/dev/null || echo "999")
    
    # Determine analysis mode based on file size
    local ctags_fields ctags_kinds ctags_extras analysis_mode
    if [[ $line_count -lt 500 ]]; then
        # EXTENDED MODE: Full analysis for small files (<500 lines)
        ctags_fields="--fields=+nkStZia"
        ctags_kinds=""
        ctags_extras="--extras=+f"
        analysis_mode="extended"
    elif [[ $line_count -lt 1200 ]]; then
        # REGULAR MODE: Drop variables and references (500-1200 lines)
        ctags_fields="--fields=+nkStZi"
        ctags_kinds=""
        ctags_extras=""
        analysis_mode="regular"
    else
        # BASIC MODE: Core architectural elements only (>1200 lines)
        ctags_fields="--fields=+nkSt"
        ctags_kinds=""
        ctags_extras=""
        analysis_mode="basic"
    fi
    
    # Create temporary output file
    local temp_output="$temp_dir/ctags_output"
    
    # Run CTags with size-optimized parameters
    local result
    if ! timeout "$ANALYZER_TIMEOUT" "$CTAGS_TOOL" \
        --output-format=json \
        $ctags_fields \
        $ctags_kinds \
        $ctags_extras \
        -f "$temp_output" \
        "$FILE_PATH" 2>/dev/null; then
        return_error '{"analyzer":"ctags","status":"execution_failed","file":"'"$FILE_PATH"'"}'
        return
    fi
    
    # Read the result from temp file
    if [[ -f "$temp_output" ]]; then
        result=$(cat "$temp_output" 2>/dev/null)
    else
        result=""
    fi
    
    # Check if we got results
    if [[ -n "$result" ]]; then
        # Convert multiple JSON objects to array
        local json_array="["
        local first=true
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                if [[ "$first" == true ]]; then
                    first=false
                else
                    json_array+=","
                fi
                json_array+="$line"
            fi
        done <<< "$result"
        json_array+="]"
        
        # Wrap raw CTags output in our standard format with mode info
        local ctags_json
        ctags_json='{"analyzer":"ctags","status":"success","file":"'"$FILE_PATH"'","analysis_mode":"'"$analysis_mode"'","line_count":'"$line_count"',"data":'"$json_array"'}'
        
        # Cleanup temp directory
        rm -rf "$temp_dir" 2>/dev/null
        return_success "$ctags_json"
    else
        # Cleanup temp directory  
        rm -rf "$temp_dir" 2>/dev/null
        return_error '{"analyzer":"ctags","status":"no_symbols","file":"'"$FILE_PATH"'","analysis_mode":"'"$analysis_mode"'","line_count":'"$line_count"'"}'
    fi
}
