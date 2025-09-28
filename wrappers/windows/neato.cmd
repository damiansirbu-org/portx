@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for graphwiz/neato
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=graphwiz
set EXE_RELATIVE_PATH=bin/neato.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
