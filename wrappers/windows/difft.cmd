@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for git/difft
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=git
set EXE_RELATIVE_PATH=difft.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
