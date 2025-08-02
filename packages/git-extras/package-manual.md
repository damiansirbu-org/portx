# Git Extras Package Manual

## Package Information
- **Package Name**: git-extras
- **Category**: Development
- **Type**: Git Enhancement Tools
- **License**: Various (see individual tools)

## Description
Enhanced Git command-line tools for power users and developers. 

Includes advanced diff viewers, GitHub integration, repository browsers, and productivity utilities that extend Git's core functionality.
These tools provide enhanced visualization, better diffs, and streamlined workflows for professional Git usage.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| delta.exe | Enhanced diff viewer with syntax highlighting | Git pager and diff viewer |
| difft.exe | Structural diff tool for programming languages | Compare code with structural awareness |
| gh.exe | GitHub CLI for repository management | GitHub operations from command line |
| gitstatusd.exe | Git status daemon for fast repository status | Background Git status monitoring |
| tig.exe | Terminal Git log and repository browser | Interactive Git repository browser |

## Common Usage Examples

### Delta (Enhanced Diff)
```bash
# Configure as Git pager
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"

# View diff with delta
git diff | delta
```

### GitHub CLI
```bash
# Clone repository
gh repo clone owner/repo

# Create pull request
gh pr create --title "Feature" --body "Description"

# View issues
gh issue list
```

### Tig (Terminal Browser)
```bash
# Browse repository
tig

# Browse specific file history
tig filename

# Browse Git log
tig log
```

### Difft (Structural Diff)
```bash
# Compare files with structural awareness
difft file1.js file2.js

# Use with Git
git difftool --tool=difft
```

## Installation
This package provides enhanced Git tools for developers who want advanced diff viewing, GitHub integration, and terminal-based repository browsing.

## Dependencies
- Git (provided in core bin/ directory)
- Terminal with color support recommended

---
*Part of PORTX Portable Development Environment*