@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for premake/premake
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=premake
set EXE_RELATIVE_PATH=premake.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
