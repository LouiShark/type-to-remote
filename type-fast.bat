@echo off
title Type To Remote - Fast
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0type-to-remote.ps1" -Clipboard -DelayMs 10 -StartDelaySec 3
pause
