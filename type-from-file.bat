@echo off
title Type To Remote - From File
set /p INPUT_FILE=Text file path: 
if "%INPUT_FILE%"=="" exit /b 1
set /p DELAY_MS=Delay ms [25]: 
if "%DELAY_MS%"=="" set DELAY_MS=25
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0type-to-remote.ps1" -File "%INPUT_FILE%" -DelayMs %DELAY_MS% -StartDelaySec 3
pause
