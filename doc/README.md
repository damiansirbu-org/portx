# PORTX Universal Toolchain

Portable access to Windows CLI tools from any Unix-style shell on Windows — MSYS2, Git-for-Windows, Cygwin, and WSL. Each tool is a self-contained package; PORTX generates thin wrappers so `git`, `rg`, `fd`, etc. work identically regardless of which shell you launch.

## How it works

```
you type:   git status
resolves:   wrappers/posix/git          (a generated bash wrapper on PATH)
which runs: exec C:\App\PORTX\packages\git-portable\cmd\git.exe status
```

A tool package is a directory under `packages/` containing the executable(s) plus a `portx.json` manifest. A PowerShell importer reads the manifest and generates the wrappers and PATH entries. There is **no** runtime path-conversion engine — the wrappers `exec` the Windows executable directly and pass arguments through; the target tools handle Windows/Unix path styles themselves.

## Import types (`importType` in portx.json)

- `wrap` — generate a wrapper for each named binary; the wrapper `exec`s that one executable. The package directory is NOT added to PATH. Use for a self-contained tool. (Most packages.)
- `path` — add the package directory (or its `packagePaths`) to PATH; generate no wrapper. Use for a bundle of many executables meant to be discovered together.
- `wrapAndPath` — both.
- `none` — documentation-only package; nothing imported.

## Components

```
packages/            one directory per tool: <exe(s)> + portx.json
ps/portx-import.ps1  PowerShell importer: reads manifests, writes wrappers, builds the PATH cache
wrappers/posix/      generated bash wrappers (Unix shells)
wrappers/windows/    generated .cmd wrappers (native cmd)
path/portx_pkg_path  generated PATH fragment, sourced by the shell profile
schema/portx.schema.json
```

## Usage

```
portx import          # (re)generate wrappers + PATH for all packages
portx import <name>   # one package
portx import -Clean   # wipe wrappers first, then regenerate (drops wrappers of removed packages)
portx list            # list all packages and tools
```

## Requirements

- A Windows Unix-style shell: MSYS2, Git-for-Windows, Cygwin, or WSL.
- PowerShell 5.1+ (for the importer).

## Documentation

- **[Architecture](architecture.md)** — the mechanism: packages, import types, wrapper generation, PATH assembly, conflict model, package portability.
- **[Implementation](implementation.md)** — using the importer, the manifest schema, adding a package, making a package portable.
