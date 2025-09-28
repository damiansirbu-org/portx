@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for exiftool/exiftool-k
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=exiftool
set EXE_RELATIVE_PATH=exiftool(-k).exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
