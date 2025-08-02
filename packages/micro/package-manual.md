# Micro Package Manual

## Package Information
- **Package Name**: micro
- **Category**: Development Tools
- **Type**: Terminal Text Editor
- **License**: MIT

## Description
Modern and intuitive terminal-based text editor with mouse support and familiar key bindings.

User-friendly terminal text editor designed for ease of use with common keyboard shortcuts, syntax highlighting, and extensible plugin system.
Perfect for users who want a simple yet powerful editing experience without modal complexity.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| micro.exe | Modern terminal text editor | Edit text files with intuitive interface |

## Common Usage Examples

### Basic File Operations
```bash
# Open file
micro file.txt

# Create new file
micro newfile.py

# Open multiple files
micro file1.txt file2.py file3.md

# Open directory (file browser)
micro .
```

### Reading from Standard Input
```bash
# Edit from stdin
echo "Hello World" | micro

# Edit command output
ls -la | micro

# Edit clipboard content
clip | micro
```

## Key Bindings

### Standard Shortcuts
```bash
# File operations
Ctrl+S          # Save file
Ctrl+O          # Open file
Ctrl+Q          # Quit
Ctrl+N          # New file
Ctrl+W          # Close current file

# Editing
Ctrl+Z          # Undo
Ctrl+Y          # Redo
Ctrl+C          # Copy
Ctrl+X          # Cut
Ctrl+V          # Paste
Ctrl+A          # Select all
```

### Navigation
```bash
# Cursor movement
Arrow keys      # Basic movement
Ctrl+Left/Right # Word jumping
Home/End        # Line beginning/end
Ctrl+Home/End   # File beginning/end
Page Up/Down    # Page navigation

# Go to line
Ctrl+G          # Go to line number
```

### Search and Replace
```bash
# Search
Ctrl+F          # Find
F3/Shift+F3     # Find next/previous
Ctrl+R          # Find and replace
Ctrl+H          # Replace

# Advanced search
Alt+R           # Toggle regex mode
Alt+C           # Toggle case sensitivity
Alt+W           # Toggle whole word
```

### Selection and Editing
```bash
# Selection
Shift+Arrow     # Extend selection
Ctrl+Shift+Left/Right # Select word
Ctrl+L          # Select line
Ctrl+A          # Select all

# Multiple cursors
Alt+Click       # Add cursor at position
Ctrl+D          # Select next occurrence
Ctrl+Shift+D    # Select all occurrences
```

## Advanced Features

### Multiple Panes
```bash
# Pane management
Ctrl+E          # Split horizontally
Ctrl+Shift+E    # Split vertically
Ctrl+W          # Close pane
Ctrl+Tab        # Next pane
Ctrl+Shift+Tab  # Previous pane
```

### Tabs
```bash
# Tab management
Ctrl+T          # New tab
Ctrl+W          # Close tab
Alt+Left/Right  # Switch tabs
Ctrl+Page Up/Down # Move tabs
```

### Terminal Integration
```bash
# Terminal operations
Ctrl+`          # Open terminal
F4              # Toggle terminal
Ctrl+Shift+T    # Run in terminal
```

## Syntax Highlighting

### Supported Languages
- **Programming**: Python, JavaScript, Java, C/C++, Go, Rust
- **Web**: HTML, CSS, PHP, TypeScript, React JSX
- **Configuration**: JSON, YAML, TOML, XML, INI
- **Markup**: Markdown, LaTeX, reStructuredText
- **Shell**: Bash, PowerShell, Batch, Fish
- **And 75+ more file types**

### Custom Syntax
```bash
# Custom syntax highlighting
# Place syntax files in ~/.config/micro/syntax/
# Supports TextMate-style grammar files
# Real-time syntax detection
```

## Plugin System

### Built-in Plugins
```bash
# File management
filemanager     # File browser sidebar
autofmt         # Auto-formatting
autoclose       # Auto-close brackets
comment         # Comment/uncomment

# Development tools
linter          # Code linting
go              # Go language support
python          # Python development
```

### Plugin Management
```bash
# Plugin commands (Ctrl+E to open command bar)
> plugin install linter
> plugin list
> plugin remove pluginname
> plugin update
> plugin search keyword
```

### Popular Plugins
```bash
# Install useful plugins
> plugin install filemanager
> plugin install linter
> plugin install autofmt
> plugin install jump
> plugin install manipulator
```

## Configuration

### Settings
```bash
# Open settings (Ctrl+E then type)
> set option value

# Common settings
> set tabsize 4
> set tabstospaces true
> set autoindent true
> set softwrap true
> set mouse true
> set clipboard external
```

### Configuration File (~/.config/micro/settings.json)
```json
{
    "autoclose": true,
    "autoindent": true,
    "autosave": 10,
    "clipboard": "external",
    "colorscheme": "monokai",
    "cursorline": true,
    "eofnewline": true,
    "fastdirty": false,
    "fileformat": "unix",
    "ignorecase": true,
    "indentchar": " ",
    "keepautoindent": false,
    "mouse": true,
    "pluginchannels": [
        "https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json"
    ],
    "pluginrepos": [],
    "ruler": true,
    "savecursor": false,
    "savehistory": true,
    "saveundo": false,
    "scrollbar": false,
    "scrollmargin": 3,
    "scrollspeed": 2,
    "softwrap": false,
    "splitbottom": true,
    "splitright": true,
    "statusformatl": "$(filename) $(modified)($(line),$(col)) $(status.paste)| ft:$(opt:filetype) | $(opt:fileformat) | $(opt:encoding)",
    "statusformatr": "$(bind:ToggleKeyMenu): bindings, $(bind:ToggleHelp): help",
    "statusline": true,
    "syntax": true,
    "tabmovement": false,
    "tabsize": 4,
    "tabstospaces": false,
    "termtitle": false,
    "useprimary": true
}
```

### Color Schemes
```bash
# Available themes
> set colorscheme monokai
> set colorscheme solarized
> set colorscheme dracula
> set colorscheme github
> set colorscheme atom-dark

# List all themes
> help colors
```

### Key Bindings Customization
```json
// ~/.config/micro/bindings.json
{
    "Alt+g": "command:goto",
    "Ctrl+r": "command:replaceall",
    "F1": "command:help",
    "F2": "command:save",
    "F3": "command:find",
    "Ctrl+/": "command:comment",
    "Ctrl+d": "command:duplicateline"
}
```

## Command System

### Command Bar
```bash
# Open command bar
Ctrl+E          # Open command mode

# Common commands
> save          # Save current file
> quit          # Quit micro
> find pattern  # Find text
> replace old new # Replace text
> goto 42       # Go to line 42
> set tabsize 2 # Change setting
```

### File Commands
```bash
> open file.txt     # Open file
> save filename     # Save as
> backup           # Create backup
> reload           # Reload from disk
> cd /path         # Change directory
```

### Edit Commands
```bash
> cut              # Cut selection
> copy             # Copy selection
> paste            # Paste
> duplicateline    # Duplicate current line
> deleteline       # Delete current line
> indent           # Indent selection
> outdent          # Unindent selection
```

## Development Features

### Code Formatting
```bash
# Auto-formatting (with autofmt plugin)
Ctrl+Shift+I    # Format document
> format        # Format current file

# Language-specific formatting
# Supports gofmt, prettier, autopep8, etc.
```

### Linting Integration
```bash
# Code linting (with linter plugin)
F8              # Next error
Shift+F8        # Previous error
> lint          # Run linter
> linter status # Show linter info
```

### Project Navigation
```bash
# File browser (with filemanager plugin)
Ctrl+B          # Toggle file browser
Enter           # Open selected file
Space           # Preview file
d               # Create directory
f               # Create file
```

## Workflow Integration

### Git Integration
```bash
# Git operations
> !git status      # Run git command
> !git add .       # Stage changes
> !git commit -m "message" # Commit
> terminal         # Open terminal for git
```

### External Tools
```bash
# Run external commands
> !command         # Execute command
> term command     # Run in terminal
> cd directory     # Change working directory
```

### Session Management
```bash
# Session features
- Automatic session saving
- Restore tabs on restart
- Cursor position memory
- Undo history persistence
```

## Use Cases

### Software Development
- Code editing with syntax highlighting
- Multi-file project management
- Integration with development tools
- Plugin ecosystem for language support

### System Administration
- Configuration file editing
- Log file analysis
- Script development
- Quick text manipulation

### General Text Editing
- Document writing and editing
- Note-taking and organization
- Data file manipulation
- Quick text processing

### Remote Development
- SSH-compatible terminal editing
- Lightweight resource usage
- Mouse support over SSH
- Familiar keyboard shortcuts

## Installation
Modern terminal text editor with intuitive interface and powerful features.
Designed for users who want simplicity without sacrificing functionality.

## Dependencies
None - standalone executable with built-in syntax highlighting and plugin system.

## Performance Features
- Fast startup time
- Efficient memory usage
- Responsive editing experience
- Optimized file handling
- Minimal system resource usage

---
*Part of PORTX Portable Development Environment*