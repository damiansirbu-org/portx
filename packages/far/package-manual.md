# FAR Manager Package Manual

## Package Information
- **Package Name**: far
- **Category**: File Operations
- **Type**: Advanced File Manager and Text Editor
- **License**: BSD 3-Clause

## Description
Professional file manager with powerful text editor, archive support, and extensive plugin system.

FAR Manager is a comprehensive file management solution featuring dual-panel interface, built-in text editor, network support, and advanced scripting capabilities.
Designed for power users and system administrators who need efficient file operations and text processing capabilities.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| Far.exe | FAR Manager main application | Advanced file manager with editor |
| luafar3.dll | Lua scripting engine | Plugin and macro development |
| sqlite3.dll | Database engine | Data storage and management |

## Key Features Overview

### File Management
- **Dual-Panel Interface** - Norton Commander-style layout
- **Network Support** - FTP, SFTP, SCP, WebDAV protocols
- **Archive Management** - 7z, ZIP, RAR, TAR, CAB support
- **File Operations** - Copy, move, delete with advanced options
- **Search and Filter** - Powerful file search with regex support

### Text Editor
- **Syntax Highlighting** - Configurable syntax coloring
- **Large File Support** - Efficient handling of large text files
- **Multiple Encodings** - Unicode, ANSI, OEM support
- **Regular Expressions** - Advanced search and replace
- **Block Operations** - Column selection and editing

### Plugin System
- **Extensible Architecture** - Rich plugin API
- **Built-in Plugins** - Archive, network, comparison tools
- **Lua Scripting** - Macro programming and automation
- **Custom Commands** - User-defined operations

## Basic Navigation and Operations

### Panel Navigation
```
F1        - Help system
F2        - User menu
F3        - View file
F4        - Edit file
F5        - Copy files
F6        - Move/rename files
F7        - Create directory
F8        - Delete files
F9        - Menu bar
F10       - Exit
F11       - Plugin commands
F12       - Screen switch

Tab       - Switch between panels
Ctrl+O    - Hide/show panels
Ctrl+F1   - Left drive menu
Ctrl+F2   - Right drive menu
```

### File Operations
```
Enter     - Enter directory or execute file
Shift+Enter - Execute file and keep console
Ctrl+Enter  - Execute filename at cursor
Space     - Select/deselect file
Ins       - Select file and move down
+         - Select files by mask
-         - Deselect files by mask
*         - Invert selection
```

### Quick Search and Navigation
```
Ctrl+S    - Quick search
Alt+F7    - Find files
Ctrl+F    - Find in current file
F7        - Search in files
Ctrl+L    - Repeat last search
Esc       - Cancel operation
```

## Advanced File Operations

### Bulk File Operations
- **Multi-selection** - Select files with Space, Ins, or masks
- **Advanced Copy** - Copy with filtering and transformations
- **Synchronization** - Directory comparison and sync
- **Batch Rename** - Pattern-based file renaming
- **File Attributes** - Bulk attribute modification

### Archive Management
- **Archive Viewing** - Browse archives like directories
- **Extraction** - Extract files with path preservation
- **Creation** - Create archives with compression options
- **Password Support** - Handle encrypted archives
- **Multi-format** - Support for numerous archive formats

### Network Operations
- **FTP/SFTP Client** - Built-in network file transfer
- **Network Drives** - Map and access network locations
- **WebDAV Support** - Cloud storage integration
- **Secure Connections** - SSL/TLS encrypted transfers

## Text Editor Features

### Editing Capabilities
- **Multi-file Editing** - Work with multiple files simultaneously
- **Unlimited Undo/Redo** - Comprehensive edit history
- **Block Operations** - Column and stream block selection
- **Code Folding** - Collapse and expand code sections
- **Word Wrap** - Automatic line wrapping

### Search and Replace
- **Regular Expressions** - Powerful pattern matching
- **Multi-file Search** - Search across multiple documents
- **Incremental Search** - Real-time search as you type
- **Replace Preview** - Preview changes before applying
- **Search History** - Recall previous searches

### Syntax Highlighting
- **Language Support** - Highlighting for 200+ languages
- **Custom Schemes** - User-defined color schemes
- **Theme Management** - Multiple visual themes
- **Plugin Integration** - Extended language support

## Plugin System and Customization

### Built-in Plugins

#### ArcLite (Archive Manager)
- **Multi-format Support** - 7z, ZIP, RAR, TAR, CAB, ISO
- **Archive Creation** - Create archives with compression
- **Password Protection** - Encrypted archive support
- **Self-extracting** - Create executable archives

#### NetBox (Network Client)
- **Protocol Support** - FTP, SFTP, SCP, WebDAV
- **Secure Connections** - SSL/TLS encryption
- **Key Authentication** - SSH key-based login
- **Session Management** - Save and restore connections

#### Compare (File Comparison)
- **Text Comparison** - Line-by-line file comparison
- **Binary Comparison** - Byte-level file analysis
- **Directory Sync** - Compare and synchronize folders
- **Difference Visualization** - Highlight changes

#### TmpPanel (Temporary Panel)
- **File Collections** - Create temporary file lists
- **Search Results** - Display search results in panels
- **Custom Lists** - User-defined file collections
- **Integration** - Work with other plugins

### Macro Programming
```lua
-- Example FAR Manager Lua macro
Keys = "F4"
Area = "Shell"
Flags = "NoPluginPanels"

function main()
    local item = panel.GetPanelItem(nil, 1, panel.GetCurrentPanelItem(nil, 1))
    if item and not item.FileAttributes:match("d") then
        editor.Editor(item.FileName, nil, nil, nil, nil, nil, 0x10, 1, 1, 1200)
    end
end
```

### Custom Commands and Automation
```lua
-- File operation automation
function BulkRename()
    local panel_info = panel.GetPanelInfo(nil, 1)
    for i = 1, panel_info.ItemsNumber do
        local item = panel.GetPanelItem(nil, 1, i)
        if item.FileAttributes:match("d") == nil then
            local new_name = item.FileName:gsub(" ", "_"):lower()
            far.MoveToRecycleBin = false
            panel.SetPanelItem(nil, 1, i, {FileName = new_name})
        end
    end
    panel.UpdatePanel(nil, 1)
end
```

## Configuration and Themes

### Color Schemes
FAR Manager includes multiple color schemes:
- **Default** - Standard blue/white theme
- **Black** - Dark theme for low-light environments
- **Custom** - User-defined color combinations
- **High Contrast** - Accessibility-focused themes

### Interface Customization
- **Panel Layout** - Customize column display
- **Key Mappings** - Modify keyboard shortcuts
- **Menu Configuration** - Customize context menus
- **Toolbar Setup** - Configure quick access buttons

### Plugin Configuration
- **Plugin Manager** - Enable/disable plugins
- **Plugin Settings** - Configure plugin behavior
- **Hotkey Assignment** - Assign keys to plugin functions
- **Auto-loading** - Configure plugin startup

## Workflow Examples

### Development Workflow
```
1. Navigate to project directory
2. F4 - Edit source files with syntax highlighting
3. Ctrl+F - Search across project files
4. F5 - Copy files between environments
5. F11 - Use Compare plugin for file differences
6. Alt+F7 - Find files by content or name
```

### System Administration
```
1. Browse system directories with elevated privileges
2. Edit configuration files with backup creation
3. Compare configuration files across systems
4. Archive log files with compression
5. Transfer files via secure protocols
6. Monitor file system changes
```

### Archive Management
```
1. F3 - View archive contents
2. F5 - Extract files with path preservation
3. F6 - Move files to different archives
4. F7 - Create new archives with compression
5. Enter - Navigate archive structure
6. Ctrl+PgDn - Enter archive for editing
```

## Advanced Features

### File Filtering and Masks
- **Include Masks** - Specify files to include
- **Exclude Masks** - Specify files to exclude
- **Attribute Filtering** - Filter by file attributes
- **Date Filtering** - Filter by modification date
- **Size Filtering** - Filter by file size

### Batch Operations
- **Multi-file Search** - Search across selected files
- **Batch Attribute Changes** - Modify multiple file attributes
- **Mass Rename** - Rename files using patterns
- **Batch Conversion** - Convert file formats
- **Synchronized Operations** - Coordinate panel actions

### Integration Features
- **Shell Integration** - Context menu integration
- **Command Line** - Execute system commands
- **External Tools** - Launch external applications
- **Clipboard Integration** - Advanced clipboard operations
- **Registry Editing** - Windows registry access

## Performance Optimization

### Large File Handling
- **Efficient Loading** - Fast loading of large files
- **Memory Management** - Optimized memory usage
- **Background Operations** - Non-blocking file operations
- **Progress Indicators** - Visual operation feedback
- **Cancellation Support** - Abort long operations

### Network Performance
- **Connection Caching** - Reuse network connections
- **Parallel Transfers** - Multiple simultaneous transfers
- **Resume Support** - Resume interrupted transfers
- **Bandwidth Control** - Limit transfer speeds
- **Compression** - On-the-fly compression

## Use Cases

### File Management
- Daily file operations and organization
- Archive creation and management
- Network file transfer and synchronization
- Bulk file operations and transformations

### Development and Editing
- Source code editing with syntax highlighting
- Project file management and navigation
- Configuration file editing and comparison
- Log file analysis and processing

### System Administration
- Server maintenance and configuration
- System file management and backup
- Remote system access and management
- Automated file operations and scripting

### Power User Tasks
- Advanced file search and filtering
- Custom workflow automation
- Plugin development and customization
- Complex file processing operations

## Installation
Comprehensive file manager with text editor and extensive plugin system.
Essential tool for file management, text editing, and system administration tasks.

## Dependencies
- Windows operating system (Windows 7+)
- Lua runtime (included for scripting)
- SQLite engine (included for data storage)
- Plugin dependencies vary by functionality

## System Requirements
- Minimum: Windows 7, 1GB RAM, 100MB disk space
- Recommended: Windows 10+, 4GB RAM, 500MB disk space
- Network connectivity for FTP/SFTP operations
- Administrative privileges for system file access

## Plugin Development
FAR Manager supports plugin development in:
- **C/C++** - Native plugin development
- **Lua** - Scripting and macro development
- **Pascal** - Alternative development language
- **Plugin SDK** - Comprehensive development tools

---
*Part of PORTX Portable Development Environment*