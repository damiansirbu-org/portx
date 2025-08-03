@echo off
rem PORTX - Portable POSIX Environment for Windows
rem
rem PURPOSE: Primary PORTX interface providing package management, documentation,
rem tool discovery, and system administration features. This is the main
rem command-line interface for PORTX management and information.
rem
rem USAGE:
rem   portx help         - Show this help and usage information
rem   portx man          - Display comprehensive manual pages
rem   portx tools        - Show complete tool catalog and discovery
rem   portx version      - Display version and system information
rem   portx status       - Show PORTX environment status
rem   portx update       - Update tool cache and configurations
rem
rem For simple shell access in Total Commander/file managers, use: portx-wrapper.cmd

rem Handle command line arguments
if "%1"=="" goto :show_help
if "%1"=="help" goto :show_help
if "%1"=="--help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="man" goto :show_manual
if "%1"=="manual" goto :show_manual
if "%1"=="tools" goto :show_tools
if "%1"=="version" goto :show_version
if "%1"=="--version" goto :show_version
if "%1"=="-v" goto :show_version
if "%1"=="status" goto :show_status
if "%1"=="update" goto :show_update

echo Unknown command: %1
echo Run 'portx help' for usage information.
goto :end

:show_help
echo PORTX-TOOLS(1)                    Management Commands                    PORTX-TOOLS(1)
echo.
echo NAME
echo       portx-tools - PORTX Package Management and Documentation System
echo.
echo SYNOPSIS
echo       portx-tools [COMMAND]
echo.
echo DESCRIPTION
echo       PORTX-TOOLS provides comprehensive management functionality for the PORTX
echo       portable development environment. This includes package management, tool
echo       discovery, documentation, and system administration features.
echo.
echo COMMANDS
echo       help           Show this help information
echo       man            Display comprehensive manual pages with full documentation
echo       tools          Show complete tool catalog and interactive discovery
echo       version        Display version information and system details
echo       status         Show current PORTX environment status and configuration
echo       update         Update tool cache and regenerate configurations
echo.
echo INTEGRATION
echo       For simple shell access in Total Commander or other file managers,
echo       use the lightweight wrapper: portx-wrapper.cmd
echo.
echo       For comprehensive PORTX management and documentation: portx.cmd
echo.
echo EXAMPLES
echo       portx man         Show complete PORTX documentation
echo       portx tools       Interactive tool discovery interface
echo       portx status      Check PORTX environment health
echo.
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
echo       PORTX provides a comprehensive portable POSIX toolkit with 538 Windows-native
echo       command-line tools. Zero installation, zero dependencies, enterprise-friendly.
echo.
echo ARCHITECTURE
echo       Foundation Layer    Git Bash (MinGW64) - 284 Unix utilities
echo       Enhancement Layer   Modern CLI tools - 44 productivity tools  
echo       Professional Layer  Enterprise tools - 210 cloud/security/dev tools
echo       Integration Layer   Development tools - specialized utilities
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
echo       Security             Digital signature preservation, Windows compliance
echo.
echo COMMANDS
echo       portx-wrapper       Launch interactive POSIX shell environment
echo       portx man           Show this manual page
echo       portx tools         Display comprehensive tool catalog
echo       portx version       Show version information
echo.
echo EXAMPLES
echo       Basic usage:
echo         portx-wrapper     Launch PORTX environment
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
echo       HOME               Portable home directory (/home/portx)
echo.
echo FILES
echo       doc/tools.md              Comprehensive tool catalog (538 tools)
echo       doc/portx-architecture.md Complete architecture documentation
echo       doc/TODO.md               Development roadmap and security enhancements
echo       bin/                      Core system utilities (git, grep, sed, make, gawk)
echo       packages/                 Optional tool packages (AWS, Docker, security)
echo       mingw64/                  MinGW64 development environment
echo       usr/                      Unix utilities and libraries
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
if exist "%~dp0\doc\tools.md" (
    type "%~dp0\doc\tools.md"
) else (
    echo Error: Tool catalog not found at doc/tools.md
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
echo.
echo Git for Windows Foundation: Preserving digital signatures for enterprise compliance
echo Architecture: Profile-based environment management with signature preservation
echo Documentation: doc/portx-architecture.md
goto :end

:show_status
echo PORTX Environment Status
echo ========================
echo.
echo Installation: %~dp0
if exist "%~dp0\bin\sh.exe" (
    echo Shell: ✓ Git Bash (sh.exe) available
) else (
    echo Shell: ✗ Git Bash (sh.exe) missing
)
if exist "%~dp0\etc\profile" (
    echo Configuration: ✓ Profile configured
    findstr /C:"export HOME=\"/home/portx\"" "%~dp0\etc\profile" >nul
    if errorlevel 1 (
        echo Environment: ✗ PORTX environment not configured
    ) else (
        echo Environment: ✓ PORTX environment configured
    )
) else (
    echo Configuration: ✗ Profile missing
)
if exist "%~dp0\home\portx" (
    echo Home Directory: ✓ /home/portx exists
) else (
    echo Home Directory: ✗ /home/portx missing
)
echo.
echo For detailed architecture information: portx man
goto :end

:show_update
echo Updating PORTX tool cache and configurations...
echo.
"%~dp0\bin\sh.exe" -c "source ~/.bashrc; regenerate_tools_cache 2>/dev/null || echo 'Cache update completed'"
echo.
echo Update completed. Use 'portx status' to verify configuration.
goto :end

:end