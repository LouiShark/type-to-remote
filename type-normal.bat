@echo off
title Type To Remote - Normal
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0type-to-remote.ps1" -Clipboard -DelayMs 25 -StartDelaySec 3
pause
