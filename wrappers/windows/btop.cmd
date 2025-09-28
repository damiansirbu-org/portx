@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for btop/btop
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=btop
set EXE_RELATIVE_PATH=btop.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
