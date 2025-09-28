@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for oha/oha
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=oha
set EXE_RELATIVE_PATH=oha.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
