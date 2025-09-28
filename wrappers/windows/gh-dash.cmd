@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for gh-dash/gh-dash
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=gh-dash
set EXE_RELATIVE_PATH=gh-dash.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
