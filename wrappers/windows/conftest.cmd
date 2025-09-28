@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for conftest/conftest
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=conftest
set EXE_RELATIVE_PATH=conftest.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
