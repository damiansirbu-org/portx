@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for podman/win-sshproxy
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=podman
set EXE_RELATIVE_PATH=win-sshproxy.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
