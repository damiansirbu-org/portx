@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for broot/broot
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=broot
set EXE_RELATIVE_PATH=broot.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
