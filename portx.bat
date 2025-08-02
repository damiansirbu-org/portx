@echo off
rem PORTX - Portable POSIX Environment for Windows
rem Git Bash Portable Launcher with custom HOME and manual system
rem
rem SYSTEM OVERVIEW:
rem Git Bash startup sequence: sh.exe -> /etc/profile -> /etc/profile.d/*.sh -> ~/.bash_profile -> ~/.bashrc
rem - /etc/profile: System-wide config, sets PATH, sources profile.d scripts
rem - /etc/profile.d/*.sh: Additional system configs loaded alphabetically
rem - ~/.bash_profile: User's login shell config (only for login shells)
rem - ~/.bashrc: User's interactive shell config (sourced by .bash_profile)
rem
rem PROBLEM: Default Git Bash uses Windows home (C:\Users\%USERNAME%) via nsswitch.conf
rem instead of MSYS2 home (/home/%USERNAME%), breaking portable installations
rem
rem SOLUTION: Set HOME env var BEFORE launching sh.exe, overriding nsswitch.conf
rem This makes Git Bash use /home/%USERNAME% where our .bashrc and configs live

rem Handle command line arguments
if "%1"=="man" goto :show_manual
if "%1"=="manual" goto :show_manual
if "%1"=="help" goto :show_manual
if "%1"=="--help" goto :show_manual
if "%1"=="-h" goto :show_manual
if "%1"=="tools" goto :show_tools
if "%1"=="version" goto :show_version
if "%1"=="--version" goto :show_version
if "%1"=="-v" goto :show_version

rem Set portable environment
set HOME=/home/portable
set USER=portable
set USERNAME=portable

rem Launch sh.exe directly with login shell
"%~dp0\bin\sh.exe" --login -i
goto :end

:show_manual
echo PORTX(1)                          User Commands                         PORTX(1)
echo.
echo NAME
echo       portx - Portable POSIX Environment for Windows
echo.
echo SYNOPSIS  
echo       portx [COMMAND]
echo.
echo DESCRIPTION
echo       PORTX provides a comprehensive portable POSIX toolkit with 501 Windows-native
echo       command-line tools. Zero installation, zero dependencies, enterprise-friendly.
echo.
echo ARCHITECTURE
echo       Foundation Layer    Git Bash (MinGW64) - 272 Unix utilities
echo       Enhancement Layer   Modern CLI tools - 44 productivity tools  
echo       Professional Layer  Enterprise tools - 158 cloud/security/dev tools
echo       Integration Layer   Development tools - 27+ specialized utilities
echo.
echo TOOL CATEGORIES
echo       Core System         Essential Unix utilities, file management, text processing
echo       Text Processing     Searching, formatting, JSON/YAML processing, editors
echo       Security           Cryptographic tools, antivirus, vulnerability scanners
echo       Development        Git, compilers, version control, profiling tools
echo       Network            Diagnostics, protocols, communication tools
echo       Containers         Docker, Kubernetes, container management
echo       Cloud              AWS CLI, Azure CLI, cloud service management
echo       Mobile             Android development and device management
echo       System Analysis    Microsoft SysInternals diagnostic suite
echo       Windows Automation NirCmd system control utilities
echo.
echo KEY ADVANTAGES
echo       Enterprise Compatible  No installation, no registry entries, no admin rights
echo       Performance           Native Windows executables, no emulation layers
echo       Portability          Self-contained, runs from any directory
echo       Completeness         Full POSIX shell plus modern enterprise tooling
echo       Integration          Seamless tool interoperability via PATH management
echo.
echo COMMANDS
echo       portx               Launch interactive POSIX shell environment
echo       portx man           Show this manual page
echo       portx tools         Display comprehensive tool catalog
echo       portx version       Show version information
echo.
echo EXAMPLES
echo       Basic usage:
echo         portx             Launch PORTX environment
echo         ls -la            List files with details
echo         rg pattern        Fast recursive search with ripgrep
echo         fd pattern        Fast find alternative
echo.
echo       Professional workflows:
echo         aws s3 ls         List S3 buckets
echo         kubectl get pods  List Kubernetes pods
echo         terraform plan    Infrastructure planning
echo         nuclei -l urls    Vulnerability scanning
echo.
echo       System analysis:
echo         psinfo64 -accepteula      System information
echo         handle64 -accepteula      Open files and handles
echo         nircmd speak text "test"  Text-to-speech
echo.
echo ENVIRONMENT
echo       PORTX_ROOT         Root directory of PORTX installation
echo       PATH               Enhanced with all tool directories  
echo       HOME               Portable home directory (/home/portable)
echo.
echo FILES
echo       doc-portx/tools.md    Comprehensive tool catalog (501 tools)
echo       doc-portx/TODO.md     Development roadmap and security enhancements
echo       bin/                  Core system executables
echo       bin-ext/              Enhanced Unix tools (ripgrep, bat, fzf, jq)
echo       bin-tools/            Professional tools (AWS, Docker, security)
echo       mingw64/              MinGW64 development environment
echo       usr/                  Unix utilities and libraries
echo.
echo AUTHOR
echo       Written by Damian Sirbu.
echo.
echo COPYRIGHT
echo       PORTX delivers enterprise-grade Unix functionality on Windows without
echo       the complexity or security concerns of traditional emulation approaches.
echo.
goto :end

:show_tools
if exist "%~dp0\doc-portx\tools.md" (
    type "%~dp0\doc-portx\tools.md"
) else (
    echo Error: Tool catalog not found at doc-portx/tools.md
    echo Run 'portx man' for general documentation.
)
goto :end

:show_version
if exist "%~dp0\VERSION" (
    setlocal enabledelayedexpansion
    set /p version=<"%~dp0\VERSION"
    echo PORTX version !version!
) else (
    echo PORTX version unknown
)
goto :end

:end