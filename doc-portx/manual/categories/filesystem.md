# 🗂️ File System & Core Utilities (58 tools)
**Essential Unix file operations and system utilities**

[🏠 Back to Wiki Home](../index.md) | [📚 All Categories](../index.md#-tool-categories)

---

## 🚀 Category Overview

The foundation of Unix/Linux - core file system operations and utilities:
- **File operations** - ls, cp, mv, rm, find, chmod, chown
- **Archive management** - tar, gzip, zip, 7za
- **Directory navigation** - cd, pwd, mkdir, rmdir
- **File permissions** - chmod, chown, umask
- **Search and locate** - find, locate, which, whereis

---

## 📁 Essential File Operations

### **ls** - List directory contents
Display files and directories with detailed information.
- **Usage**: `ls -la`, `ls -lh --color=auto`
- **Sorting**: `ls -lt` (by time), `ls -lS` (by size)
- **Location**: `usr/bin/ls.exe`

### **cp** - Copy files and directories  
Copy files with preservation of attributes.
- **Usage**: `cp file.txt backup.txt`, `cp -r directory/ backup/`
- **Preserve**: `cp -p file.txt dest/` (preserve timestamps)
- **Location**: `usr/bin/cp.exe`

### **mv** - Move/rename files
Move files and directories, also used for renaming.
- **Usage**: `mv old.txt new.txt`, `mv file.txt /destination/`
- **Location**: `usr/bin/mv.exe`

### **rm** - Remove files and directories
Delete files and directories with safety options.
- **Usage**: `rm file.txt`, `rm -rf directory/`
- **Safe**: `rm -i file.txt` (interactive)
- **Location**: `usr/bin/rm.exe`

---

## 🔍 File Search & Location

### **find** - Search for files and directories
Powerful recursive file search with complex criteria.
- **Usage**: `find . -name "*.txt"`, `find /path -type f -size +100M`
- **Advanced**: `find . -name "*.log" -mtime +7 -delete`
- **Location**: `usr/bin/find.exe`

### **locate** - Fast filename database search
Quick file location using pre-built database.
- **Usage**: `locate filename`, `locate -i PATTERN`
- **Location**: `usr/bin/locate.exe`

### **which** - Locate command
Find the location of executable files.
- **Usage**: `which python`, `which -a gcc`
- **Location**: `usr/bin/which.exe`

---

## 📦 Archive & Compression

### **tar** - Archive files
Create and extract tape archives.
- **Create**: `tar -czf archive.tar.gz directory/`
- **Extract**: `tar -xzf archive.tar.gz`
- **List**: `tar -tzf archive.tar.gz`
- **Location**: `usr/bin/tar.exe`

### **gzip/gunzip** - Compress files
GNU zip compression utilities.
- **Usage**: `gzip file.txt`, `gunzip file.txt.gz`
- **Location**: `usr/bin/gzip.exe`

### **7za** - 7-Zip archiver
High-compression ratio archiver.
- **Usage**: `7za a archive.7z directory/`
- **Extract**: `7za x archive.7z`
- **Location**: `bin-ext/7za/7za.exe`

---

## 🔐 Permissions & Ownership

### **chmod** - Change file permissions
Modify file access permissions.
- **Octal**: `chmod 755 script.sh`, `chmod 644 file.txt`
- **Symbolic**: `chmod u+x script.sh`, `chmod go-w file.txt`
- **Location**: `usr/bin/chmod.exe`

### **chown** - Change ownership
Change file and directory ownership.
- **Usage**: `chown user:group file.txt`
- **Recursive**: `chown -R user:group directory/`
- **Location**: `usr/bin/chown.exe`

---

*Use `portx filesystem` to view this category*

**[⬆️ Back to Top](#️-file-system--core-utilities-58-tools)** | **[🏠 Wiki Home](../index.md)**