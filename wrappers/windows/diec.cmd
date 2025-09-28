@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for detectiteasy/diec
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=detectiteasy
set EXE_RELATIVE_PATH=diec.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
