@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for mc/mcedit
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=mc
set EXE_RELATIVE_PATH=mcedit.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
