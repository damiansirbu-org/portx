@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for glow/glow
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=glow
set EXE_RELATIVE_PATH=glow.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
