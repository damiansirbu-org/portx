@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for subfinder/subfinder
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=subfinder
set EXE_RELATIVE_PATH=subfinder.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
