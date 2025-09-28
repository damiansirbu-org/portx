@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for powershell-core/pwsh
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=powershell-core
set EXE_RELATIVE_PATH=pwsh.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
