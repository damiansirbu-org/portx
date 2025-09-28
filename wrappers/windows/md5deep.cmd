@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for hashdeep/md5deep
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=hashdeep
set EXE_RELATIVE_PATH=md5deep.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
