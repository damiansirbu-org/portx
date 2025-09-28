@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for bun/bun
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=bun
set EXE_RELATIVE_PATH=bun.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
