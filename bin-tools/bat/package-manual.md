# bat Package Manual

## Package Information
- **Package Name**: bat
- **Category**: Text Processing
- **Type**: Enhanced File Viewer
- **License**: MIT/Apache 2.0

## Description
Modern replacement for cat with syntax highlighting, Git integration, and automatic paging.

Enhanced file viewer with syntax highlighting for hundreds of programming languages, Git diff support, and intelligent formatting.
Designed as a drop-in replacement for cat with significant improvements for development workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| bat.exe | Enhanced file viewer with syntax highlighting | View files with syntax highlighting and Git integration |

## Common Usage Examples

### Basic File Viewing
```bash
# View file with syntax highlighting
bat file.js

# View multiple files
bat file1.py file2.py file3.py

# View from stdin
echo "console.log('hello')" | bat -l js

# Specify language manually
bat -l json config.txt
```

### Git Integration
```bash
# Show Git diff with syntax highlighting
git diff | bat

# View file with Git changes highlighted
bat --diff file.js

# Show file with line numbers and Git status
bat -n --show-all file.py
```

### Output Control
```bash
# Show line numbers
bat -n file.js

# Show all characters (whitespace, etc.)
bat -A file.txt

# Plain output (no decorations)
bat -p file.txt

# Paging control
bat --paging=never file.txt
bat --paging=always file.txt
```

### Language Support
```bash
# List supported languages
bat --list-languages

# Auto-detect language
bat unknown_file

# Force specific language
bat -l cpp header.h
bat -l yaml config.txt
```

### Customization
```bash
# Use specific theme
bat --theme="Monokai Extended" file.js

# List available themes
bat --list-themes

# Set style options
bat --style=numbers,changes,header file.py
bat --style=plain file.txt
```

### File Range Selection
```bash
# Show specific line range
bat -r 10:20 file.py

# Show from line 50 to end
bat -r 50: file.js

# Show first 100 lines
bat -r :100 file.txt
```

### Integration with Other Tools
```bash
# Use as pager for git
git config --global core.pager "bat"

# Use with find
find . -name "*.py" -exec bat {} +

# Use with grep
grep -r "function" . | bat -l grep

# Pipeline usage
curl -s https://api.github.com/users/octocat | bat -l json
```

### Configuration Examples
```bash
# Create config file at %APPDATA%\bat\config
--theme="OneHalfDark"
--style="numbers,changes,header"
--pager="less -RF"
--map-syntax="*.conf:INI"
```

### Advanced Features
```bash
# Show file header with metadata
bat --decorations=always file.txt

# Disable all decorations
bat --decorations=never file.txt

# Custom tab width
bat --tabs=2 file.py

# Wrap long lines
bat --wrap=character file.txt
```

### Development Workflow Integration
```bash
# Quick file inspection
bat README.md

# View log files with highlighting
bat app.log

# Inspect configuration files
bat nginx.conf
bat package.json

# Review code changes
git show HEAD:file.js | bat -l js
```

## Supported Languages
Over 200 programming languages and file formats including:
- **Programming**: JavaScript, Python, Java, C++, Rust, Go, etc.
- **Markup**: HTML, XML, Markdown, YAML, JSON, etc.
- **Configuration**: INI, TOML, Dockerfile, etc.
- **Data**: CSV, SQL, Log files, etc.

## Installation
Enhanced file viewer with syntax highlighting and Git integration.
Drop-in replacement for cat with modern development features.

## Dependencies
None - standalone executable with built-in syntax highlighting themes and language support.

## Configuration
- Config file: `%APPDATA%\bat\config`
- Themes: Built-in themes or custom theme files
- Language mappings: Custom syntax associations
- Git integration: Automatic when in Git repository

---
*Part of PORTX Portable Development Environment*