#!/bin/bash

# PathX Build System
# Organized build for path conversion tool with proper directory structure

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$PROJECT_ROOT/src"
BIN_DIR="$PROJECT_ROOT/bin"
CONFIG_DIR="$PROJECT_ROOT/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building PathX...${NC}"

# Ensure directories exist
mkdir -p "$BIN_DIR" "$CONFIG_DIR"

# Clean previous builds
echo "Cleaning previous builds..."
rm -f "$BIN_DIR/pathx.exe" "$BIN_DIR/tool-exceptions.json"

# Run unit tests first (from src directory)
echo -e "${YELLOW}Running unit tests...${NC}"
cd "$SRC_DIR"
if go test -v .; then
    echo -e "${GREEN}All tests passed${NC}"
else
    echo -e "${RED}Tests failed - build aborted${NC}"
    exit 1
fi

# Build PathX executable to bin directory
echo "Building PathX executable..."
if go build -o "$BIN_DIR/pathx.exe" .; then
    echo -e "${GREEN}PathX built successfully${NC}"
else
    echo -e "${RED}Build failed${NC}"
    exit 1
fi

# Copy tool-exceptions.json from config to bin directory
echo "Copying runtime config to bin directory..."
if [[ -f "$CONFIG_DIR/tool-exceptions.json" ]]; then
    cp "$CONFIG_DIR/tool-exceptions.json" "$BIN_DIR/"
    echo -e "${GREEN}Config copied to bin directory${NC}"
else
    echo -e "${RED}tool-exceptions.json missing from config directory${NC}"
    exit 1
fi

echo "Executable: $BIN_DIR/pathx.exe"
echo "Config: $BIN_DIR/tool-exceptions.json"

# Test basic functionality
echo -e "${YELLOW}Testing basic functionality...${NC}"
if "$BIN_DIR/pathx.exe" --help > /dev/null 2>&1; then
    echo -e "${GREEN}PathX executable working${NC}"
else
    echo -e "${RED}PathX executable failed basic test${NC}"
    exit 1
fi

echo -e "${GREEN}PathX build complete!${NC}"
echo ""
echo "Directory structure:"
echo "  bin/pathx.exe                - Executable"
echo "  bin/tool-exceptions.json     - Runtime config (copied from config/)"
echo "  src/                         - Source code"
echo "  config/                      - Original config and schema"
echo "  scripts/                     - Validation scripts"