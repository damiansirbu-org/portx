@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for docker-compose/docker-compose
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=docker-compose
set EXE_RELATIVE_PATH=docker-compose.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
