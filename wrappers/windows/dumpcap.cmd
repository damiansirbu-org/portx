@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for wireshark-cli/dumpcap
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=wireshark-cli
set EXE_RELATIVE_PATH=dumpcap.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
