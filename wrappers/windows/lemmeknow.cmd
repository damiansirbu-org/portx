@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for lemmeknow/lemmeknow
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=lemmeknow
set EXE_RELATIVE_PATH=lemmeknow.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
