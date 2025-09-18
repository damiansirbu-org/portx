#!/bin/bash
# Simple test execution script for analyzer validation
# This file is used as a test case for shell script analysis

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$SCRIPT_DIR/test_execution.log"

# Basic logging function
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" | tee -a "$LOG_FILE"
}

# Initialize test environment
initialize_test_environment() {
    log_info "Initializing test environment..."
    
    # Create necessary directories
    local dirs=("logs" "tmp" "results")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
            mkdir -p "$SCRIPT_DIR/$dir"
        fi
    done
    
    # Initialize log file
    echo "# Test Execution Log - $(date)" > "$LOG_FILE"
}

# Run a specific test
run_test() {
    local test_name="$1"
    local test_file="$2"
    
    log_info "Running test: $test_name"
    
    if [[ -f "$test_file" ]]; then
        "$test_file" && log_info "Test passed: $test_name" || log_info "Test failed: $test_name"
    else
        log_info "Test file not found: $test_file"
    fi
}

# Main execution function
main() {
    initialize_test_environment
    
    # Run basic tests
    run_test "unit_tests" "$SCRIPT_DIR/unit_tests.sh"
    run_test "integration_tests" "$SCRIPT_DIR/integration_tests.sh"
    
    log_info "Test execution completed"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi