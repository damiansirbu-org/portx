#!/bin/bash

# PathX Tool Exceptions Validation Script
# Validates tool-exceptions.json against its schema

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCEPTIONS_FILE="$SCRIPT_DIR/tool-exceptions.json"
SCHEMA_FILE="$SCRIPT_DIR/tool-exceptions.schema.json"

echo "🔍 Validating PathX tool exceptions..."

# Check if files exist
if [[ ! -f "$EXCEPTIONS_FILE" ]]; then
    echo "❌ Error: tool-exceptions.json not found"
    exit 1
fi

if [[ ! -f "$SCHEMA_FILE" ]]; then
    echo "❌ Error: tool-exceptions.schema.json not found"
    exit 1
fi

# Check if gojq is available
if ! command -v gojq >/dev/null 2>&1; then
    echo "❌ Error: gojq is required for JSON validation"
    echo "Please install gojq from: https://github.com/itchyny/gojq"
    exit 1
fi

# Validate JSON syntax
echo "📋 Checking JSON syntax..."
if ! gojq empty "$EXCEPTIONS_FILE" >/dev/null 2>&1; then
    echo "❌ Error: Invalid JSON syntax in tool-exceptions.json"
    gojq empty "$EXCEPTIONS_FILE"
    exit 1
fi

if ! gojq empty "$SCHEMA_FILE" >/dev/null 2>&1; then
    echo "❌ Error: Invalid JSON syntax in tool-exceptions.schema.json"
    gojq empty "$SCHEMA_FILE"
    exit 1
fi

echo "✅ JSON syntax valid"

# Basic structure validation
echo "🔧 Checking required fields..."

# Check schema version
SCHEMA_VERSION=$(gojq -r '._schema_version' "$EXCEPTIONS_FILE")
if [[ "$SCHEMA_VERSION" == "null" || "$SCHEMA_VERSION" == "" ]]; then
    echo "❌ Error: Missing _schema_version field"
    exit 1
fi

if [[ ! "$SCHEMA_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Invalid schema version format: $SCHEMA_VERSION"
    exit 1
fi

# Check input_exceptions
if [[ "$(gojq -r '.input_exceptions | type' "$EXCEPTIONS_FILE")" != "object" ]]; then
    echo "❌ Error: input_exceptions must be an object"
    exit 1
fi

# Check output_exceptions
if [[ "$(gojq -r '.output_exceptions | type' "$EXCEPTIONS_FILE")" != "object" ]]; then
    echo "❌ Error: output_exceptions must be an object"
    exit 1
fi

echo "✅ Required fields present"

# Validate input exception rules
echo "⚙️  Validating input exception rules..."
INPUT_TOOLS=$(gojq -r '.input_exceptions | keys[] | select(startswith("_") | not)' "$EXCEPTIONS_FILE")
while IFS= read -r tool; do
    if [[ -n "$tool" ]]; then
        echo "  Checking input rules for: $tool"

        # Check required arrays exist
        for field in "never_convert_after_flags" "never_convert_at_positions" "never_convert_patterns"; do
            if [[ "$(gojq -r ".input_exceptions[\"$tool\"].$field | type" "$EXCEPTIONS_FILE")" != "array" ]]; then
                echo "❌ Error: $tool.$field must be an array"
                exit 1
            fi
        done

        # Validate position values are integers >= 0
        POSITIONS=$(gojq -r ".input_exceptions[\"$tool\"].never_convert_at_positions[]?" "$EXCEPTIONS_FILE")
        while IFS= read -r pos; do
            if [[ -n "$pos" && ! "$pos" =~ ^[0-9]+$ ]]; then
                echo "❌ Error: $tool.never_convert_at_positions contains non-integer: $pos"
                exit 1
            fi
        done <<< "$POSITIONS"
    fi
done <<< "$INPUT_TOOLS"

echo "✅ Input exception rules valid"

# Validate output exception rules
echo "🔄 Validating output exception rules..."
OUTPUT_CATEGORIES=$(gojq -r '.output_exceptions | keys[] | select(startswith("_") | not)' "$EXCEPTIONS_FILE")
while IFS= read -r category; do
    if [[ -n "$category" ]]; then
        echo "  Checking output rules for: $category"

        # Check tools array exists and is not empty
        if [[ "$(gojq -r ".output_exceptions[\"$category\"].tools | type" "$EXCEPTIONS_FILE")" != "array" ]]; then
            echo "❌ Error: $category.tools must be an array"
            exit 1
        fi

        TOOL_COUNT=$(gojq -r ".output_exceptions[\"$category\"].tools | length" "$EXCEPTIONS_FILE")
        if [[ "$TOOL_COUNT" -eq 0 ]]; then
            echo "❌ Error: $category.tools cannot be empty"
            exit 1
        fi

        # Check mutually exclusive flags
        HAS_DIRECT_IO=$(gojq -r ".output_exceptions[\"$category\"].force_direct_io != null" "$EXCEPTIONS_FILE")
        HAS_CONVERT_ALL=$(gojq -r ".output_exceptions[\"$category\"].convert_all_paths != null" "$EXCEPTIONS_FILE")
        HAS_CONVERT_PATHS=$(gojq -r ".output_exceptions[\"$category\"].convert_paths_only != null" "$EXCEPTIONS_FILE")

        RULE_COUNT=0
        [[ "$HAS_DIRECT_IO" == "true" ]] && ((RULE_COUNT++))
        [[ "$HAS_CONVERT_ALL" == "true" ]] && ((RULE_COUNT++))
        [[ "$HAS_CONVERT_PATHS" == "true" ]] && ((RULE_COUNT++))

        if [[ $RULE_COUNT -ne 1 ]]; then
            echo "❌ Error: $category must have exactly one of: force_direct_io, convert_all_paths, convert_paths_only"
            exit 1
        fi
    fi
done <<< "$OUTPUT_CATEGORIES"

echo "✅ Output exception rules valid"

# Summary statistics
echo ""
echo "📊 Validation Summary:"
echo "Schema version: $SCHEMA_VERSION"
echo "Input exceptions: $(echo "$INPUT_TOOLS" | grep -c . || echo 0) tools"
echo "Output exceptions: $(echo "$OUTPUT_CATEGORIES" | grep -c . || echo 0) categories"

TOTAL_OUTPUT_TOOLS=0
while IFS= read -r category; do
    if [[ -n "$category" ]]; then
        COUNT=$(gojq -r ".output_exceptions[\"$category\"].tools | length" "$EXCEPTIONS_FILE")
        TOTAL_OUTPUT_TOOLS=$((TOTAL_OUTPUT_TOOLS + COUNT))
    fi
done <<< "$OUTPUT_CATEGORIES"

echo "Total tools with output rules: $TOTAL_OUTPUT_TOOLS"
echo ""
echo "🎉 tool-exceptions.json validation passed!"