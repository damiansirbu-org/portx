# PathX Solutions Research

**Date**: 2025-09-28
**Research Phase**: TTY Detection + Output Interception Solutions

## Problem Statement

**Core Issue**: Need bidirectional path conversion (Unix ↔ Windows) while preserving TTY detection for interactive tools like Claude Code.

**Challenge**: Cannot intercept stdout/stderr without breaking TTY detection, but need to convert Windows paths in output back to Unix paths.

## Solution 1: Pseudo Terminal (PTY) Approach

### Research Findings
- **Library**: `github.com/creack/pty` (successor to kr/pty)
- **Principle**: PTY maintains terminal characteristics while allowing output interception
- **TTY Preservation**: Process sees real terminal through PTY, not pipe

### Implementation Pattern
```go
import "github.com/creack/pty"

// Start command with PTY
ptmx, err := pty.Start(cmd)

// Intercept output without breaking TTY
go func() {
    scanner := bufio.NewScanner(ptmx)
    for scanner.Scan() {
        line := scanner.Text()
        if containsWindowsPaths(line) {
            line = convertToUnixPaths(line)
        }
        fmt.Fprintln(os.Stdout, line)
    }
}()
```

### Benefits
- ✅ Preserves TTY detection
- ✅ Allows real-time output interception
- ✅ No tool-specific configuration needed
- ✅ Interactive tools work correctly

### Limitations
- ⚠️ Additional dependency (creack/pty)
- ⚠️ Slight performance overhead
- ⚠️ PTY behavior differs from direct execution

## Solution 2: Smart Runtime Detection

### Concept
Instead of pre-configuring tools, detect at runtime:
1. Monitor if tool produces output
2. Scan output for Windows path patterns
3. Convert only when paths detected
4. Default to TTY preservation

### Detection Logic
```go
func needsConversion(output string) bool {
    // Match C:\path patterns
    return regexp.MustCompile(`[A-Z]:\\[^\s]*`).MatchString(output)
}
```

### Benefits
- ✅ Zero configuration required
- ✅ Works with all tools automatically
- ✅ Only converts when necessary
- ✅ Eliminates tool classification problem

## Solution 3: Hybrid Approach (Recommended)

### Strategy
Combine PTY + smart detection:
1. Use PTY for output interception
2. Apply runtime path detection
3. Convert Windows paths to Unix on-the-fly
4. Preserve TTY for interactive tools

### Implementation Flow
```
Input: Unix paths → Windows paths (for executable)
Execute: Windows executable with PTY
Output: Scan for Windows paths → Convert to Unix paths
Result: User sees Unix paths, TTY preserved
```

## Competitive Analysis

### WslPath (C#)
- **Algorithm**: String manipulation, not regex
- **Pattern**: `/mnt/c/path` detection via character position
- **Performance**: StringBuilder for path reconstruction

### MSYS2 path_convert (C++)
- **Testing**: 100+ test cases for edge cases
- **Features**: Handles quoted paths, special prefixes (-I, -L, @)
- **Scope**: Network paths, UNC, URL support

## CLI Library Research

### Comparison Results
1. **Cobra** (Current): 35k+ stars, best help system, used by Docker/Kubernetes
2. **urfave/cli**: 20k+ stars, lightweight, simple
3. **go-flags**: Struct tags, excellent testability

### Recommendation
**Keep Cobra** - meets "best help we can get" requirement.

## TTY Detection Technical Details

### What TTY Means
- **TTY**: Terminal device that supports interactive I/O
- **Detection**: `term.IsTerminal()` checks if file descriptor is terminal
- **Impact**: Interactive vs batch mode behavior

### Claude Code Specific Issue
- **Problem**: When stdout piped, Claude Code requires `--print` flag
- **Detection**: Process checks `isatty(STDOUT_FILENO)`
- **Solution**: PTY makes process think it has real terminal

### Current Working Fix
```go
// WORKING - Direct I/O inheritance
cmd.Stdin = os.Stdin
cmd.Stdout = os.Stdout
cmd.Stderr = os.Stderr

// BROKEN - Pipe breaks TTY detection
stdout, _ := cmd.StdoutPipe()
```

## Implementation Recommendations

### File Structure
- **main.go**: CLI interface only
- **pty.go**: PTY handling and output processing
- **convert.go**: Path conversion algorithms
- **parse.go**: Argument parsing logic
- **detect.go**: Runtime path detection

### Dependencies
- `github.com/creack/pty`: PTY functionality
- `github.com/spf13/cobra`: CLI framework
- `golang.org/x/term`: TTY detection utilities

### Performance Considerations
- Stream processing to avoid memory buildup
- Compiled regex patterns with caching
- Byte-level path conversion for speed
- Minimal allocations in hot paths

---

**Status**: Research complete, ready for implementation planning.