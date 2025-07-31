@echo off
rem Git Bash Portable Launcher with custom HOME
rem
rem SYSTEM OVERVIEW:
rem Git Bash startup sequence: sh.exe -> /etc/profile -> /etc/profile.d/*.sh -> ~/.bash_profile -> ~/.bashrc
rem - /etc/profile: System-wide config, sets PATH, sources profile.d scripts
rem - /etc/profile.d/*.sh: Additional system configs loaded alphabetically
rem - ~/.bash_profile: User's login shell config (only for login shells)
rem - ~/.bashrc: User's interactive shell config (sourced by .bash_profile)
rem
rem PROBLEM: Default Git Bash uses Windows home (C:\Users\%USERNAME%) via nsswitch.conf
rem instead of MSYS2 home (/home/%USERNAME%), breaking portable installations
rem
rem SOLUTION: Set HOME env var BEFORE launching sh.exe, overriding nsswitch.conf
rem This makes Git Bash use /home/%USERNAME% where our .bashrc and configs live

set HOME=/home/portable
set USER=portable
set USERNAME=portable

rem echo Setting HOME to: %HOME%
rem echo Setting USER to: %USER%

rem Launch sh.exe directly with login shell
"%~dp0\bin\sh.exe" --login -i