@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for nerdctl/nerdctl
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=nerdctl
set EXE_RELATIVE_PATH=nerdctl.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
