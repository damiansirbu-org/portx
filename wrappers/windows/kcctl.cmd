@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for kcctl/kcctl
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=kcctl
set EXE_RELATIVE_PATH=bin/kcctl.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
