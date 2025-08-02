# PORTX Build System

This directory contains the build tools and scripts for creating professional PORTX executables.

## Directory Structure

```
build/
├── bat2exe/                           # BAT to EXE conversion tools
│   ├── Bat_To_Exe_Converter.exe      # F2ko's BAT to EXE converter
│   └── portx_icon.ico                # PORTX application icon
├── build-portx-executable.bat        # Main build script
├── build-packages.sh                 # Package builder (for GitHub Releases)
├── build-packages.bat                # Package builder (Windows version)
└── README.md                         # This file
```

## Building PORTX Executable

### Quick Build
```bash
# From PORTX root directory
build\build-portx-executable.bat
```

### What It Does
1. **Converts** `portx.bat` to professional `portx.exe`
2. **Embeds** custom icon and metadata
3. **Installs** executable to root directory: `portx.exe`

### Professional Features Added
- ✅ Custom PORTX icon
- ✅ Version information (from VERSION file)
- ✅ Corporate metadata and branding
- ✅ 64-bit executable
- ✅ Professional appearance

### Requirements
- Windows environment
- `portx.bat` in root directory
- `VERSION` file in root directory
- `build/bat2exe/Bat_To_Exe_Converter.exe`
- `build/bat2exe/portx_icon.ico`

## Result

**Before**: `portx.bat` (script appearance)
**After**: `portx.exe` (professional application in root - like a boss!)

The executable maintains all functionality while providing corporate-friendly branding and professional metadata.

## Tools Included

### BAT to EXE Converter
- **Source**: F2ko's Bat To Exe Converter
- **License**: Freeware
- **Purpose**: Professional script-to-executable conversion
- **Features**: Icon embedding, metadata, 64-bit support

This tool is included in PORTX for users who need to convert their own batch scripts to professional executables.

## Corporate Benefits

Using `portx.exe` instead of `portx.bat` provides:
- **IT Approval**: Executable files appear more professional
- **User Trust**: Developers expect EXE launchers for toolkits  
- **Brand Recognition**: Custom icon and metadata
- **Security Perception**: Less "script-like" appearance