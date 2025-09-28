@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for lizard/lizard
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=lizard
set EXE_RELATIVE_PATH=lizard.bat
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
