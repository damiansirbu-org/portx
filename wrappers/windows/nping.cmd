@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for nmap/nping
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=nmap
set EXE_RELATIVE_PATH=nping.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
