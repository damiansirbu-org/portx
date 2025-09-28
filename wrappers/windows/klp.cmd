@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for klp/klp
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=klp
set EXE_RELATIVE_PATH=klp.bat
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
