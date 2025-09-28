@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for just/just
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=just
set EXE_RELATIVE_PATH=just.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
