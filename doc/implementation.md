# PORTX Implementation Guide

## Layout

```
PORTX/
  packages/            tool packages (<exe(s)> + portx.json)
  ps/portx-import.ps1  the importer
  wrappers/
    posix/             generated bash wrappers
    windows/           generated .cmd wrappers
  path/portx_pkg_path  generated PATH fragment
  schema/portx.schema.json
  doc/
```

## The importer (ps/portx-import.ps1)

```
./portx-import.ps1 import            # all packages
./portx-import.ps1 import <name>     # one package
./portx-import.ps1 import -Clean     # wipe wrappers/ first, then regenerate
./portx-import.ps1 list              # list packages and tools
```

For each `wrap`/`wrapAndPath` package it writes `wrappers/posix/<tool>` + `wrappers/windows/<tool>.cmd`. For `path`/`wrapAndPath` it records the directory into `path/portx_pkg_path`. `-Clean` removes the whole `wrappers/` tree before regenerating — use it to drop wrappers left behind by removed packages.

## portx.json manifest

```json
{
  "name": "<lowercase-name>",
  "version": "<x.y.z>",
  "description": "<>=10 chars>",
  "importType": "wrap|path|none|wrapAndPath",
  "bin": {
    "<tool>": {
      "path": "<relative/exe>",
      "description": "...",
      "tags": [ "..." ]
    }
  },
  "packagePaths": [ "<dir>" ]
}
```

- `path` is relative to the package dir; may be nested (`rg.exe`, `cmd/git.exe`).
- `packagePaths` applies to `path`/`wrapAndPath` types — the dirs added to PATH.
- Full schema: `schema/portx.schema.json`.

## Wrapper templates

Bash (`wrappers/posix/<tool>`):

```bash
#!/bin/bash
# PORTX: <package>/<tool>
case "$(uname -sr)" in
    [Ll]inux*[Mm]icrosoft*) r="/mnt/c/App/PORTX" ;;
    [Mm][Ii][Nn][Gg][Ww]*|[Mm][Ss][Yy][Ss]*) r="/c/App/PORTX" ;;
    [Cc][Yy][Gg][Ww][Ii][Nn]*) r="/cygdrive/c/App/PORTX" ;;
    *) r="/c/App/PORTX" ;;
esac
args=("$@")
exec "$r/packages/<package>/<path>" "${args[@]}"
```

cmd (`wrappers/windows/<tool>.cmd`):

```cmd
@echo off
rem PORTX: <package>/<tool>
"C:\App\PORTX\packages\<package>\<path>" %*
```

## Adding a package

1. Create `packages/<name>/`, drop in the executable(s).
2. Write `portx.json` (name, version, description, importType, bin).
3. For a self-contained tool use `importType: wrap`.
4. `./portx-import.ps1 import <name>`.
5. Verify: `which <tool>` finds `wrappers/posix/<tool>`; `<tool> --version` runs.

## Making a package portable

If the executable loads DLLs, ensure they resolve from within the package, not the host.

1. Compute the closure with a dependency tool: `objdump -p <exe>` lists static imports; walk them recursively. **Some DLLs are loaded dynamically** (e.g. git loads `libcurl-4.dll` via `LoadLibraryExW`) and will not appear in the static import table — add those roots explicitly and walk their closure too.
2. Bundle exactly that closure (nothing more, nothing less). Windows resolves a DLL from the executable's own directory before PATH, so a complete local closure wins over the host.
3. Verify self-containment empirically: run the tool with the host runtime stripped from PATH — `PATH="/c/Windows/System32:/c/Windows" <tool> ...`. If it still works, it uses only its own bundled DLLs.

`packages/git-portable` is the worked example (a 13-DLL git closure, ~69M, verified this way).

## Shell integration

`~/.bash_profile` sources the generated PATH fragment:

```bash
if [[ -f "/c/App/PORTX/path/portx_pkg_path" ]]; then
    source "/c/App/PORTX/path/portx_pkg_path"
fi
if [[ -n "$PORTX_PACKAGES_PATH" ]]; then
    export PATH="$PATH:$PORTX_PACKAGES_PATH"
fi
```

Both PORTX fragments append to PATH, so host tools take precedence on name clashes (see architecture.md "Conflict model").
