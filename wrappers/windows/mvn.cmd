@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for maven/mvn
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=maven
set EXE_RELATIVE_PATH=bin/mvn.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
