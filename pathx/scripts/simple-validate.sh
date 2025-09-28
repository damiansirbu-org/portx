#!/bin/bash

# Simple PathX Tool Exceptions Validation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCEPTIONS_FILE="$SCRIPT_DIR/tool-exceptions.json"

echo "🔍 Simple validation of PathX tool exceptions..."

# Check JSON syntax
if ! gojq empty "$EXCEPTIONS_FILE" >/dev/null 2>&1; then
    echo "❌ Error: Invalid JSON syntax"
    exit 1
fi

# Check required top-level fields
SCHEMA_VERSION=$(gojq -r '._schema_version' "$EXCEPTIONS_FILE")
INPUT_COUNT=$(gojq -r '.input_exceptions | keys | length' "$EXCEPTIONS_FILE")
OUTPUT_COUNT=$(gojq -r '.output_exceptions | keys | length' "$EXCEPTIONS_FILE")

echo "✅ JSON syntax valid"
echo "📊 Schema version: $SCHEMA_VERSION"
echo "📊 Input exception tools: $((INPUT_COUNT - 1))"  # Subtract 1 for _description
echo "📊 Output exception categories: $((OUTPUT_COUNT - 1))"  # Subtract 1 for _description

# List all input tools
echo ""
echo "🔧 Input exception tools:"
gojq -r '.input_exceptions | keys[] | select(startswith("_") | not) | "  - " + .' "$EXCEPTIONS_FILE"

echo ""
echo "🔄 Output exception categories:"
gojq -r '.output_exceptions | keys[] | select(startswith("_") | not) | "  - " + .' "$EXCEPTIONS_FILE"

echo ""
echo "🎉 Basic validation passed!"