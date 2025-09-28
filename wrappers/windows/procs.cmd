@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for procs/procs
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=procs
set EXE_RELATIVE_PATH=procs.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
