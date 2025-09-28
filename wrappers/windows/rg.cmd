@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for ripgrep/rg
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=ripgrep
set EXE_RELATIVE_PATH=rg.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
