@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for chdig/chdig
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=chdig
set EXE_RELATIVE_PATH=chdig.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
