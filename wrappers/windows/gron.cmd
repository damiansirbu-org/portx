@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for gron/gron
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=gron
set EXE_RELATIVE_PATH=gron.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
