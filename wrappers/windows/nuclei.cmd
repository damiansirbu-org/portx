@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for nuclei/nuclei
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=nuclei
set EXE_RELATIVE_PATH=nuclei.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
