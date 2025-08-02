# GitUI Package Manual

## Package Information
- **Package Name**: gitui
- **Category**: Development Tools
- **Type**: Git Terminal UI
- **License**: MIT

## Description
Blazing fast terminal user interface for Git written in Rust.

Modern Git interface with intuitive keyboard navigation, real-time updates, and comprehensive Git operations.
Designed for developers who prefer terminal-based workflows with visual Git management.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| gitui.exe | Fast terminal-based Git interface | Interactive Git operations with visual interface |

## Common Usage Examples

### Basic Git Operations
```bash
# Launch GitUI in current repository
gitui

# Launch in specific directory
gitui --directory /path/to/repo

# Launch with specific theme
gitui --theme dark

# Launch with logging enabled
gitui --logging
```

## Interface Overview

### Main Views
- **Status**: Working directory changes and staging area
- **Log**: Commit history with branch visualization
- **Files**: File browser with diff preview
- **Stashing**: Stash management interface
- **Branches**: Branch management and switching

### Navigation Keys
- **Tab**: Switch between panels
- **h/j/k/l**: Vim-style navigation
- **Arrow keys**: Navigate lists and panels
- **Enter**: Select/confirm action
- **Esc**: Cancel/go back

## Status View Operations

### Staging and Unstaging
```bash
# In GitUI Status view:
# Space - Stage/unstage selected file
# a - Stage all files
# u - Unstage all files
# Enter - View file diff
# d - Discard changes (with confirmation)
```

### Working with Changes
```bash
# File operations:
# Enter - Show detailed diff
# Space - Toggle staging
# d - Discard changes
# r - Reset file to HEAD
# i - Add to .gitignore
```

### Commit Operations
```bash
# Commit workflow:
# c - Open commit dialog
# Type commit message
# Ctrl+Enter - Commit changes
# Esc - Cancel commit
```

## Log View Features

### Commit History
```bash
# Navigation:
# j/k or ↑/↓ - Navigate commits
# Enter - Show commit details
# Space - Show commit diff
# b - Create branch from commit
# t - Create tag from commit
```

### Branch Visualization
```bash
# Branch operations:
# o - Checkout commit/branch
# r - Revert commit
# R - Reset to commit
# c - Cherry-pick commit
# d - Show detailed diff
```

### Commit Details
```bash
# Detailed view:
# Tab - Switch between files and diff
# Enter - Open file diff
# Space - Toggle file selection
# y - Copy commit hash
```

## Branch Management

### Branch Operations
```bash
# Branch view:
# Enter - Checkout branch
# Space - Show branch details
# n - Create new branch
# d - Delete branch
# r - Rename branch
# m - Merge branch
```

### Remote Branches
```bash
# Remote operations:
# f - Fetch from remote
# p - Pull from remote
# P - Push to remote
# o - Checkout remote branch
# t - Track remote branch
```

## Stash Management

### Stash Operations
```bash
# Stash view:
# s - Create new stash
# Enter - Apply stash
# d - Drop stash
# p - Pop stash (apply and drop)
# Space - Show stash diff
```

### Stash Workflow
```bash
# Create stash with message:
# s - Open stash dialog
# Type message
# Enter - Create stash

# Apply stash:
# Navigate to stash
# Enter - Apply stash
# p - Pop stash (apply and remove)
```

## File Browser

### File Navigation
```bash
# File view:
# Enter - Open file/directory
# Space - Show file diff
# Backspace - Go up directory
# / - Search files
# ? - Show file options
```

### File Operations
```bash
# File actions:
# o - Open in external editor
# c - Copy file path
# r - Rename file
# d - Delete file
# i - Show file info
```

## Advanced Features

### Diff Viewing
```bash
# Diff navigation:
# j/k - Navigate diff hunks
# Space - Stage/unstage hunk
# Enter - Stage/unstage line
# Tab - Switch between files
# r - Reset hunk
```

### Search and Filter
```bash
# Search operations:
# / - Search in current view
# n/N - Next/previous search result
# Ctrl+f - Advanced filter
# Esc - Clear search
```

### Configuration
```bash
# Custom key bindings and themes:
# Create config at: %APPDATA%\gitui\key_bindings.ron
# Theme config at: %APPDATA%\gitui\theme.ron
```

## Workflow Examples

### Daily Development
```bash
# 1. Launch GitUI
gitui

# 2. Review changes in Status view
# 3. Stage files with Space
# 4. Commit with 'c'
# 5. Push with 'P' (in Status view)
```

### Code Review
```bash
# 1. Switch to Log view
# 2. Navigate to commits
# 3. Press Enter for detailed view
# 4. Review files and diffs
# 5. Use Tab to switch between panels
```

### Branch Management
```bash
# 1. Switch to Branches view (B)
# 2. Create new branch (n)
# 3. Switch between branches (Enter)
# 4. Merge branches (m)
# 5. Delete old branches (d)
```

## Keyboard Shortcuts Reference

### Global
- **q**: Quit GitUI
- **?**: Show help
- **Tab**: Switch panels
- **1-5**: Quick view switching
- **r**: Refresh all data

### Status View
- **c**: Commit
- **a**: Stage all
- **u**: Unstage all
- **s**: Stash changes
- **f**: Fetch
- **p**: Pull
- **P**: Push

### Log View
- **b**: Create branch
- **t**: Create tag
- **o**: Checkout
- **r**: Revert
- **R**: Reset
- **c**: Cherry-pick

## Installation
Fast terminal-based Git interface with intuitive keyboard navigation.
Provides comprehensive Git operations without leaving the terminal.

## Dependencies
- Git installation required
- Active Git repository
- Terminal with Unicode support recommended

## Performance Features
- Written in Rust for maximum performance
- Async operations for responsive interface
- Minimal memory footprint
- Fast repository scanning
- Real-time file system monitoring

---
*Part of PORTX Portable Development Environment*