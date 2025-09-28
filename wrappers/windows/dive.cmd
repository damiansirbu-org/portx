@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for dive/dive
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=dive
set EXE_RELATIVE_PATH=dive.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
