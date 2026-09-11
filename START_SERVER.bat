@echo off
title Shaadi Song - Local Server
echo.
echo  ============================================
echo   Shaadi Song - Starting Server...
echo  ============================================
echo.
echo  Your browser will open automatically.
echo  Keep this window open while you use the site.
echo  Close this window (or press Ctrl+C) to stop.
echo.

:: Try running directly first
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"

:: If it exits immediately, it may need elevation - try as admin
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  Trying with Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0server.ps1\"' -Verb RunAs"
)

pause
