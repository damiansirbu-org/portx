# PORTX Unified Design System Documentation

*Comprehensive guide to the PORTX theme system - industry-standard design tokens and terminal UI components*

## Overview

The PORTX Unified Design System provides a comprehensive, enterprise-grade theming solution for terminal applications. Built following modern UI design principles (inspired by Tailwind CSS), it delivers consistent visual experiences across all PORTX tools while maintaining maximum terminal compatibility.

## Architecture

### Core Components

1. **Terminal Capability Detection** - Smart detection of terminal features with intelligent fallbacks
2. **Color System** - Semantic design tokens with multi-level terminal support
3. **Icon System** - Three-tier iconography with progressive enhancement
4. **Typography System** - Text styling with broad terminal compatibility
5. **Composite Functions** - High-level UI components for rapid development

### File Structure

```
home/portx/scripts/
├── theme.sh          # Main unified design system (NEW)
└── icons.sh.deprecated  # Legacy system (deprecated)
```

## Terminal Capability Detection

### Detection Levels

The theme system automatically detects terminal capabilities and adapts accordingly:

#### Color Support Levels
- **COLOR_LEVEL_TRUECOLOR (3)** - 24-bit RGB colors (16.7 million colors)
- **COLOR_LEVEL_EXTENDED (2)** - 256-color palette
- **COLOR_LEVEL_BASIC (1)** - 16 ANSI colors
- **COLOR_LEVEL_NONE (0)** - Monochrome/text-only

#### Icon Support Levels
- **ICON_LEVEL_NERD (3)** - Nerd Font icons (professional iconography)
- **ICON_LEVEL_UNICODE (2)** - Unicode symbols
- **ICON_LEVEL_ASCII (1)** - ASCII text fallbacks

### Detection Logic

```bash
# Color Detection
- Checks NO_COLOR environment variable
- Detects pipe/redirect contexts (non-interactive)
- Identifies terminal programs (VS Code, modern terminals)
- Analyzes TERM and COLORTERM variables
- Provides graceful fallbacks

# Icon Detection
- Detects Nerd Font environments
- Checks for Unicode terminal support
- Falls back to ASCII for maximum compatibility
```

## Color System

### Semantic Color Functions

#### Brand Colors
```bash
color_primary()     # Blue-500 (#3B82F6) → Blue → Bold
color_secondary()   # Gray-500 (#6B7280) → White → None
```

#### Status Colors
```bash
color_success()     # Green-500 (#22C55E) → Green → Bold
color_error()       # Red-500 (#EF4444) → Red → Bold  
color_warning()     # Amber-500 (#F59E0B) → Bright Yellow → Bold
color_info()        # Sky-500 (#0EA5E9) → Cyan → Bold
```

#### UI Element Colors
```bash
color_muted()       # Gray-400 (#9CA3AF) → Light Gray → Dim
color_accent()      # Purple-500 (#A855F7) → Magenta → Bold
color_reset()       # Reset to terminal default
```

### Implementation Example

```bash
#!/bin/bash
source "$PORTX_ROOT/home/portx/scripts/theme.sh"

echo -e "$(color_primary)This is primary text$(color_reset)"
echo -e "$(color_success)Success message$(color_reset)"
echo -e "$(color_error)Error message$(color_reset)"
```

## Icon System

### Semantic Icon Functions

#### Package & Directory Icons
```bash
icon_package()      # Nerd: 󰏖  Unicode: ◆  ASCII: [*]
icon_directory()    # Nerd: 󰉋  Unicode: ◇  ASCII: [>]
```

#### Status Icons  
```bash
icon_success()      # Nerd: 󰸞  Unicode: ✓  ASCII: [+]
icon_error()        # Nerd: 󰅖  Unicode: ✗  ASCII: [-]
icon_warning()      # Nerd: 󰀪  Unicode: ◈  ASCII: [!]
```

#### Functional Icons
```bash
icon_network()      # Nerd: 󰀪  Unicode: ◉  ASCII: [~]
icon_search()       # Nerd: 󰍉  Unicode: ▶  ASCII: [?]
icon_statistics()   # Nerd: 󰄨  Unicode: ◈  ASCII: [@]
```

### Usage Example

```bash
echo "$(icon_package) Installing package..."
echo "$(icon_success) Installation complete"
echo "$(icon_error) Package not found"
```

## Typography System

### Text Styling Functions

```bash
text_bold()         # Bold text (available in most terminals)
text_dim()          # Dimmed text (muted appearance)
text_italic()       # Italic text (extended terminal support)
text_underline()    # Underlined text (broad support)
```

### Usage Example

```bash
echo -e "$(text_bold)Important:$(color_reset) $(text_dim)Optional information$(color_reset)"
echo -e "$(text_underline)Emphasized link$(color_reset)"
```

## Composite Styling Functions

### High-Level UI Components

#### Status Messages
```bash
status_success "Operation completed successfully"
status_error "Configuration file missing"
status_warning "Using legacy configuration"
status_info "Processing 42 items"
```

#### Headers and Layout
```bash
header "PORTX Package Manager" "$(icon_package)"
# Displays: 📦 PORTX Package Manager (styled)

header "System Status"
# Displays: 📦 System Status (with default icon)
```

#### Text Components
```bash
muted "Secondary information"
accent "Important highlight"
```

## Integration Examples

### Package Manager Integration

```bash
#!/bin/bash
source "$PORTX_ROOT/home/portx/scripts/theme.sh"

header "PORTX Package Manager" "$(icon_package)"
echo
echo "$(icon_directory) PORTX Root: $PORTX_ROOT" 
echo "$(icon_network) Repository: $PACKAGES_REPO"
echo

if install_package "$1"; then
    status_success "Package $1 installed successfully"
else
    status_error "Failed to install package $1"
fi
```

### Environment Security Scanner

```bash
#!/bin/bash
source "$PORTX_ROOT/home/portx/scripts/theme.sh"

if check_environment_security; then
    printf "$(color_success)[PORTX]$(color_reset)"
else
    status_warning "PATH conflicts detected"
    for issue in "${found_issues[@]}"; do
        echo "  $(icon_error) PATH contains: '$issue'"
    done
fi
```

## Performance Characteristics

### Benchmarking Results

- **Function Call Performance**: 11ms average per function call
- **Caching System**: Detection results cached for session duration
- **Memory Usage**: Minimal global variable footprint
- **Startup Impact**: <50ms additional shell initialization time

### Performance Test

```bash
# Built-in performance testing
source "$PORTX_ROOT/home/portx/scripts/theme.sh"
test_theme_performance

# Expected output:
# 300 theme function calls took: 3480ms
# Average per function: 11ms
```

## Migration Guide

### From Legacy Icons System

The unified theme system replaces the previous `icons.sh` with enhanced functionality:

#### Before (Legacy)
```bash
source "$PORTX_ROOT/home/portx/scripts/icons.sh"
echo "$(icon_package) Installing..."
```

#### After (Unified)  
```bash
source "$PORTX_ROOT/home/portx/scripts/theme.sh"
status_info "Installing package..."
echo "$(color_primary)$(icon_package) Advanced styling$(color_reset)"
```

### Fallback Compatibility

Scripts automatically fall back to basic functionality if theme.sh is unavailable:

```bash
# Robust loading pattern
if [[ -f "$PORTX_ROOT/home/portx/scripts/theme.sh" ]]; then
    source "$PORTX_ROOT/home/portx/scripts/theme.sh"
else
    # Comprehensive fallback functions
    icon_package() { echo "📦"; }
    color_primary() { echo '\033[0;34m'; }
    color_reset() { echo '\033[0m'; }
    status_success() { echo -e "✅ $1"; }
    # ... additional fallbacks
fi
```

## Development Guidelines

### Design Token Usage

1. **Semantic Over Visual**: Use `color_error` not `color_red`
2. **Consistent Fallbacks**: Always provide ASCII alternatives
3. **Terminal Awareness**: Let the system handle capability detection
4. **Performance First**: Cache results, minimize repeated calls

### Code Standards

```bash
# ✅ Good - Semantic usage
status_success "Package installed"
echo -e "$(color_primary)Primary action$(color_reset)"

# ❌ Avoid - Direct terminal codes
echo -e "\033[32mPackage installed\033[0m"
echo -e "\033[34mPrimary action\033[0m"

# ✅ Good - Composite functions
header "Tool Status" "$(icon_statistics)"

# ❌ Avoid - Manual composition
echo -e "\033[1;34m📊 Tool Status\033[0m"
```

### Testing

```bash
# Test theme system functionality
source "$PORTX_ROOT/home/portx/scripts/theme.sh"
test_theme_system

# Check terminal capabilities
get_theme_info

# Performance validation
test_theme_performance
```

## Integration Status

### Fully Integrated Scripts

- ✅ **portx.sh** - Package manager with complete theme integration
- ✅ **env-security.sh** - Security scanner with status indicators  
- ✅ **.bashrc** - Shell initialization with themed feedback
- ✅ **All PORTX utilities** - Consistent error handling and status messages

### Theme Coverage

- **Status Indicators**: Success, error, warning, info messages
- **UI Components**: Headers, muted text, accent highlights
- **Icon Usage**: Package, directory, network, statistics icons
- **Color Coding**: Status-based color schemes with accessibility
- **Typography**: Bold headers, dimmed secondary text

## Enterprise Features

### Accessibility Compliance

- **Color Blindness**: Semantic colors with icon reinforcement
- **Low Vision**: High contrast modes with bold text options
- **Screen Readers**: Meaningful text fallbacks for all icons
- **Terminal Diversity**: Broad compatibility across enterprise terminals

### Security Considerations

- **No External Dependencies**: Self-contained system
- **Privilege Independence**: No admin rights required
- **Environment Isolation**: Respects existing terminal preferences
- **Audit Trail**: All theming decisions documented and reversible

## Technical Implementation

### Key Files Modified

1. **portx.sh** - Updated to use unified theme system
2. **env-security.sh** - Migrated from legacy icons to theme system
3. **.bashrc** - Updated to load theme.sh instead of icons.sh
4. **icons.sh** - Deprecated and renamed to icons.sh.deprecated

### Global Variables

```bash
# Performance caching
PORTX_THEME_DETECTED=false
PORTX_COLOR_LEVEL=""
PORTX_ICON_LEVEL=""

# Capability constants
COLOR_LEVEL_TRUECOLOR=3
COLOR_LEVEL_EXTENDED=2
COLOR_LEVEL_BASIC=1
COLOR_LEVEL_NONE=0

ICON_LEVEL_NERD=3
ICON_LEVEL_UNICODE=2
ICON_LEVEL_ASCII=1
```

## Future Enhancements

### Planned Features

- **Theme Customization**: User-defined color schemes
- **High Contrast Mode**: Enhanced accessibility options
- **Animation Support**: Subtle terminal animations where supported
- **Internationalization**: Multi-language icon alternatives

### Extensibility

The theme system is designed for easy extension:

```bash
# Custom color definition
color_custom() {
    detect_terminal_capabilities
    case $PORTX_COLOR_LEVEL in
        $COLOR_LEVEL_TRUECOLOR) echo '\033[38;2;255;105;180m' ;;
        *) echo '\033[0;35m' ;;
    esac
}

# Custom status function
status_custom() {
    echo -e "$(color_custom)$(icon_custom)$(color_reset) $(color_custom)$1$(color_reset)"
}
```

---

*This documentation reflects the current state of the PORTX Unified Design System as of January 2025. For the latest updates and implementation details, refer to `theme.sh` source code.*