@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for nmap/npcap-installer
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=nmap
set EXE_RELATIVE_PATH=npcap-1.83.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
