@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for python-micromamba/micromamba
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=python-micromamba
set EXE_RELATIVE_PATH=micromamba.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
