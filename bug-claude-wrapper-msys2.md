# Bug Report: Claude Wrapper Issue in MSYS2

## Problem Summary
The PORTX wrapper is incorrectly passing arguments to Claude Code, causing Claude to think it received file arguments when it should start interactively.

## Error Message
```
Error: Input must be provided either through stdin or as a prompt argument when using --print
```

## Root Cause Analysis
When user runs `claude` command with no arguments (should start interactively), the wrapper is somehow passing the CLI script path as an argument to Claude Code, making Claude think it's in `--print` mode.

## Debug Evidence from MSYS2
```bash
$ /c/App/PORTX/go/target/portx-wrap.exe --portxDebug node /c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js
DEBUG: DetectEnvironment called - using parent process detection only
DEBUG: Parent process - PID: 19496, Name: bash.exe, Exe: C:\App\Git\usr\bin\bash.exe
DEBUG: Running uname from parent shell: C:\App\Git\usr\bin\bash.exe
DEBUG: uname -s from parent shell: MINGW64_NT-10.0-19045
DEBUG: Detected environment: msys2
DEBUG: msys2 environment configured
{"level":"info","timestamp":"2025-09-27T17:25:17.240+0300","caller":"go/main.go:107","msg":"Debug mode enabled via wrapper flag","tool":"node","args":["C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"]}
{"level":"info","timestamp":"2025-09-27T17:25:17.241+0300","caller":"go/main.go:119","msg":"About to call ExecuteTool","tool":"node","args":["C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"],"wrapper_nil":false}
{"level":"info","timestamp":"2025-09-27T17:25:17.241+0300","caller":"go/wrapper.go:83","msg":"ExecuteTool called","tool":"node","args":["C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"]}
{"level":"info","timestamp":"2025-09-27T17:25:17.241+0300","caller":"go/wrapper.go:168","msg":"Processing parameter","arg":"C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js","position":0}
{"level":"info","timestamp":"2025-09-27T17:25:17.241+0300","caller":"go/wrapper.go:214","msg":"Path not recognized as Unix path","arg":"C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js","platform":"msys2"}
{"level":"info","timestamp":"2025-09-27T17:25:17.241+0300","caller":"go/wrapper.go:108","msg":"Tool execution details","tool":"node","executable":"C:\\App\\PORTX\\packages\\node\\node.exe","original_args":["C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"],"processed_args":["C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"],"platform":"msys2"}
Error: Input must be provided either through stdin or as a prompt argument when using --print
{"level":"info","timestamp":"2025-09-27T17:25:23.208+0300","caller":"go/wrapper.go:133","msg":"Tool execution completed","tool":"node","duration":5.9669632,"exit_code":1}
{"level":"info","timestamp":"2025-09-27T17:25:23.208+0300","caller":"go/main.go:141","msg":"ExecuteTool completed successfully","exit_code":1}
```

## Key Debug Information
- **Environment Detection**: Correctly detects MSYS2
- **Path Conversion**: Working correctly (no conversion needed for Windows format path)
- **Wrapper Execution**: `node.exe "C:/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"`
- **Problem**: Claude Code thinks it received a file argument and enters `--print` mode

## Expected vs Actual Behavior
- **Expected**: `claude` command starts interactively, waits for user input
- **Actual**: Claude thinks it received file arguments and expects input via stdin or `--print` argument

## File Locations
- **Wrapper**: `/c/App/PORTX/go/target/portx-wrap.exe`
- **Claude Script**: `/c/App/PORTX/packages/node/claude`
- **Node Script**: `/c/App/PORTX/packages/node/node`
- **Tool Config**: `/c/App/PORTX/go/config/tool-configs.json`
- **Claude CLI**: `/c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js`

## Wrapper Call Chain
1. User runs: `claude` (no arguments)
2. PORTX `claude` script calls: `$basedir/node $basedir/node_modules/@anthropic-ai/claude-code/cli.js`
3. PORTX `node` script calls: `portx-wrap.exe "node" "/path/to/cli.js"`
4. Wrapper executes: `node.exe "/path/to/cli.js"`
5. Claude Code receives the script path as if it were a file argument

## Source Code Analysis Needed
- **wrapper.go**: Check how arguments are passed to `exec.CommandContext`
- **Claude CLI source**: `/c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js` line 3722 contains the "--print" error check

## Node Tool Configuration
```json
"node": {
  "name": "node",
  "windows_path": "C:\\\\App\\\\PORTX\\\\packages\\\\node\\\\node.exe",
  "parameter_rules": {
    "always_convert": [],
    "never_convert": ["--require", "--loader"],
    "embedded_paths": [],
    "positional_rules": {
      "0": "always_convert"
    }
  }
}
```

## Test Commands for MSYS2
```bash
# Test wrapper directly (FAILS with --print error)
/c/App/PORTX/go/target/portx-wrap.exe --portxDebug node /c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js

# Test node.exe directly (FAILS with git-bash error but different failure mode)
/c/App/PORTX/packages/node/node.exe "/c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"

# Test claude script (FAILS with --print error via wrapper)
/c/App/PORTX/packages/node/claude

# Start Claude with clean environment (WORKING method for MSYS2)
# This bypasses both the git-bash detection and wrapper issues
env PATH="/usr/local/bin:/usr/bin:/bin" /c/App/PORTX/packages/node/node.exe "/c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js"
```

## Critical Question
Why does the wrapper cause Claude Code to think it received file arguments when the exact same `node.exe "script.js"` command works correctly when run directly?

## Previous Analysis (May Be Wrong)
- Initial thought was path conversion issues - RULED OUT
- Initial thought was environment detection issues - RULED OUT
- Initial thought was Windows vs Unix detection - PARTIALLY RELEVANT but not root cause

## Next Steps
1. Examine the exact arguments passed to `exec.CommandContext` in wrapper.go
2. Compare behavior of direct node.exe call vs wrapper call
3. Check if there are any environment variables or stdin/stdout handling differences
4. Investigate if the wrapper is somehow changing how Claude Code interprets its arguments