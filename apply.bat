@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo    APPLYING AGENT HARNESS TEMPLATE TO THIS PROJECT
echo ========================================================

set "SCRIPT_DIR=%~dp0"
set "PARENT_DIR=%SCRIPT_DIR%.."

echo [*] Target project detected: "%PARENT_DIR%"
echo [*] Installing rules, skills, and universal harness...

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" -Target "%PARENT_DIR%"

echo.
echo ========================================================
echo [SUCCESS] Template applied successfully to your project!
echo You can now delete this 'agent-harness-template' folder.
echo ========================================================
pause
