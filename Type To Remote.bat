@echo off
title Type To Remote
cd /d "%~dp0"

:menu
cls
echo Type To Remote
echo.
echo 1. Type clipboard - normal 25 ms
echo 2. Type clipboard - slow 60 ms
echo 3. Type clipboard - fast 10 ms
echo 4. Type from text file
echo 5. Exit
echo.
choice /c 12345 /n /m "Choose: "

if errorlevel 5 exit /b 0
if errorlevel 4 call "%~dp0type-from-file.bat" & goto menu
if errorlevel 3 call "%~dp0type-fast.bat" & goto menu
if errorlevel 2 call "%~dp0type-slow.bat" & goto menu
if errorlevel 1 call "%~dp0type-normal.bat" & goto menu
