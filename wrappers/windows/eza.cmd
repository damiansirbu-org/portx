@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for eza/eza
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=eza
set EXE_RELATIVE_PATH=eza.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
