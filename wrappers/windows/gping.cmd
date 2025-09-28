@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for gping/gping
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=gping
set EXE_RELATIVE_PATH=gping.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
