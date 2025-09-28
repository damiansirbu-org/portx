@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for ctop/ctop
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=ctop
set EXE_RELATIVE_PATH=ctop.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
