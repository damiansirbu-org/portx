@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for ouch/ouch
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=ouch
set EXE_RELATIVE_PATH=ouch.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
