@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for figlet/figlet
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=figlet
set EXE_RELATIVE_PATH=figlet.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
