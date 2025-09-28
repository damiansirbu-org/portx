@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for pueue/pueued
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=pueue
set EXE_RELATIVE_PATH=pueued.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
