@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for shellcheck/shellcheck
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=shellcheck
set EXE_RELATIVE_PATH=shellcheck.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
