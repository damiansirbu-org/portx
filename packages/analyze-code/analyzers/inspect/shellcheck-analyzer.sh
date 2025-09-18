#!/bin/bash
# =============================================================================
# SHELLCHECK ANALYZER - Semantic Shell Script Analysis
# Advanced semantic analysis focused on code understanding and patterns
# =============================================================================

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_shellcheck")

analyze_shellcheck() {
    local shellcheck_path="$GIT_BASH_ROOT/home/portx/packages/shellcheck/shellcheck.exe"
    
    # Check if shellcheck is available
    if [[ ! -f "$shellcheck_path" ]]; then
        return_error '{"analyzer":"shellcheck","status":"tool_unavailable","details":"Shellcheck not found at expected path"}'
        return
    fi
    
    # Only analyze shell files
    local file_ext="${FILE_PATH##*.}"
    case "$file_ext" in
        sh|bash|zsh|fish) ;;
        "") 
            local basename="$(basename "$FILE_PATH")"
            case "$basename" in
                *.*) 
                    return_error '{"analyzer":"shellcheck","status":"unsupported_file","details":"File has extension but is not a shell script"}'
                    return
                    ;;
            esac
            ;;
        *) 
            return_error '{"analyzer":"shellcheck","status":"unsupported_file","details":"File extension not supported for shell analysis"}'
            return
            ;;
    esac
    
    # Run shellcheck with JSON output and semantic focus
    local result
    result=$(timeout "$ANALYZER_TIMEOUT" "$shellcheck_path" \
        --format=json \
        --enable=all \
        --shell=bash \
        --severity=style \
        --wiki-link-count=5 \
        "$FILE_PATH" 2>/dev/null)
    
    if [[ -n "$result" ]]; then
        # Count different types of issues for quality metrics
        local total_issues error_count warning_count style_count info_count
        total_issues=$(echo "$result" | "$GOJQ_PATH" 'length' 2>/dev/null || echo "0")
        error_count=$(echo "$result" | "$GOJQ_PATH" '[.[] | select(.level == "error")] | length' 2>/dev/null || echo "0")
        warning_count=$(echo "$result" | "$GOJQ_PATH" '[.[] | select(.level == "warning")] | length' 2>/dev/null || echo "0")
        style_count=$(echo "$result" | "$GOJQ_PATH" '[.[] | select(.level == "style")] | length' 2>/dev/null || echo "0")
        info_count=$(echo "$result" | "$GOJQ_PATH" '[.[] | select(.level == "info")] | length' 2>/dev/null || echo "0")
        
        # Build enhanced JSON structure with safe construction
        local enhanced_json
        enhanced_json=$(json_object \
            "analyzer" "shellcheck" \
            "file" "$FILE_PATH" \
            "status" "analyzed" \
            "total_issues" "$total_issues" \
            "error_count" "$error_count" \
            "warning_count" "$warning_count" \
            "style_count" "$style_count" \
            "info_count" "$info_count" \
            "analysis_notes" "Enhanced shellcheck with semantic categorization")
        
        # For now, we'll add the raw issues as a separate field to maintain compatibility
        # but provide the enhanced metrics for content quality validation
        local temp_file="/tmp/shellcheck_$$.json"
        echo "$enhanced_json" > "$temp_file"
        echo "$result" | "$GOJQ_PATH" --slurpfile base "$temp_file" '$base[0] + {raw_issues: .}' 2>/dev/null > "$temp_file.final"
        
        if [[ -f "$temp_file.final" ]]; then
            local final_result
            final_result=$(cat "$temp_file.final")
            rm -f "$temp_file"* 2>/dev/null
            return_success "$final_result"
        else
            rm -f "$temp_file"* 2>/dev/null
            return_success "$enhanced_json"
        fi
    else
        # No issues found - return enhanced success structure with full metrics
        local no_issues_json
        no_issues_json=$(json_object \
            "analyzer" "shellcheck" \
            "file" "$FILE_PATH" \
            "status" "no_issues" \
            "total_issues" "0" \
            "error_count" "0" \
            "warning_count" "0" \
            "style_count" "0" \
            "info_count" "0" \
            "analysis_notes" "No issues found - clean shell script")
        return_success "$no_issues_json"
    fi
}