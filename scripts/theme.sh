#!/bin/bash
# PORTX Minimal Theme System - White, gray, dimmed blue/red only
# Icons: ◆ ◈ ◇ geometric symbols instead of emojis

# Prevent multiple loading
export PORTX_MINIMAL_THEME_LOADED=1

# Constants - Always set to avoid unbound variable errors
if [[ -z "${PORTX_THEME_CONSTANTS_SET:-}" ]]; then
    declare -gr COLOR_LEVEL_NONE=0
    declare -gr COLOR_LEVEL_BASIC=1
    declare -gr COLOR_LEVEL_EXTENDED=2
    declare -gr COLOR_LEVEL_TRUECOLOR=3
    declare -gr ICON_LEVEL_ASCII=1
    declare -gr ICON_LEVEL_UNICODE=2
    declare -gr ICON_LEVEL_NERD=3
    export PORTX_THEME_CONSTANTS_SET=1
fi

# Global variables
PORTX_THEME_DETECTED=""
PORTX_COLOR_LEVEL=""
PORTX_ICON_LEVEL=""

# Capability detection
_detect_color_support() {
    [[ -n "$PORTX_COLOR_LEVEL" ]] && return
    
    # Ensure constants are initialized
    if [[ -z "${PORTX_THEME_CONSTANTS_SET:-}" ]]; then
        declare -gr COLOR_LEVEL_NONE=0
        declare -gr COLOR_LEVEL_BASIC=1
        declare -gr COLOR_LEVEL_EXTENDED=2
        declare -gr COLOR_LEVEL_TRUECOLOR=3
        export PORTX_THEME_CONSTANTS_SET=1
    fi
    
    if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 1 ]] || [[ "$TERM" == "dumb" ]]; then
        PORTX_COLOR_LEVEL=${COLOR_LEVEL_NONE:-0}
    elif [[ "$COLORTERM" =~ (truecolor|24bit) ]] || [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
        PORTX_COLOR_LEVEL=${COLOR_LEVEL_TRUECOLOR:-3}
    elif [[ "$TERM" =~ 256color ]] || [[ "$TERM" =~ (xterm|screen|tmux) ]]; then
        PORTX_COLOR_LEVEL=${COLOR_LEVEL_EXTENDED:-2}
    elif [[ "$TERM" =~ (xterm|screen|ansi|vt) ]]; then
        PORTX_COLOR_LEVEL=${COLOR_LEVEL_BASIC:-1}
    else
        PORTX_COLOR_LEVEL=${COLOR_LEVEL_NONE:-0}
    fi
}

_detect_icon_support() {
    [[ -n "$PORTX_ICON_LEVEL" ]] && return
    
    # Ensure icon constants are initialized
    if [[ -z "${PORTX_THEME_CONSTANTS_SET:-}" ]]; then
        declare -gr ICON_LEVEL_ASCII=1
        declare -gr ICON_LEVEL_UNICODE=2
        declare -gr ICON_LEVEL_NERD=3
        export PORTX_THEME_CONSTANTS_SET=1
    fi
    
    if [[ "${TERM_PROGRAM:-}" == "vscode" ]] || [[ -n "${NERD_FONT:-}" ]]; then
        PORTX_ICON_LEVEL=${ICON_LEVEL_NERD:-3}
    elif [[ "$TERM" =~ (xterm|screen|tmux) ]] || [[ -n "$COLORTERM" ]]; then
        PORTX_ICON_LEVEL=${ICON_LEVEL_UNICODE:-2}
    else
        PORTX_ICON_LEVEL=${ICON_LEVEL_ASCII:-1}
    fi
}

detect_terminal_capabilities() {
    [[ "$PORTX_THEME_DETECTED" == "true" ]] && return
    _detect_color_support
    _detect_icon_support
    PORTX_THEME_DETECTED="true"
}

# MINIMAL COLORS - only white, gray, dimmed blue/red
color_primary() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[37m' ;;  # White (primary text)
    esac
}

color_secondary() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[90m' ;;  # Gray (secondary/muted text)
    esac
}

color_success() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[90m' ;;  # Dim gray (minimal)
    esac
}

color_error() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[1;31m' ;;  # Bright red
    esac
}

color_warning() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[93m' ;;  # Bright yellow
    esac
}

color_info() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[90m' ;;  # Gray (no more blue)
    esac
}

color_muted() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[90m' ;;  # Dim gray
    esac
}

color_accent() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[37m' ;;  # White
    esac
}

color_pale_blue() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[94m' ;;  # Pale blue for package names
    esac
}

color_pale_green() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        *) echo $'\033[92m' ;;  # Pale green for success messages
    esac
}

color_reset() {
    echo $'\033[0m'
}

# GEOMETRIC ICONS - ◆ ◈ ◇
icon_package() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font package
        ${ICON_LEVEL_UNICODE:-2}) echo '📦' ;;  # Unicode package
        *) echo '[*]' ;;
    esac
}

icon_statistics() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font tools
        ${ICON_LEVEL_UNICODE:-2}) echo '⚙️' ;;  # Unicode gear
        *) echo '[@]' ;;
    esac
}

icon_success() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}|${ICON_LEVEL_UNICODE:-2}) echo '◈' ;;
        *) echo '[+]' ;;
    esac
}

icon_error() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}|${ICON_LEVEL_UNICODE:-2}) echo '◆' ;;
        *) echo '[-]' ;;
    esac
}

icon_warning() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}|${ICON_LEVEL_UNICODE:-2}) echo '◇' ;;
        *) echo '[!]' ;;
    esac
}

icon_directory() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}|${ICON_LEVEL_UNICODE:-2}) echo '◇' ;;
        *) echo '[>]' ;;
    esac
}

icon_network() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font network
        ${ICON_LEVEL_UNICODE:-2}) echo '🌐' ;;  # Unicode globe
        *) echo '[~]' ;;
    esac
}

icon_search() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font search
        ${ICON_LEVEL_UNICODE:-2}) echo '🔍' ;;  # Unicode magnifying glass
        *) echo '[?]' ;;
    esac
}

icon_computer() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font computer
        ${ICON_LEVEL_UNICODE:-2}) echo '💻' ;;  # Unicode laptop
        *) echo '[PC]' ;;
    esac
}

icon_ssh() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font key
        ${ICON_LEVEL_UNICODE:-2}) echo '🔑' ;;  # Unicode key
        *) echo '[SSH]' ;;
    esac
}

icon_tools() {
    detect_terminal_capabilities
    case $PORTX_ICON_LEVEL in
        ${ICON_LEVEL_NERD:-3}) echo '' ;;  # Nerd font wrench
        ${ICON_LEVEL_UNICODE:-2}) echo '🔧' ;;  # Unicode wrench
        *) echo '[TOOLS]' ;;
    esac
}

# Formatting functions - separate data from presentation
format_portx_status() {
    local env_info="${PORTX_ENV_TYPE:-unknown}"
    printf '%bPortx%b%b[%s]%b' "$(color_info)" "$(color_reset)" "$(color_muted)" "${env_info,,}" "$(color_reset)"
}

format_tools_status() {
    local gfw_dirs="${GFW_DIRS:-0}"
    local gfw_execs="${GFW_EXECUTABLES:-0}"
    local pkg_dirs="${PORTX_PKG_DIRS:-0}"
    local pkg_execs="${PORTX_PKG_EXECUTABLES:-0}"
    
    printf '%bTools[gfw:%d/%d, pkg:%d/%d]%b' \
        "$(color_muted)" \
        "$gfw_dirs" "$gfw_execs" \
        "$pkg_dirs" "$pkg_execs" \
        "$(color_reset)"
}

format_ssh_status() {
    local ssh_user="${PORTX_SSH_USER:-}"
    local ssh_status="${PORTX_SSH_STATUS:-}"
    
    if [[ -n "$ssh_user" ]]; then
        printf '%bSsh%b%b[%s]%b' "$(color_info)" "$(color_reset)" "$(color_muted)" "$ssh_user" "$(color_reset)"
    elif [[ -n "$ssh_status" ]]; then
        printf '%bSsh%b%b[%s]%b' "$(color_info)" "$(color_reset)" "$(color_muted)" "$ssh_status" "$(color_reset)"
    fi
}

# Typography
text_bold() { echo '\033[1m'; }
text_dim() { echo '\033[2m'; }
text_italic() { echo '\033[3m'; }
text_underline() { echo '\033[4m'; }

# Composite functions
status_success() {
    echo -e "$(color_muted)$(icon_success)$(color_reset) $(color_secondary)$1$(color_reset)"
}

status_error() {
    echo -e "$(color_error)$(icon_error)$(color_reset) $(color_error)$1$(color_reset)"
}

status_warning() {
    echo -e "$(color_muted)$(icon_warning)$(color_reset) $(color_muted)$1$(color_reset)"
}

status_info() {
    echo -e "$(color_muted)$(icon_package)$(color_reset) $(color_muted)$1$(color_reset)"
}

header() {
    local title="$1"
    local icon="${2:-$(icon_package)}"
    echo -e "$(color_muted)$icon$(color_reset) $(color_secondary)$title$(color_reset)"
}

muted() {
    echo -e "$(color_muted)$1$(color_reset)"
}

accent() {
    echo -e "$(color_accent)$1$(color_reset)"
}

# Test functions
test_theme_system() {
    echo "PORTX Minimal Theme:"
    echo "$(status_info 'Scanning packages')"
    echo "$(header 'PORTX Tools Inventory' '$(icon_statistics)')"
}

get_theme_info() {
    detect_terminal_capabilities
    echo "Minimal - Colors: $PORTX_COLOR_LEVEL, Icons: $PORTX_ICON_LEVEL"
}

test_theme_performance() {
    local start=$(date +%s%3N)
    for i in {1..100}; do color_primary >/dev/null; done
    local end=$(date +%s%3N)
    echo "100 calls: $((end - start))ms"
}
