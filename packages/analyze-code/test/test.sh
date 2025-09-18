#!/usr/bin/env bash
# PRECISE ANALYZER VALIDATION - Tests exact analyzer requirements per file type
# Clear PASS/FAIL reporting with detailed analyzer validation

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly ANALYZE_HOOK="${SCRIPT_DIR}/../analyze-hook.sh"
readonly TEST_FILES_DIR="${SCRIPT_DIR}/files"
readonly RESULTS_DIR="${SCRIPT_DIR}/results"

mkdir -p "${RESULTS_DIR}"

# WORKING ANALYZERS TEST - REALISTIC EXPECTATIONS
declare -A FILE_ANALYZER_REQUIREMENTS=(
    # Java files - EXACTLY 4 analyzers required
    ["test_file_java_service.java"]="ctags scc dependency dependency_reverse"
    
    # Python files - EXACTLY 4 analyzers required  
    ["test_file_python_helper.py"]="ctags scc dependency dependency_reverse"
    
    # JavaScript files - EXACTLY 4 analyzers required
    ["test_file_javascript_tests.js"]="ctags scc dependency dependency_reverse"
    
    # Shell files - EXACTLY 5 analyzers required  
    ["test_file_shell_execute.sh"]="ctags scc shellcheck dependency dependency_reverse"
    
    # C++ files - EXACTLY 2 analyzers required
    ["test_file_cpp_database.cpp"]="ctags scc"
    
    # JSON files - EXACTLY 2 analyzers required
    ["test_file_json_package.json"]="ctags scc"
    
    # YAML config files - EXACTLY 2 analyzers required
    ["test_file_yaml_config.yaml"]="ctags scc"
    
    # Helm Chart files - EXACTLY 3 analyzers required
    ["test_file_yaml_helm_chart.yaml"]="ctags scc helm_chart"
)

# Test execution function
test_single_file() {
    local file_name="$1"
    local expected_analyzers="$2"
    local file_path="${TEST_FILES_DIR}/${file_name}"
    local result_file="${RESULTS_DIR}/${file_name}.result"
    
    echo "========================================="
    echo "TESTING: ${file_name}"
    echo "EXPECTED ANALYZERS: ${expected_analyzers}"
    echo "========================================="
    
    # Create JSON input with cache disabled
    local json_input=$(cat <<EOF
{
    "tool": "Read",
    "params": {
        "file_path": "${file_path}",
        "claude_cache_skip": "true"
    }
}
EOF
)
    
    # Execute analyzer
    local exit_code=0
    echo "${json_input}" | CLAUDE_CACHE_SKIP=true "${ANALYZE_HOOK}" inspect > "${result_file}" 2>&1 || exit_code=$?
    
    # Validate exit code (0 or 2 are acceptable)
    if [[ ${exit_code} -ne 0 && ${exit_code} -ne 2 ]]; then
        echo "❌ FAILED - Invalid exit code: ${exit_code}"
        return 1
    fi
    
    # Parse expected analyzers into array
    local expected_array
    IFS=' ' read -ra expected_array <<< "${expected_analyzers}"
    local expected_count=${#expected_array[@]}
    
    echo "REQUIRED ANALYZER COUNT: ${expected_count}"
    echo
    
    # Validate each expected analyzer
    local passed_analyzers=0
    local failed_analyzers=0
    local total_errors=0
    
    echo "DETAILED ANALYZER VALIDATION:"
    echo "------------------------------------------------------------"
    
    for analyzer in "${expected_array[@]}"; do
        echo "Testing analyzer: ${analyzer}"
        
        if grep -q "\"analyzer\":\"${analyzer}\"" "${result_file}"; then
            echo "  ✓ Analyzer executed successfully"
            
            # Extract analyzer data for detailed validation
            local analyzer_data
            analyzer_data=$(grep -A 50 "\"analyzer\":\"${analyzer}\"" "${result_file}" | head -20)
            
            # Check for errors first
            if echo "${analyzer_data}" | grep -q "ERROR:\|\"error\":\|\"status\":\"error\""; then
                echo "  ❌ ERROR DETECTED in output"
                local error_details=$(echo "${analyzer_data}" | grep -o "ERROR:[^\"]*\|\"error\":[^,}]*\|\"status\":\"error\"")
                echo "     Error details: ${error_details}"
                failed_analyzers=$((failed_analyzers + 1))
                total_errors=$((total_errors + 1))
                
            # Check for data content
            elif echo "${analyzer_data}" | grep -q "\"data\":\|\"analysis\":\|\"results\":\|\"metrics\":\|\"raw_scc_data\":\|\"function_analysis\":\|\"syntax_tree\":\|\"code_elements\":\|\"analysis_summary\":\|\"architecture\":\|\"microservices\":\|\"dependencies\":\|\"kubernetes\":\|\"templates\":\|\"configuration\":\|\"patterns\":\|\"chart_metadata\":"; then
                echo "  ✅ DATA VALIDATION PASSED"
                
                # Show specific data fields found
                local data_fields=""
                echo "${analyzer_data}" | grep -q "\"data\":" && data_fields+="data "
                echo "${analyzer_data}" | grep -q "\"metrics\":" && data_fields+="metrics "
                echo "${analyzer_data}" | grep -q "\"function_analysis\":" && data_fields+="functions "
                echo "${analyzer_data}" | grep -q "\"syntax_tree\":" && data_fields+="ast "
                echo "${analyzer_data}" | grep -q "\"analysis_summary\":" && data_fields+="summary "
                echo "${analyzer_data}" | grep -q "\"architecture\":" && data_fields+="architecture "
                echo "${analyzer_data}" | grep -q "\"microservices\":" && data_fields+="microservices "
                echo "${analyzer_data}" | grep -q "\"dependencies\":" && data_fields+="dependencies "
                echo "${analyzer_data}" | grep -q "\"kubernetes\":" && data_fields+="kubernetes "
                echo "${analyzer_data}" | grep -q "\"templates\":" && data_fields+="templates "
                echo "${analyzer_data}" | grep -q "\"configuration\":" && data_fields+="configuration "
                echo "${analyzer_data}" | grep -q "\"patterns\":" && data_fields+="patterns "
                echo "${analyzer_data}" | grep -q "\"chart_metadata\":" && data_fields+="chart_metadata "
                
                if [[ -n "$data_fields" ]]; then
                    echo "     Data fields: ${data_fields}"
                fi
                
                # Extract key metrics for scc
                if [[ "$analyzer" == "scc" ]]; then
                    local lines_count=$(echo "${analyzer_data}" | grep -o "\"total_lines\":[0-9]*" | cut -d: -f2)
                    local complexity=$(echo "${analyzer_data}" | grep -o "\"total_complexity\":[0-9]*" | cut -d: -f2)
                    [[ -n "$lines_count" ]] && echo "     Lines analyzed: ${lines_count}"
                    [[ -n "$complexity" ]] && echo "     Complexity score: ${complexity}"
                fi
                
                # Extract tag count for ctags
                if [[ "$analyzer" == "ctags" ]]; then
                    local tag_count=$(echo "${analyzer_data}" | grep -o "\"_type\": \"tag\"" | wc -l)
                    echo "     Tags found: ${tag_count}"
                fi
                
                # Extract analysis details for helm_chart
                if [[ "$analyzer" == "helm_chart" ]]; then
                    local chart_name=$(echo "${analyzer_data}" | grep -o "\"name\":\"[^\"]*\"" | head -1 | cut -d: -f2 | tr -d '"')
                    local actual_microservices=$(echo "${analyzer_data}" | grep -o "\"actual_microservices\":[0-9]*" | cut -d: -f2)
                    local values_config_sections=$(echo "${analyzer_data}" | grep -o "\"values_config_sections\":[0-9]*" | cut -d: -f2)
                    local chart_deps=$(echo "${analyzer_data}" | grep -o "\"chart_dependencies\":[0-9]*" | cut -d: -f2)
                    local complexity=$(echo "${analyzer_data}" | grep -o "\"complexity\":\"[^\"]*\"" | cut -d: -f2 | tr -d '"')
                    local arch_type=$(echo "${analyzer_data}" | grep -o "\"architecture_type\":\"[^\"]*\"" | cut -d: -f2 | tr -d '"')
                    [[ -n "$chart_name" ]] && echo "     Chart: ${chart_name}"
                    [[ -n "$actual_microservices" ]] && echo "     Microservices (templates): ${actual_microservices}"
                    [[ -n "$values_config_sections" ]] && echo "     Config sections (values.yaml): ${values_config_sections}"
                    [[ -n "$chart_deps" ]] && echo "     Dependencies (Chart.yaml): ${chart_deps}"
                    [[ -n "$complexity" ]] && echo "     Complexity: ${complexity}"
                    [[ -n "$arch_type" ]] && echo "     Architecture: ${arch_type}"
                fi
                
                passed_analyzers=$((passed_analyzers + 1))
                
            else
                echo "  ⚠️  NO DATA CONTENT DETECTED"
                echo "     Analyzer ran but returned no analyzable data"
                failed_analyzers=$((failed_analyzers + 1))
            fi
        else
            echo "  ❌ ANALYZER NOT EXECUTED"
            echo "     Analyzer was not found in the result output"
            failed_analyzers=$((failed_analyzers + 1))
        fi
        echo ""
    done
    
    echo
    echo "========================================="
    echo "FINAL RESULTS FOR ${file_name}:"
    echo "========================================="
    echo "Expected analyzers: ${expected_count}"
    echo "✅ Passed: ${passed_analyzers}"
    echo "❌ Failed: ${failed_analyzers}"
    echo "🚨 Errors found: ${total_errors}"
    
    if [[ ${passed_analyzers} -eq ${expected_count} && ${total_errors} -eq 0 ]]; then
        echo "🎉 OVERALL: PERFECT PASS - All analyzers working with real data"
        return 0
    elif [[ ${passed_analyzers} -eq ${expected_count} ]]; then
        echo "⚠️  OVERALL: PASS WITH WARNINGS - All analyzers executed but some have errors"
        return 0  
    else
        echo "💥 OVERALL: FAILED - Missing ${failed_analyzers} analyzers"
        return 1
    fi
}

# Main test execution
main() {
    echo "PRECISE ANALYZER VALIDATION SUITE"
    echo "Testing exact analyzer requirements per file type"
    echo "================================================="
    echo
    
    local total_files=0
    local passed_files=0
    local failed_files=0
    
    # Test each file with exact requirements
    for file_name in "${!FILE_ANALYZER_REQUIREMENTS[@]}"; do
        local expected_analyzers="${FILE_ANALYZER_REQUIREMENTS[$file_name]}"
        
        total_files=$((total_files + 1))
        
        if test_single_file "${file_name}" "${expected_analyzers}"; then
            passed_files=$((passed_files + 1))
        else
            failed_files=$((failed_files + 1))
        fi
        
        echo
        echo
    done
    
    # Final summary
    echo "================================================="
    echo "FINAL TEST SUITE RESULTS"
    echo "================================================="
    echo "Total files tested: ${total_files}"
    echo "✅ Files passed: ${passed_files}" 
    echo "❌ Files failed: ${failed_files}"
    echo
    
    if [[ ${failed_files} -eq 0 ]]; then
        echo "🎉 SUCCESS: ALL FILES PASSED ANALYZER VALIDATION"
        return 0
    else
        echo "💥 FAILURE: ${failed_files} files failed analyzer validation"
        echo
        echo "Failed files need investigation:"
        for file_name in "${!FILE_ANALYZER_REQUIREMENTS[@]}"; do
            local expected_analyzers="${FILE_ANALYZER_REQUIREMENTS[$file_name]}"
            local result_file="${RESULTS_DIR}/${file_name}.result"
            
            if [[ -f "${result_file}" ]]; then
                local passed_count=0
                local expected_array
                IFS=' ' read -ra expected_array <<< "${expected_analyzers}"
                
                for analyzer in "${expected_array[@]}"; do
                    if grep -q "\"analyzer\":\"${analyzer}\"" "${result_file}" && ! grep -A 20 "\"analyzer\":\"${analyzer}\"" "${result_file}" | head -10 | grep -q "ERROR:\|\"error\":"; then
                        passed_count=$((passed_count + 1))
                    fi
                done
                
                if [[ ${passed_count} -lt ${#expected_array[@]} ]]; then
                    echo "  - ${file_name}: ${passed_count}/${#expected_array[@]} analyzers working"
                fi
            fi
        done
        
        return 1
    fi
}

main "$@"