# 💻 Development Tools (45 tools)
**Compilers, version control, editors, and build systems**

[🏠 Back to Wiki Home](../index.md) | [📚 All Categories](../index.md#-tool-categories)

---

## 🚀 Category Overview

Essential development tools for modern software engineering:
- **Compilers & build systems** - gcc, g++, make, cmake
- **Version control** - git, svn
- **Text editors** - helix, micro, nano
- **Development utilities** - gdb, objdump, nm, ar

---

## 🔨 Compilers & Build Tools

### **gcc** - GNU Compiler Collection
C/C++ compiler with optimization and debugging support.
- **Usage**: `gcc -o program program.c`, `gcc -Wall -g program.c`
- **Optimization**: `gcc -O2 -march=native program.c`
- **Location**: `mingw64/bin/gcc.exe`

### **g++** - C++ compiler
C++ compiler with STL support.
- **Usage**: `g++ -std=c++17 -O2 app.cpp`
- **Location**: `mingw64/bin/g++.exe`

### **make** - Build automation
GNU Make for managing project builds.
- **Usage**: `make all`, `make clean`, `make -j4`
- **Location**: `bin-ext/make/make.exe`

---

## 📝 Version Control

### **git** - Distributed version control
Industry-standard version control system.
- **Usage**: `git clone repo.git`, `git add .`, `git commit -m "message"`
- **Branches**: `git checkout -b feature`, `git merge main`
- **Location**: `mingw64/bin/git.exe`

### **lazygit** - Git TUI
Terminal user interface for git.
- **Usage**: `lazygit`
- **Location**: `bin-tools/lazygit/lazygit.exe`

---

## ✏️ Text Editors

### **helix** - v25.07.1 ⭐ **Modern Editor**
Modern modal text editor with language server support.
- **Usage**: `hx file.txt`, `hx .` (open directory)
- **Location**: `bin-tools/helix/hx.exe`

### **micro** - v2.0.10 ⭐ **User-Friendly**
Easy-to-use terminal editor with mouse support.
- **Usage**: `micro file.txt`
- **Location**: `bin-ext/micro/micro.exe`

---

## 🔍 Debugging & Analysis

### **gdb** - GNU Debugger
Debug compiled programs.
- **Usage**: `gdb ./program`
- **Location**: `mingw64/bin/gdb.exe`

### **objdump** - Object file analyzer
Analyze object files and executables.
- **Usage**: `objdump -d program.exe`
- **Location**: `mingw64/bin/objdump.exe`

---

*Use `portx development` to view this category*

**[⬆️ Back to Top](#-development-tools-45-tools)** | **[🏠 Wiki Home](../index.md)**