@echo off
REM Quick Deploy - Fast deployment without full backup
REM This skips Git operations and uses existing build if available

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

echo ========================================
echo 🚀 Quick Mali Deploy
echo ========================================
echo.

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

REM Check if we have a recent build
if exist "build\web\main.dart.js" (
    echo ✅ Found existing build, using it...
    robocopy build\web public /E /MIR
    echo ✅ Build files copied to public directory
) else (
    echo 🔨 Building web version...
    %FLUTTER_PATH% build web --release
    robocopy build\web public /E /MIR
    echo ✅ Build completed and copied
)

echo.
echo 🌐 Deploying to Firebase...
firebase deploy --only hosting

echo.
echo ✅ Quick deployment complete!
echo 🌐 Visit: https://mali-prod.web.app
echo.
pause
