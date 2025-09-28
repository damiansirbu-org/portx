@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for socat/socat
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=socat
set EXE_RELATIVE_PATH=socat.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
