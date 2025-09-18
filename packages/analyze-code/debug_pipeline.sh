#!/bin/bash
export FILE_PATH="/c/Work/Git/damiansirbu/claude/hooks/analyze-hook/analyze-hook.sh"
source lib/settings.sh
source lib/core-utils.sh
setup_environment
source lib/json-utils.sh

load_analyzers() {
    local action="$1"
    local analyzer_subdir="$ANALYZER_DIR/analyzers/$action"
    for analyzer_file in "$analyzer_subdir"/*.sh; do
        if [[ -f "$analyzer_file" ]]; then
            source "$analyzer_file"
        fi
    done
}

load_analyzers inspect

# Set up APPLICABLE_ANALYZERS like main script does
mapfile -t APPLICABLE_ANALYZERS < <(echo "analyze_dependency")

echo "=== Simulating format_analysis_results exactly ==="
echo "APPLICABLE_ANALYZERS: ${APPLICABLE_ANALYZERS[*]}"
echo "Number of analyzers: ${#APPLICABLE_ANALYZERS[@]}"

# Simulate the exact for loop from format_analysis_results
local all_output=""
for analyzer in "${APPLICABLE_ANALYZERS[@]}"; do
    echo "Processing analyzer: $analyzer"
    
    # This is the exact line from format_analysis_results
    local analyzer_result
    analyzer_result=$($analyzer 2>&1)
    echo "Raw result length: ${#analyzer_result}"
    
    if [[ -n "$analyzer_result" ]]; then
        echo "Result is not empty"
        
        # Parse exactly like format_analysis_results does
        local return_code
        local output_data
        return_code=$(echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.return_code // "ERROR"' 2>/dev/null)
        output_data=$(echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.output // ""' 2>/dev/null)
        
        echo "return_code: '$return_code'"
        echo "output_data length: ${#output_data}"
        
        if [[ "$return_code" == "SUCCESS" && -n "$output_data" ]]; then
            echo "SUCCESS path taken"
        else
            echo "ERROR path taken - return_code='$return_code', output_data_empty=$([ -z "$output_data" ] && echo "true" || echo "false")"
        fi
    else
        echo "ERROR: analyzer_result is empty!"
    fi
done
