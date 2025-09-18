#!/bin/bash
# shellcheck disable=SC1091

# =============================================================================
# ANALYZE CODE - STANDALONE DUAL MODE TOOL
# inspect: Code structure analysis (default)
# verify:  Code quality validation
# =============================================================================

# Source settings and libraries
source "$(dirname "${BASH_SOURCE[0]}")/lib/settings.sh"
source "$ANALYZER_DIR/lib/core-utils.sh"

# Ensure Git tools are in PATH for analyzers
export PATH="$GIT_BASH_ROOT/bin:$PATH"

# Parameter parsing for standalone tool
if [[ $# -eq 0 ]]; then
    json_output "error" "Missing required parameter" '"usage":"analyze-code.sh <file_path> [inspect|verify]","options":{"file_path":"Path to the file to analyze","inspect":"Analyze code structure (default)","verify":"Validate code quality"}'
    exit 1
fi

# Convert relative path to absolute path
if [[ "$1" = /* ]] || [[ "$1" =~ ^[a-zA-Z]: ]]; then
    FILE_PATH="$1"
else
    FILE_PATH="$(pwd)/$1"
fi
ACTION="${2:-inspect}"

# Validate action parameter
case "$ACTION" in
    inspect|verify)
        ;;
    *)
        json_output "error" "Invalid action specified" '"invalid_action":"'"$ACTION"'","usage":"analyze-code.sh <file_path> [inspect|verify]","valid_actions":["inspect","verify"]'
        exit 1
        ;;
esac
source "$ANALYZER_DIR/lib/json-utils.sh"
source "$ANALYZER_DIR/lib/text-utils.sh"

# Global variables for exit handler
ANALYZER_RESULTS=""

final_exit() {
    local reason="$1"
    
    case "$reason" in
        SKIP)
            local file_ext_display="${FILE_EXT:-"no extension"}"
            local filename
            filename="$(basename "$FILE_PATH")"
            json_output "skipped" "File not supported for analysis" '"file_extension":"'"$file_ext_display"'","filename":"'"$filename"'","reason":"file_not_supported"'
            exit 0
            ;;
        ERROR)
            local filename
            filename="$(basename "$FILE_PATH")"
            if [[ -n "$ANALYZER_RESULTS" ]]; then
                json_output "error" "Analysis failed" '"filename":"'"$filename"'","details":"'"$ANALYZER_RESULTS"'"'
            else
                json_output "error" "Failed to analyze file" '"filename":"'"$filename"'"'
            fi
            exit 1
            ;;
        SUCCESS)
            if [[ -n "$ANALYZER_RESULTS" ]]; then
                # Build analyzers object using temp file to avoid argument length limits
                local temp_analyzers_file="/tmp/analyzers_$$.json"
                echo "{}" > "$temp_analyzers_file"
                local successful_count=0
                local error_count=0
                local total_count=0
                
                while IFS= read -r line; do
                    if [[ -n "$line" && "$line" =~ ^\{.*\}$ ]]; then
                        local analyzer_name
                        analyzer_name=$(echo "$line" | "$GOJQ_PATH" -r '.analyzer // "unknown"' 2>/dev/null)
                        if [[ -n "$analyzer_name" && "$analyzer_name" != "unknown" ]]; then
                            # Add analyzer result to object via safe JSON merge
                            json_merge_safe "$temp_analyzers_file" "$line" "analyzer"
                            
                            # Count analyzer status
                            total_count=$((total_count + 1))
                            local status
                            status=$(echo "$line" | "$GOJQ_PATH" -r '.status // "unknown"' 2>/dev/null)
                            if [[ "$status" == "error" || "$status" == "execution_failed" ]]; then
                                error_count=$((error_count + 1))
                            else
                                successful_count=$((successful_count + 1))
                            fi
                        fi
                    fi
                done <<< "$ANALYZER_RESULTS"
                
                local analyzers_json
                analyzers_json=$(cat "$temp_analyzers_file")
                rm -f "$temp_analyzers_file" 2>/dev/null
                
                # Build execution summary with enhanced metrics
                local expected_count=${#APPLICABLE_ANALYZERS[@]}
                local success_rate=$((successful_count * 100 / (total_count > 0 ? total_count : 1)))
                
                # Count status types and content quality
                local warn_count=0
                local content_rich_count=0
                while IFS= read -r line; do
                    if [[ -n "$line" && "$line" =~ ^\{.*\}$ ]]; then
                        local status
                        status=$(echo "$line" | "$GOJQ_PATH" -r '.status // "unknown"' 2>/dev/null)
                        if [[ "$status" == "warning" ]]; then
                            warn_count=$((warn_count + 1))
                        fi
                        
                        # Count fields to assess content richness (minimum 5 fields indicates substantial content)
                        local field_count
                        field_count=$(echo "$line" | "$GOJQ_PATH" 'keys | length' 2>/dev/null || echo "0")
                        if [[ "$field_count" -ge 5 ]]; then
                            content_rich_count=$((content_rich_count + 1))
                        fi
                    fi
                done <<< "$ANALYZER_RESULTS"
                
                local summary_json
                summary_json=$(json_object \
                    "file_type" "$FILE_EXT" \
                    "expected_analyzers" "$expected_count" \
                    "executed_analyzers" "$total_count" \
                    "successful_analyzers" "$successful_count" \
                    "failed_analyzers" "$error_count" \
                    "warning_analyzers" "$warn_count" \
                    "content_rich_analyzers" "$content_rich_count" \
                    "success_rate" "${success_rate}%" \
                    "content_quality_rate" "$((content_rich_count * 100 / (total_count > 0 ? total_count : 1)))%")
                
                # Build final result using temp file to avoid argument length limits
                local final_temp="/tmp/final_result_$$.json"
                echo '{"status": "success"}' > "$final_temp"
                
                # Add analyzers to final result
                echo "$analyzers_json" | "$GOJQ_PATH" --slurpfile base "$final_temp" '. as $analyzers | $base[0] + {analyzers: $analyzers}' > "$final_temp.new" && mv "$final_temp.new" "$final_temp"
                
                # Add summary to final result  
                echo "$summary_json" | "$GOJQ_PATH" --slurpfile base "$final_temp" '. as $summary | $base[0] + {execution_summary: $summary}' > "$final_temp.new" && mv "$final_temp.new" "$final_temp"
                
                # Output final result and cleanup
                cat "$final_temp"
                rm -f "$final_temp" 2>/dev/null
            else
                json_output "no_results" "No analysis results available"
            fi
            exit 0
            ;;
        *)
            json_output "error" "Internal error: Invalid exit reason" '"reason":"'"$reason"'"'
            exit 2
            ;;
    esac
}

# Early file type check - SKIP unsupported files immediately  
setup_environment
if ! should_analyze_file "$FILE_EXT" "$BASENAME"; then
    final_exit SKIP
fi

load_analyzers() {
    local action="$1"
    local analyzer_subdir="$ANALYZER_DIR/analyzers/$action"
    for analyzer_file in "$analyzer_subdir"/*.sh; do
        if [[ -f "$analyzer_file" ]]; then
            # shellcheck disable=SC1090  # Dynamic sourcing of analyzer modules
            source "$analyzer_file"
        fi
    done
}

# Load analyzers before main function
load_analyzers "$ACTION"

main() {
    
    local validation_result
    local validation_status
    validation_result=$(validate_file_path)
    validation_status=$(echo "$validation_result" | "$GOJQ_PATH" -r '.status')
    
    if [[ "$validation_status" == "ERROR" ]]; then
        ANALYZER_RESULTS="ERROR: $(echo "$validation_result" | "$GOJQ_PATH" -r '.data | to_entries | map("\(.key): \(.value)") | join(", ")')"
        final_exit ERROR
    fi
    
    if [[ "$ACTION" == "inspect" ]]; then
        mapfile -t APPLICABLE_ANALYZERS < <(get_inspect_analyzers "$FILE_EXT" "$BASENAME")
    else
        # shellcheck disable=SC2034  # Used in lib/json-utils.sh by format_analysis_results
        mapfile -t APPLICABLE_ANALYZERS < <(get_verify_analyzers "$FILE_EXT" "$BASENAME")
    fi
    local analysis_output
    analysis_output=$(format_analysis_results)
    if [[ -n "$ANALYZER_RESULTS" ]]; then
        ANALYZER_RESULTS+=$'\n\n'"$analysis_output"
    else
        ANALYZER_RESULTS="$analysis_output"
    fi
    
    final_exit SUCCESS
}

# Execute main function
main
