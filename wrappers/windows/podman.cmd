@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for podman/podman
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=podman
set EXE_RELATIVE_PATH=podman.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
