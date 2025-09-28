@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for officetopdf/officetopdf
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=officetopdf
set EXE_RELATIVE_PATH=OfficeToPDF.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
