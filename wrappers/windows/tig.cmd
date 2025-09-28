@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for git/tig
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=git
set EXE_RELATIVE_PATH=tig.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
