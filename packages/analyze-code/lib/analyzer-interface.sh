#!/bin/bash
# =============================================================================
# ANALYZER INTERFACE - Communication Functions
# Standardized functions for analyzer-to-orchestrator communication
# =============================================================================

# Return successful analysis result
return_success() {
    local output="$1"
    echo "{\"output\":$output,\"return_code\":\"SUCCESS\"}"
}

# Return error result
return_error() {
    local output="$1"
    echo "{\"output\":$output,\"return_code\":\"ERROR\"}"
}

# Return generic result (for backward compatibility)
return_result() {
    local output="$1"
    local code="${2:-SUCCESS}"
    echo "{\"output\":$output,\"return_code\":\"$code\"}"
}
