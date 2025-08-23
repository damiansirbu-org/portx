@echo off
rem PORTX Shell Wrapper - Portable POSIX Environment for Windows
rem
rem PURPOSE: Simple shell launcher wrapper for Total Commander and other external tools
rem This wrapper provides a single-parameter entry point for file managers and IDEs
rem that have limited command-line parameter support or external tool integration.
rem
rem USAGE:
rem   portx.cmd                    - Launch PORTX interactive shell
rem   Total Commander integration - Configure as external tool: C:\App\Git\home\portx\portx-wrapper.cmd
rem   IDE integration             - Use as terminal: C:\App\Git\home\portx\portx-wrapper.cmd
rem   File manager integration    - Add to "Open with" menu: C:\App\Git\home\portx\portx-wrapper.cmd
rem
rem ARCHITECTURE:
rem   - Uses Git for Windows with preserved digital signatures
rem   - Environment configured via /etc/profile (no external variable hacks)
rem   - Maintains Windows security compliance (SmartScreen, AppLocker compatible)
rem   - See doc/portx-architecture.md for complete technical documentation
rem
rem For package management, manual pages, and advanced features, use: portx-tools.cmd

rem Launch PORTX shell with login initialization
rem This preserves Git for Windows digital signatures while loading portable environment
rem Dynamically detect Git Bash root and launch sh.exe
for %%I in ("%~dp0..\..") do set "GIT_BASH_ROOT=%%~fI"
"%GIT_BASH_ROOT%\bin\sh.exe" --login -i