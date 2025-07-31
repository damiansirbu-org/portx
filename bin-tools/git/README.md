# Git Enhancement Tools

This directory contains additional git utilities that enhance the standard git experience.

## Recommended Tools to Add

### Visual Diff Tools
- **delta** - https://github.com/dandavison/delta
  - Syntax-highlighting pager for git, diff, and grep output
  - `git config --global core.pager delta`

- **difftastic** - https://github.com/Wilfred/difftastic
  - Structural diff that understands syntax
  - `git config --global diff.external difft`

### Git Workflow
- **tig** - https://github.com/jonas/tig
  - Text-mode interface for Git
  - Browse commits, view diffs, navigate repo history

- **gitui** - https://github.com/extrawurst/gitui
  - Blazing fast terminal UI for git
  - Written in Rust, very responsive

- **lazygit** - Already included in parent directory
  - Simple terminal UI for git

### GitHub Integration
- **gh** - https://github.com/cli/cli
  - Official GitHub CLI
  - Create PRs, manage issues, clone repos

### Git Utilities
- **git-lfs** - https://git-lfs.github.com/
  - Large File Storage extension
  - Track large files outside main repo

- **git-extras** - https://github.com/tj/git-extras
  - Collection of git utilities
  - git-ignore, git-info, git-changelog, etc.

## Installation Status

✅ **delta** - v0.18.2 - Syntax-highlighting pager (already installed)
✅ **difft** - v0.61.0 - Structural diff tool (already installed)
✅ **tig** - v2.5.5 - Text-mode Git interface (installed from system)
✅ **gitui** - Blazing fast terminal UI (already installed)
✅ **gh** - v2.76.2 - Official GitHub CLI (downloaded and installed)
✅ **git-lfs** - v3.7.0 - Large File Storage (downloaded and installed)

## Installation

Download the Windows binaries for each tool and place them in this directory.
Most tools provide pre-built Windows executables in their GitHub releases.

## Configuration

After adding tools, you may want to configure git to use them:

```bash
# Use delta for diffs
git config --global core.pager delta

# Use difftastic for external diff
git config --global diff.external difft

# Set up git aliases
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```