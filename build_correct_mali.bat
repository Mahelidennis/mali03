@echo off
echo Building the correct Mali app...
echo.

REM Set Flutter path
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

REM Clean previous builds
echo Cleaning previous builds...
%FLUTTER_PATH% clean

REM Get dependencies
echo Getting dependencies...
%FLUTTER_PATH% pub get

REM Build for web
echo Building for web...
%FLUTTER_PATH% build web --release

REM Copy to public directory
echo Copying to public directory...
robocopy build\web public /E /MIR

REM Deploy to Firebase
echo Deploying to Firebase...
firebase deploy --only hosting

echo.
echo ✅ Mali app deployed successfully!
echo 🌐 Visit: https://mali-prod.web.app
pause
