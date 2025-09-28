@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for age/age-keygen
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=age
set EXE_RELATIVE_PATH=age-keygen.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
