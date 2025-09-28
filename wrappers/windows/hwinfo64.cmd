@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for hwinfo/hwinfo64
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=hwinfo
set EXE_RELATIVE_PATH=HWiNFO64.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
