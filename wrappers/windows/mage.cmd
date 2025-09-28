@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for mage/mage
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=mage
set EXE_RELATIVE_PATH=mage.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
