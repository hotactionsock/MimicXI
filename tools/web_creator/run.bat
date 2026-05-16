@echo off
:: MimicXI Web Character Creator — Windows launcher
:: Double-click this file, or run from a command prompt in tools\web_creator\

cd /d "%~dp0"

echo MimicXI Character Creator
echo --------------------------

:: Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install Python 3.10+ and ensure it is on your PATH.
    pause
    exit /b 1
)

:: Create venv if it doesn't exist
if not exist ".venv\Scripts\python.exe" (
    echo Creating virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo Installing dependencies...
    .venv\Scripts\pip install --quiet -r requirements.txt
    if errorlevel 1 (
        echo ERROR: pip install failed. Check requirements.txt and your network connection.
        pause
        exit /b 1
    )
)

echo Starting server at http://127.0.0.1:5000
echo Press Ctrl+C to stop.
echo.

.venv\Scripts\python app.py

:: If we get here the server exited — keep window open to read any error
echo.
echo Server stopped.
pause
