@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for tinycc/tiny-libmaker
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=tinycc
set EXE_RELATIVE_PATH=tiny_libmaker.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
