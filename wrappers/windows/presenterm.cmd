@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for presenterm/presenterm
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=presenterm
set EXE_RELATIVE_PATH=presenterm.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
