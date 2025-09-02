# Tree-sitter Parser for PORTX

**Self-contained AST parser with embedded Python + 26 language parsers. Zero dependencies.**

## Usage

```bash
treesitter-parse <language> <file_path>

# Examples
treesitter-parse python script.py
treesitter-parse bash script.sh  
treesitter-parse javascript app.js
```

## Installed Languages (26)
bash, c_sharp, cpp, css, go, haskell, html, java, javascript, json, kotlin, lua, make, markdown, php, python, regex, ruby, rust, scala, sql, swift, toml, typescript, xml, yaml

## How It Works

**Embedded Python 3.11** + **26 language parsers** = **Portable AST parsing**

```
treesitter-parse.cmd → python-embedded/python.exe → embedded_treesitter_parser.py → portable-parsers/tree_sitter_*
```

**Path setup:** `python311._pth` modified to include `../portable-parsers` in Python path

## Adding New Languages

**Automated (Recommended):**
```bash
treesitter-add-language.cmd <language>

# Examples
treesitter-add-language.cmd dockerfile
treesitter-add-language.cmd c
treesitter-add-language.cmd terraform
```

**Manual:**
```bash
# 1. Install parser
"python-embedded/python.exe" -m pip install tree-sitter-<language> --target portable-parsers

# 2. Test
treesitter-parse <language> <test_file>
```

**Available languages:** https://pypi.org/search/?q=tree-sitter

## Claude Code Integration

**Works with `/analyze` slash command:**
```bash
/analyze "c:/path/to/file.py"
```

**Hook integration:** Used by pre-read analysis hooks for automatic AST parsing.

## Troubleshooting

**Parser fails:**
```bash
# Try fallback
treesitter-parse-fallback <language> <file>

# Check available languages  
treesitter-parse
```

**Unicode issues:** Ensure files are UTF-8 encoded.

## Stats
- **Size:** 59MB (21MB Python + 38MB parsers)  
- **Languages:** 26 installed, 165+ available
- **Dependencies:** Zero
- **Platform:** Windows x64