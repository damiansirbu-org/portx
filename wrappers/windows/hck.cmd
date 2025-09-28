@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for hck/hck
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=hck
set EXE_RELATIVE_PATH=hck.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
