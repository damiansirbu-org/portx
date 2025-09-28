@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for pnpm/pnpm
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=pnpm
set EXE_RELATIVE_PATH=pnpm.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
