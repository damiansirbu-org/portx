@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for act/act
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=act
set EXE_RELATIVE_PATH=act.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
