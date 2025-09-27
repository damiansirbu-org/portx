#!/bin/bash
# PORTX Universal Wrapper Build Script
# Compiles the Go wrapper executable

WRAPPER_NAME="portx-wrap"

# Detect environment for display
detect_environment() {
    if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
        echo "wsl"
    elif [[ -n "${MSYSTEM:-}" ]]; then
        echo "msys2"
    elif [[ -n "${CYGWIN:-}" ]] || echo "$PATH" | grep -q cygwin; then
        echo "cygwin"
    elif [[ "$OS" == "Windows_NT" ]]; then
        echo "windows"
    else
        echo "unix"
    fi
}

# Build the Go wrapper
build_wrapper() {
    local env_type="$1"

    echo "Building PORTX wrapper for $env_type..."

    # Change to script directory
    cd "$(dirname "$0")"

    # Initialize Go module if needed
    if [[ ! -f go.mod ]]; then
        echo "Initializing Go module..."
        go mod init portx-wrap
        go mod tidy
    fi

    # Build with optimizations
    echo "Compiling Go wrapper..."
    CGO_ENABLED=0 go build -ldflags="-s -w -X main.version=$(date +%Y%m%d-%H%M%S)" \
        -o "target/${WRAPPER_NAME}.exe" *.go

    if [[ ! -f "target/${WRAPPER_NAME}.exe" ]]; then
        echo "ERROR: Failed to build wrapper"
        return 1
    fi

    echo "✓ Wrapper built successfully: target/${WRAPPER_NAME}.exe"
    return 0
}

# Test the compiled binary
test_binary() {
    echo "Testing compiled binary..."

    if [[ ! -f "target/${WRAPPER_NAME}.exe" ]]; then
        echo "ERROR: Binary not found"
        return 1
    fi

    # Test basic execution
    if ./target/"${WRAPPER_NAME}.exe" --help >/dev/null 2>&1; then
        echo "✓ Binary responds to --help"
    else
        echo "⚠ Binary --help test failed"
    fi

    # Show binary info
    echo "✓ Binary size: $(ls -lh "target/${WRAPPER_NAME}.exe" | awk '{print $5}')"
    echo "✓ Binary path: $(pwd)/target/${WRAPPER_NAME}.exe"

    return 0
}

# Main build function
main() {
    echo "=================================================="
    echo "PORTX Universal Wrapper Build"
    echo "=================================================="

    # Check requirements
    if ! command -v go >/dev/null 2>&1; then
        echo "ERROR: Go is required but not installed"
        return 1
    fi

    # Detect environment
    env_type=$(detect_environment)
    echo "Detected environment: $env_type"

    # Check source files
    if [[ ! -f "main.go" ]]; then
        echo "ERROR: main.go not found in current directory"
        return 1
    fi

    if [[ ! -f "config/tool-configs.json" ]]; then
        echo "ERROR: config/tool-configs.json not found"
        return 1
    fi

    # Build
    if ! build_wrapper "$env_type"; then
        echo "ERROR: Build failed"
        return 1
    fi

    # Test
    test_binary

    echo "=================================================="
    echo "✓ PORTX Universal Wrapper built successfully!"
    echo "Environment: $env_type"
    echo "Binary: $(pwd)/target/${WRAPPER_NAME}.exe"
    echo ""
    echo "Test manually with:"
    echo "  ./target/${WRAPPER_NAME}.exe git --version"
    echo "  ./target/${WRAPPER_NAME}.exe rg --help"
    echo "=================================================="

    return 0
}

# Run with error handling
if ! main "$@"; then
    echo "ERROR: Build failed"
    exit 1
fi