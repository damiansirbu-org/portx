#!/bin/bash
# =============================================================================
# DPRINT ANALYZER - Code Formatter and Style Checker
# Validates formatting for JavaScript, TypeScript, JSON, Markdown files
# =============================================================================

analyze_dprint() {
    local dprint_path="$GIT_BASH_ROOT/home/portx/packages/dprint/dprint.exe"
    
    echo "=== DPRINT FORMATTING ANALYSIS ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    # Check if dprint is available
    if [[ ! -f "$dprint_path" ]]; then
        echo "Dprint not available at $dprint_path"
        echo "Please install dprint for formatting validation"
        return 1
    fi
    
    local file_ext="${FILE_PATH##*.}"
    
    # Check if file type is supported
    case "$file_ext" in
        js|jsx|ts|tsx|json|md|markdown)
            echo "File type supported: $file_ext"
            ;;
        *)
            echo "File type not supported by dprint: $file_ext"
            echo "Supported: js, jsx, ts, tsx, json, md, markdown"
            return 1
            ;;
    esac
    
    if [[ ! -f "$FILE_PATH" ]]; then
        echo "File not found: $FILE_PATH"
        return 1
    fi
    
    echo "Checking formatting..."
    local dprint_output
    
    # Run dprint check
    if timeout $ANALYZER_TIMEOUT "$dprint_path" check "$FILE_PATH" 2>/dev/null >/dev/null; then
        echo "✅ File is properly formatted"
        
        # Show formatting stats
        echo
        echo "File formatting details:"
        local line_count
        line_count=$(wc -l < "$FILE_PATH" 2>/dev/null || echo "0")
        echo "• Total lines: $line_count"
        
        # Check for common formatting issues manually
        local issues_found=false
        
        case "$file_ext" in
            js|jsx|ts|tsx)
                if grep -q "	" "$FILE_PATH" 2>/dev/null; then
                    echo "• Contains tabs (dprint prefers spaces)"
                    issues_found=true
                fi
                if grep -q " $" "$FILE_PATH" 2>/dev/null; then
                    echo "• Contains trailing spaces"
                    issues_found=true
                fi
                ;;
            json)
                if ! timeout 5 "$GOJQ_PATH" empty "$FILE_PATH" 2>/dev/null; then
                    echo "• JSON syntax issues detected"
                    issues_found=true
                fi
                ;;
        esac
        
        if [[ "$issues_found" != true ]]; then
            echo "• No formatting issues detected"
        fi
        
    else
        echo "❌ Formatting issues detected"
        echo
        echo "To see detailed differences, run:"
        echo "dprint fmt --diff \"$FILE_PATH\""
        echo
        echo "To auto-fix formatting, run:"
        echo "dprint fmt \"$FILE_PATH\""
        
        # Try to show some formatting issues
        echo
        echo "Common formatting issues:"
        if grep -n "	" "$FILE_PATH" 2>/dev/null | head -3; then
            echo "• Found tabs (should be spaces)"
        fi
        if grep -n " $" "$FILE_PATH" 2>/dev/null | head -3; then
            echo "• Found trailing spaces"
        fi
    fi
    
    echo
    echo "Dprint formatting rules checked:"
    case "$file_ext" in
        js|jsx|ts|tsx)
            echo "• Indentation (2 spaces)"
            echo "• Semicolons and quotes consistency"
            echo "• Line length limits"
            echo "• Object/array formatting"
            ;;
        json)
            echo "• JSON structure validation"
            echo "• Indentation consistency"
            echo "• Quote formatting"
            ;;
        md|markdown)
            echo "• Markdown syntax"
            echo "• Link formatting"
            echo "• Code block formatting"
            ;;
    esac
    
    echo
    return 0
}