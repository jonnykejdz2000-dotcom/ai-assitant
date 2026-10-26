@echo off
REM ============================================================
REM  Build AIAssistant.exe from ai_assistant_free.py
REM  Put in ONE folder: build.bat, ai_assistant_free.py and
REM  (optionally) your icon app.ico. Then double-click build.bat.
REM  Python 3.10-3.14 must be installed ("Add python.exe to PATH").
REM ============================================================

REM --- administrator rights are needed to close the running (elevated) AIAssistant.exe
net session >nul 2>&1
if errorlevel 1 (
    echo Requesting administrator rights to close the running program...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
cd /d "%~dp0"

echo.
echo [0/3] Closing running copy of AIAssistant...
taskkill /f /im AIAssistant.exe
timeout /t 2 /nobreak >nul
if exist "dist\AIAssistant.exe" del /f /q "dist\AIAssistant.exe"
if exist "dist\AIAssistant.exe" (
    echo.
    echo ERROR: dist\AIAssistant.exe is still locked. Close it from the tray icon ^(right click - Exit^),
    echo or temporarily pause your antivirus / add this folder to its exclusions, then run again.
    goto fail
)

echo.
echo [1/3] Installing dependencies...
python -m pip install --upgrade pip
python -m pip install requests mss pyautogui pillow pyperclip pysocks pystray pyinstaller
REM Voice input is optional and needs no compiler: audio is captured via sounddevice.
REM If this line fails for any reason, the program still works, just without the mic button.
python -m pip install SpeechRecognition sounddevice numpy
if errorlevel 1 goto fail

REM  Icon: used for the exe file, the tray and the settings window
set ICONARGS=
if exist app.ico (
    set ICONARGS=--icon app.ico --add-data "app.ico;."
    echo Icon found: app.ico
) else (
    echo WARNING: app.ico not found - the program will get a default icon.
)

echo.
echo [2/3] Building exe (1-3 minutes)...
python -m PyInstaller --noconfirm --clean --onefile --noconsole --name AIAssistant ^
  %ICONARGS% ^
  --hidden-import pystray._win32 --hidden-import socks ^
  --hidden-import pymsgbox --hidden-import pytweening --hidden-import pyscreeze ^
  ai_assistant_free.py
if errorlevel 1 goto fail

echo.
echo [3/3] Done!
echo Your program: %~dp0dist\AIAssistant.exe
echo.
pause
exit /b 0

:fail
echo.
echo BUILD FAILED. Scroll up to read the error.
pause
exit /b 1
