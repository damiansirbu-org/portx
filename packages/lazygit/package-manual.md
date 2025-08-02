# Lazygit Package Manual

## Package Information
- **Package Name**: lazygit
- **Category**: Development
- **Type**: Git Terminal UI
- **License**: MIT

## Description
A simple terminal UI for Git commands. 

Lazygit provides an intuitive, keyboard-driven interface for common Git operations including staging, committing, branching, merging, and viewing repository history.
Features a modern terminal interface that makes Git operations visual and accessible through keyboard shortcuts.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| lazygit.exe | Terminal-based Git interface | Interactive Git operations via TUI |

## Features
- **Visual Git Interface**: See file changes, commit history, and branches in one view
- **Keyboard Navigation**: Efficient keyboard shortcuts for all operations
- **Staging**: Easy file staging and unstaging with visual feedback
- **Branching**: Create, switch, and merge branches interactively
- **Commit History**: Browse and search commit history with details
- **Diff Viewing**: Side-by-side diff viewing with syntax highlighting
- **Merge Conflict Resolution**: Visual merge conflict resolution
- **Stash Management**: Create, apply, and drop stashes easily

## Common Usage

```bash
# Launch lazygit in current repository
lazygit

# Launch lazygit with custom config
lazygit --use-config-dir ~/.config/lazygit

# Launch with debug logging
lazygit --debug
```

## Keyboard Shortcuts (Default)
- `?` - Help/shortcuts menu
- `1-5` - Switch between panels (Status, Files, Branches, Commits, Stash)
- `Enter` - Confirm/select action
- `Esc` - Cancel/go back
- `q` - Quit
- `Space` - Stage/unstage files
- `c` - Commit changes
- `P` - Push to remote
- `p` - Pull from remote

## Installation
Provides a modern, user-friendly terminal interface for Git operations. Ideal for developers who prefer visual Git interaction over command-line Git.

## Dependencies
- Git (provided in core bin/ directory)
- Terminal with color support

---
*Part of PORTX Portable Development Environment*