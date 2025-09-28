@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for jq/jq
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=jq
set EXE_RELATIVE_PATH=jq.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
