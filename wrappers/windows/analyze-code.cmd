@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for analyze-code/analyze-code
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=analyze-code
set EXE_RELATIVE_PATH=analyze-code.sh
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
