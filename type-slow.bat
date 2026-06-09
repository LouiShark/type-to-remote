@echo off
title Type To Remote - Slow
powershell -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0type-to-remote.ps1" -Clipboard -DelayMs 60 -StartDelaySec 3
pause
