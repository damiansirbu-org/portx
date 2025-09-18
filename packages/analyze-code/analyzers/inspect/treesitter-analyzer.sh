#!/bin/bash
# =============================================================================
# TREE-SITTER ANALYZER - Advanced Syntax Tree Analysis
# Provides deep syntactic analysis and code structure understanding
# =============================================================================

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_treesitter")

analyze_treesitter() {
    local treesitter_path="$GIT_BASH_ROOT/home/portx/packages/treesitter/treesitter-parse.cmd"
    local gojq_path="/c/App/Git/home/portx/packages/gojq/gojq.exe"
    
    # Check if Tree-sitter is available
    if [[ ! -f "$treesitter_path" ]]; then
        return_error '{"analyzer":"treesitter","status":"tool_unavailable","details":"Tree-sitter executable not found at expected path"}'
        return
    fi
    
    if [[ ! -f "$FILE_PATH" ]]; then
        return_error '{"analyzer":"treesitter","status":"file_not_found","details":"Target file does not exist or is not readable"}'
        return
    fi
    
    local file_ext="${FILE_PATH##*.}"
    local language=""
    
    # Map file extensions to Tree-sitter languages
    case "$file_ext" in
        py|pyi) language="python" ;;
        js|jsx|mjs) language="javascript" ;;
        ts|tsx) language="typescript" ;;
        java) language="java" ;;
        c|h) language="c" ;;
        cc|cpp|cxx|hpp|hxx) language="cpp" ;;
        cs) language="c_sharp" ;;
        rs) language="rust" ;;
        go) language="go" ;;
        sh|bash) language="bash" ;;
        rb) language="ruby" ;;
        php) language="php" ;;
        html) language="html" ;;
        css) language="css" ;;
        json) language="json" ;;
        yaml|yml) language="yaml" ;;
        toml) language="toml" ;;
        sql) language="sql" ;;
        *) 
            return_error '{"analyzer":"treesitter","status":"unsupported_language","details":"File extension not supported by treesitter analyzer"}'
            return
            ;;
    esac
    
    # Generate enhanced JSON structure from treesitter output
    local tree_output
    if tree_output=$(timeout $ANALYZER_TIMEOUT "$treesitter_path" "$language" "$FILE_PATH" 2>/dev/null); then
        # Parse treesitter output to extract structured information
        local functions=() variables=() assignments=() classes=() imports=()
        local root_type="" children_count=0
        
        # Extract basic tree info
        root_type=$(echo "$tree_output" | grep "Root type:" | cut -d' ' -f3)
        children_count=$(echo "$tree_output" | grep "Children:" | cut -d' ' -f2)
        
        # Parse structure section to extract functions, variables, etc.
        while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            
            # Extract node type, line number, and content
            if [[ "$line" =~ ^[[:space:]]*([a-z_]+)[[:space:]]+\(line[[:space:]]+([0-9]+)\):[[:space:]]*(.+)$ ]]; then
                local node_type="${BASH_REMATCH[1]}"
                local line_num="${BASH_REMATCH[2]}"
                local content="${BASH_REMATCH[3]}"
                
                # Escape content for JSON
                local escaped_content
                escaped_content=$(printf '%s' "$content" | sed 's/\\/\\\\/g; s/"/\\"/g')
                
                case "$node_type" in
                    function_definition|method_declaration)
                        # Use safe JSON construction
                        local func_json
                        func_json=$(json_object \
                            "type" "$node_type" \
                            "line" "$line_num" \
                            "content" "$content")
                        functions+=("$func_json")
                        ;;
                    variable_assignment)
                        # Use safe JSON construction
                        local var_json
                        var_json=$(json_object \
                            "type" "variable_assignment" \
                            "line" "$line_num" \
                            "content" "$content")
                        assignments+=("$var_json")
                        ;;
                    class_definition|class_declaration)
                        # Use safe JSON construction
                        local class_json
                        class_json=$(json_object \
                            "type" "$node_type" \
                            "line" "$line_num" \
                            "content" "$content")
                        classes+=("$class_json")
                        ;;
                    import_statement|import_from_statement|import_declaration)
                        # Use safe JSON construction
                        local import_json
                        import_json=$(json_object \
                            "type" "$node_type" \
                            "line" "$line_num" \
                            "content" "$content")
                        imports+=("$import_json")
                        ;;
                esac
            fi
        done <<< "$(echo "$tree_output" | sed -n '/Structure.*items.*:/,$p' | tail -n +2)"
        
        # Build JSON arrays
        local functions_json="[$(IFS=,; echo "${functions[*]}")]"
        local assignments_json="[$(IFS=,; echo "${assignments[*]}")]"
        local classes_json="[$(IFS=,; echo "${classes[*]}")]"
        local imports_json="[$(IFS=,; echo "${imports[*]}")]"
        
        # Escape file path
        local escaped_file_path
        escaped_file_path=$(printf '%s' "${FILE_PATH}" | sed 's/\\/\\\\/g; s/"/\\"/g')
        
        # Generate comprehensive JSON output
        local success_json
        success_json=$(printf '{"analyzer":"treesitter","language":"%s","file":"%s","ast_available":true,"syntax_tree":{"root_type":"%s","children_count":%d,"total_nodes":%d},"code_elements":{"functions":%s,"variable_assignments":%s,"classes":%s,"imports":%s},"analysis_notes":"Enhanced treesitter with AST structure analysis"}' \
            "$language" \
            "$escaped_file_path" \
            "$root_type" \
            "$children_count" \
            "$(echo "$tree_output" | wc -l)" \
            "$functions_json" \
            "$assignments_json" \
            "$classes_json" \
            "$imports_json")
        return_success "$success_json"
    else
        return_error '{"analyzer":"treesitter","status":"parsing_failed","details":"Failed to parse AST - treesitter execution failed or timed out"}'
    fi
}