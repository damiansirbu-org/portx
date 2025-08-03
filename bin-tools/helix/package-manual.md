# Helix Package Manual

## Package Information
- **Package Name**: helix
- **Category**: Development Tools
- **Type**: Terminal Text Editor
- **License**: MPL 2.0

## Description
Modern terminal-based text editor with built-in language server support and multiple selections.

Post-modern text editor with tree-sitter syntax highlighting, language server protocol integration, and powerful editing features.
Designed for efficient code editing with modal editing and advanced text manipulation capabilities.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| hx.exe | Helix text editor | Advanced terminal-based code editor with LSP support |

## Common Usage Examples

### Basic File Operations
```bash
# Open file
hx file.txt

# Open multiple files
hx file1.py file2.js file3.md

# Create new file
hx new_file.txt

# Open directory (file picker)
hx .
hx /path/to/project/
```

### Editing Modes and Navigation
```bash
# Normal mode (default)
# - Navigation with h/j/k/l
# - Commands with :
# - Search with /

# Insert mode
# Press 'i' to enter insert mode
# Press Esc to return to normal mode

# Select mode
# Press 'v' for character selection
# Press 'V' for line selection
# Press Ctrl+v for block selection
```

## Key Bindings

### Movement
```bash
# Character movement
h, j, k, l      # Left, down, up, right
w, b, e         # Word forward, backward, end
0, $            # Line start, end
gg, G           # File start, end

# Line movement
H, M, L         # Screen top, middle, bottom
Ctrl+u, Ctrl+d  # Page up, down
Ctrl+b, Ctrl+f  # Full page up, down
```

### Selection
```bash
# Selection modes
v               # Select characters
V               # Select lines
Ctrl+v          # Block selection
x               # Select line
X               # Select to line boundary

# Extend selection
;               # Shrink selection
Alt+;           # Flip selection
%               # Select entire file
```

### Editing
```bash
# Insert modes
i               # Insert before cursor
a               # Insert after cursor
I               # Insert at line start
A               # Insert at line end
o               # New line below
O               # New line above

# Deletion
d               # Delete selection
dd              # Delete line
c               # Change selection
r               # Replace character
s               # Substitute selection
```

### Search and Replace
```bash
# Search
/               # Search forward
?               # Search backward
n               # Next match
N               # Previous match
*               # Search word under cursor

# Replace
:s/old/new      # Replace in selection
:s/old/new/g    # Replace all in selection
:%s/old/new/g   # Replace all in file
```

### Multiple Cursors
```bash
# Multiple selections
C               # Copy selection to next line
Alt+C           # Copy selection to previous line
s               # Select next occurrence
S               # Split selection on regex
Alt+s           # Split selection on lines
&               # Align selections
```

### File Management
```bash
# File operations
:w              # Save file
:w filename     # Save as
:q              # Quit
:q!             # Quit without saving
:wq             # Save and quit

# Buffer management
:buffer-next    # Next buffer
:buffer-previous # Previous buffer
:buffer-close   # Close buffer
Space+b         # Buffer picker
```

### Window Management
```bash
# Split windows
:vsplit         # Vertical split
:hsplit         # Horizontal split
Ctrl+w v        # Vertical split
Ctrl+w s        # Horizontal split

# Navigate splits
Ctrl+w h/j/k/l  # Move between splits
Ctrl+w q        # Close split
Ctrl+w o        # Close other splits
```

## Language Server Protocol (LSP)

### Code Intelligence
```bash
# Go to definition
gd              # Go to definition
gD              # Go to declaration
gr              # Go to references
gi              # Go to implementation

# Hover information
K               # Show hover information
Space+k         # Show signature help

# Diagnostics
]d              # Next diagnostic
[d              # Previous diagnostic
Space+e         # Show diagnostics
```

### Code Actions
```bash
# LSP actions
Space+a         # Code actions
Space+r         # Rename symbol
Space+f         # Format document
Space+F         # Format selection

# Auto-completion
Ctrl+n          # Next completion
Ctrl+p          # Previous completion
Tab             # Accept completion
```

### Workspace Operations
```bash
# File navigation
Space+f         # File picker
Space+F         # File picker (include hidden)
Space+b         # Buffer picker
Space+s         # Symbol picker
Space+S         # Workspace symbol picker

# Search
Space+/         # Global search
Space+g         # Go to line
```

## Configuration

### Runtime Directory Structure
```
runtime/
├── grammars/          # Tree-sitter grammars
├── queries/           # Tree-sitter queries
├── themes/            # Color themes
└── tutor             # Interactive tutorial
```

### Language Configuration
```toml
# languages.toml
[[language]]
name = "python"
language-server = { command = "pylsp" }
formatter = { command = "black", args = ["--quiet", "-"] }
auto-format = true

[[language]]
name = "rust"
language-server = { command = "rust-analyzer" }
formatter = { command = "rustfmt" }
```

### Key Binding Customization
```toml
# config.toml
[keys.normal]
"C-s" = ":w"
"C-q" = ":q"
"C-z" = "undo"
"C-y" = "redo"

[keys.insert]
"C-s" = "normal_mode"
"C-v" = "paste"
```

## Supported Languages

### Programming Languages
- Rust, Python, JavaScript, TypeScript
- C, C++, Java, Go, C#
- PHP, Ruby, Perl, Lua
- Haskell, OCaml, Erlang, Elixir
- And 80+ more languages

### Markup and Configuration
- HTML, CSS, JSON, YAML, TOML
- Markdown, LaTeX, XML
- Dockerfile, Nginx config
- Shell scripts, PowerShell

## Themes and Appearance

### Built-in Themes
```bash
# Dark themes
:theme dark_plus
:theme dracula
:theme monokai
:theme nord

# Light themes
:theme github_light
:theme solarized_light
```

### Custom Theme Configuration
```toml
# Custom theme in themes/my_theme.toml
"ui.background" = { bg = "#1e1e1e" }
"ui.foreground" = { fg = "#d4d4d4" }
"keyword" = { fg = "#569cd6" }
"string" = { fg = "#ce9178" }
```

## Advanced Features

### Tree-sitter Integration
- Syntax highlighting based on AST
- Intelligent text objects
- Incremental parsing
- Language-aware editing

### Multiple Selections
- Simultaneous editing at multiple locations
- Pattern-based selection expansion
- Line-based multiple cursors
- Selection manipulation commands

### Plugin System
- Language server integration
- Custom commands and functions
- Theme and appearance customization
- Key binding modifications

## Use Cases

### Software Development
```bash
# Open project
hx .

# Navigate to file
Space+f

# Find symbol
Space+s

# Go to definition
gd

# Format code
Space+f
```

### Text Editing
```bash
# Multiple selections
s               # Select pattern
C               # Copy to next line
c               # Change all selections

# Block editing
Ctrl+v          # Block select
I               # Insert at block start
```

### Configuration Management
```bash
# Edit configuration files
hx ~/.config/helix/config.toml
hx ~/.config/helix/languages.toml

# Syntax highlighting for configs
# Automatic language detection
```

## Installation
Modern terminal text editor with LSP support and advanced editing features.
Designed for efficient code editing with powerful text manipulation capabilities.

## Dependencies
- Language servers for full LSP functionality (optional)
- Tree-sitter grammars (included in runtime)
- Terminal with Unicode and color support

## Performance Features
- Fast startup time
- Efficient memory usage
- Incremental parsing with tree-sitter
- Responsive UI with minimal input lag
- Asynchronous language server communication

---
*Part of PORTX Portable Development Environment*