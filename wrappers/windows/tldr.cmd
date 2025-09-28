@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for tealdeer/tldr
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=tealdeer
set EXE_RELATIVE_PATH=tealdeer.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
