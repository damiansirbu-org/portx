#!/bin/bash
cd /c/App/Git/home/portx/packages/analyze-code
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

# Test the exact format_analysis_results logic
debug_format_analysis() {
    local all_output=""
    APPLICABLE_ANALYZERS=("analyze_dependency")
    
    for analyzer in "${APPLICABLE_ANALYZERS[@]}"; do
        echo "=== Processing $analyzer ==="
        
        # Run analyzer exactly like format_analysis_results
        local analyzer_result
        analyzer_result=$($analyzer 2>&1)
        
        echo "Raw result length: ${#analyzer_result}"
        echo "Raw result (first 200 chars): ${analyzer_result:0:200}"
        
        # Save to file for inspection
        echo "$analyzer_result" > /tmp/analyzer_result.json
        
        if [[ -n "$analyzer_result" ]]; then
            echo "Result is not empty"
            
            # Test gojq parsing step by step
            echo "Testing return_code parsing..."
            local return_code
            return_code=$(echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.return_code // "ERROR"' 2>&1)
            echo "return_code result: '$return_code'"
            
            echo "Testing output parsing..."
            local output_data
            output_data=$(echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.output // ""' 2>&1)
            echo "output_data length: ${#output_data}"
            echo "output_data (first 100 chars): ${output_data:0:100}"
            
            # Test JSON validity
            echo "Testing JSON validity..."
            echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.return_code' 2>&1 | head -3
            
        else
            echo "ERROR: analyzer_result is empty!"
        fi
    done
}

debug_format_analysis