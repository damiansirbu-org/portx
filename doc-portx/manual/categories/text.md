# 🔍 Text Processing (35 tools)
**Search, parsing, processing, and manipulation of text data**

[🏠 Back to Wiki Home](../index.md) | [📚 All Categories](../index.md#-tool-categories)

---

## 🚀 Category Overview

Powerful text processing and data manipulation tools:
- **Modern search** - ripgrep, ag, fzf
- **Data processing** - jq, yq, fx for JSON/YAML
- **Traditional Unix** - grep, sed, awk, sort, uniq
- **Text manipulation** - cut, tr, paste, column

---

## 🔍 Modern Search Tools

### **ripgrep (rg)** - v13.0.0 ⭐ **Ultra-Fast Search**
Extremely fast text search with smart defaults.
- **Usage**: `rg "pattern"`, `rg "pattern" --type js`
- **Performance**: 2-10x faster than grep
- **Location**: `bin-ext/ripgrep/rg.exe`

### **ag** - v2.2.0 The Silver Searcher
Fast code search optimized for programmers.
- **Usage**: `ag "pattern"`, `ag "TODO" --ignore-dir=node_modules`
- **Location**: `bin-ext/ag/ag.exe`

### **fzf** - v0.30.0 ⭐ **Fuzzy Finder**
Interactive fuzzy finder for command-line.
- **Usage**: `find . | fzf`, `fzf --preview 'cat {}'`
- **Location**: `bin-ext/fzf/fzf.exe`

---

## 📊 Data Processing

### **jq** - v1.6 ⭐ **JSON Processor**
Lightweight command-line JSON processor.
- **Usage**: `curl api.json | jq '.users[] | select(.active)'`
- **Location**: `bin-ext/jq/jq.exe`

### **yq** - v4.31.2 YAML Processor
YAML processor with jq-like syntax.
- **Usage**: `yq eval '.services.web.ports' docker-compose.yml`
- **Location**: `bin-ext/yq/yq.exe`

### **fx** - v22.0.0 Interactive JSON
Interactive JSON viewer and processor.
- **Usage**: `echo '{"name":"john"}' | fx .name`
- **Location**: `bin-ext/fx/fx.exe`

---

## 🔧 Traditional Unix Text Tools

### **grep** - Pattern matching
Search text using regular expressions.
- **Usage**: `grep "pattern" file.txt`, `grep -r "pattern" /path/`
- **Location**: `usr/bin/grep.exe`

### **sed** - Stream editor
Non-interactive text transformation.
- **Usage**: `sed 's/old/new/g' file.txt`
- **Location**: `usr/bin/sed.exe`

### **awk** - Pattern scanning
Programming language for text processing.
- **Usage**: `awk '{print $1, $3}' file.txt`
- **Location**: `usr/bin/awk.exe`

### **sort** - Sort lines
Sort lines of text files.
- **Usage**: `sort file.txt`, `sort -n numbers.txt`
- **Location**: `usr/bin/sort.exe`

### **uniq** - Remove duplicates
Report or filter unique lines.
- **Usage**: `sort file.txt | uniq -c`
- **Location**: `usr/bin/uniq.exe`

---

## ✂️ Text Manipulation

### **cut** - Extract fields
Extract columns from text.
- **Usage**: `cut -d: -f1 /etc/passwd`
- **Location**: `usr/bin/cut.exe`

### **tr** - Transform characters
Translate or delete characters.
- **Usage**: `tr '[:lower:]' '[:upper:]'`
- **Location**: `usr/bin/tr.exe`

---

*Use `portx text` to view this category*

**[⬆️ Back to Top](#-text-processing-35-tools)** | **[🏠 Wiki Home](../index.md)**