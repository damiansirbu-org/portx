@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for rustscan/rustscan
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=rustscan
set EXE_RELATIVE_PATH=rustscan.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
