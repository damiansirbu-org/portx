@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for yq/yq
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=yq
set EXE_RELATIVE_PATH=yq.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
