@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for peco/peco
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=peco
set EXE_RELATIVE_PATH=peco.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
