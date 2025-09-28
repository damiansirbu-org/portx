# PORTX Universal Wrapper System

Cross-platform tool wrapper system providing seamless access to 369 portable tools across Windows, WSL, Cygwin, and MSYS2 environments.

## Overview

PORTX implements a sophisticated wrapper system that bridges the gap between Windows executables and Unix-like shells. The current implementation features a high-performance Go wrapper (`portx-wrap.exe`) that provides intelligent path conversion, environment detection, and real-time I/O handling for maximum compatibility.

## Quick Start

```bash
# Use Go wrapper directly (current working implementation)
/c/App/PORTX/go/target/portx-wrap.exe node /c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js

# Enable debug logging
/c/App/PORTX/go/target/portx-wrap.exe --portxDebug node /c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js
```

## Current Architecture

The system currently operates through:

- **Go Wrapper**: `portx-wrap.exe` - High-performance universal wrapper
- **Tool Configuration**: `go/config/tool-configs.json` - Tool-specific settings
- **Package System**: 220 packages with 369 executables
- **Path Conversion**: Intelligent Unix↔Windows path transformation
- **Environment Detection**: WSL, MSYS2, Cygwin, native Windows support

## Critical Tools

### 🔥 Essential Tools (Fixed)
- **git**: Git version control with embedded path support (`--git-dir`, `--work-tree`)
- **node**: Node.js runtime with Claude Code support (TTY detection fixed)
- **rg**: Ripgrep text search with pattern vs path detection
- **fd**: File finder with intelligent pattern handling

### ⚡ High Priority Tools
- **7za**: Archive operations with path conversion
- **tar/gzip**: Compression tools (git dependencies)
- **ag**: Silver searcher with output conversion

## Recent Fixes

**Critical Claude Code Wrapper Bug (2025-09-27)**:
- **Issue**: Claude Code failed with "Input must be provided through stdin" error
- **Root Cause**: Pipe-based I/O broke TTY detection in MSYS2 environments
- **Solution**: Implemented direct I/O inheritance (`cmd.Stdin = os.Stdin`)
- **Status**: ✅ RESOLVED - Claude Code now works correctly

## Configuration

**Tool-specific settings** in `go/config/tool-configs.json`:
- Path exclusion rules for regex patterns
- Output conversion settings for search tools
- Environment-specific behavior

## Documentation

- **[Architecture](architecture.md)**: Go wrapper design and cross-platform mechanisms
- **[Implementation](implementation.md)**: Technical details and development guide
- **[Tool Parameters Reference](PORTX-TOOLS-PARAMETERS-RETURNS.md)**: Complete tool parameter and return type guide

## Requirements

- Go 1.19+ (for building wrapper)
- Windows-compatible environment (WSL, Cygwin, MSYS2, or native Windows)

## License

Proprietary - PORTX Universal Toolchain System