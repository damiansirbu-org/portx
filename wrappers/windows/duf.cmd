@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for duf/duf
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=duf
set EXE_RELATIVE_PATH=duf.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
