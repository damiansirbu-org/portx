#!/bin/bash
# =============================================================================
# AST-GREP ANALYZER - Enhanced Pattern Matching and Code Search
# Semantic code search and pattern analysis using AST-based queries
# =============================================================================

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_ast_grep")

analyze_ast_grep() {
    local astgrep_path="$GIT_BASH_ROOT/home/portx/packages/ast-grep/ast-grep.exe"
    
    # Check if ast-grep is available
    if [[ ! -f "$astgrep_path" ]]; then
        return_error '{"analyzer":"ast_grep","status":"tool_unavailable","details":"ast-grep executable not found"}'
        return 1
    fi
    
    if [[ ! -f "$FILE_PATH" ]]; then
        return_error '{"analyzer":"ast_grep","status":"file_not_found","details":"Input file does not exist"}'
        return 1
    fi
    
    local file_ext="${FILE_PATH##*.}"
    local escaped_file_path
    escaped_file_path=$(printf '%s' "${FILE_PATH}" | sed 's/\\/\\\\/g; s/"/\\"/g')
    
    # Map file extension to language
    local language=""
    case "$file_ext" in
        py|pyi) language="python" ;;
        js|jsx|mjs) language="javascript" ;;
        ts|tsx) language="typescript" ;;
        java) language="java" ;;
        c|h) language="c" ;;
        cc|cpp|cxx|hpp|hxx) language="cpp" ;;
        cs) language="csharp" ;;
        rs) language="rust" ;;
        go) language="go" ;;
        sh|bash) language="bash" ;;
        rb) language="ruby" ;;
        php) language="php" ;;
        yaml|yml) language="yaml" ;;
        json) language="json" ;;
        *) 
            return_error '{"analyzer":"ast_grep","status":"unsupported_language","details":"File extension not supported by ast-grep analyzer"}'
            return 1 
            ;;
    esac
    
    local functions_found=0
    local variables_found=0
    local classes_found=0
    local imports_found=0
    local patterns_tried=0
    local successful_patterns=0
    local error_messages=()
    
    # Test different patterns based on language
    case "$language" in
        python)
            # Try Python function pattern
            local py_funcs
            if py_funcs=$(timeout 10 "$astgrep_path" run --lang python -p 'def $NAME($ARGS):
    $$$BODY' "$FILE_PATH" 2>/dev/null); then
                functions_found=$(echo "$py_funcs" | wc -l)
                ((successful_patterns++))
            fi
            ((patterns_tried++))
            ;;
            
        javascript|typescript)
            # Try simple function declaration
            local js_funcs
            if js_funcs=$(timeout 10 "$astgrep_path" run --lang "$language" -p 'function $NAME($ARGS) {}' "$FILE_PATH" 2>/dev/null); then
                functions_found=$(echo "$js_funcs" | wc -l)
                ((successful_patterns++))
            fi
            ((patterns_tried++))
            ;;
            
        bash)
            # For bash, ast-grep has limited support, try simple text matching
            # Count function definitions manually since ast-grep bash patterns fail
            if [[ -f "$FILE_PATH" ]]; then
                functions_found=$(grep -c '^[a-zA-Z_][a-zA-Z0-9_]*()' "$FILE_PATH" 2>/dev/null || echo "0")
                variables_found=$(grep -c '^[A-Z_][A-Z0-9_]*=' "$FILE_PATH" 2>/dev/null || echo "0")
                classes_found=0  # Bash doesn't have classes
                imports_found=$(grep -c '^source\|^\.' "$FILE_PATH" 2>/dev/null || echo "0")
                successful_patterns=3
            else
                functions_found=0
                variables_found=0
                classes_found=0
                imports_found=0
                error_messages+=("File not accessible for bash analysis")
            fi
            patterns_tried=3
            ;;
            
        yaml)
            # For YAML, focus on structure analysis
            if [[ -f "$FILE_PATH" ]]; then
                # Count YAML key-value pairs
                variables_found=$(grep -c '^[a-zA-Z][a-zA-Z0-9_-]*:' "$FILE_PATH" 2>/dev/null || echo "0")
                # Count arrays/lists
                imports_found=$(grep -c '^[[:space:]]*-[[:space:]]' "$FILE_PATH" 2>/dev/null || echo "0")
                # Count nested sections (indented keys)
                classes_found=$(grep -c '^[[:space:]]\+[a-zA-Z][a-zA-Z0-9_-]*:' "$FILE_PATH" 2>/dev/null || echo "0")
                functions_found=0  # YAML doesn't have functions
                successful_patterns=3
            else
                functions_found=0
                variables_found=0
                classes_found=0
                imports_found=0
                error_messages+=("File not accessible for YAML analysis")
            fi
            patterns_tried=3
            ;;
            
        json)
            # For JSON, focus on structure analysis
            if [[ -f "$FILE_PATH" ]]; then
                # Count JSON keys
                variables_found=$(grep -c '"[^"]*"[[:space:]]*:' "$FILE_PATH" 2>/dev/null || echo "0")
                # Count arrays
                imports_found=$(grep -c '\[' "$FILE_PATH" 2>/dev/null || echo "0")
                # Count objects
                classes_found=$(grep -c '{' "$FILE_PATH" 2>/dev/null || echo "0")
                functions_found=0  # JSON doesn't have functions
                successful_patterns=3
            else
                functions_found=0
                variables_found=0
                classes_found=0
                imports_found=0
                error_messages+=("File not accessible for JSON analysis")
            fi
            patterns_tried=3
            ;;
            
        *)
            # Try generic pattern matching
            local output
            if output=$(timeout 10 "$astgrep_path" run --lang "$language" -p '$ANYTHING' "$FILE_PATH" 2>&1); then
                if [[ ! "$output" =~ "Error:" ]]; then
                    ((successful_patterns++))
                fi
            else
                error_messages+=("Generic pattern failed for $language")
            fi
            ((patterns_tried++))
            ;;
    esac
    
    # Generate comprehensive analysis report using safe JSON construction
    local result_json
    result_json=$(json_object \
        "analyzer" "ast_grep" \
        "language" "$language" \
        "file" "$FILE_PATH" \
        "patterns_tried" "$patterns_tried" \
        "successful_patterns" "$successful_patterns" \
        "functions_detected" "$functions_found" \
        "variables_detected" "$variables_found" \
        "classes_detected" "$classes_found" \
        "imports_detected" "$imports_found" \
        "error_count" "${#error_messages[@]}" \
        "analysis_notes" "AST-grep analysis with pattern matching statistics")
    
    return_success "$result_json"
}