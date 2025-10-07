@echo off
echo Building Mali web app with latest code...
echo.

REM Add Flutter to PATH
set PATH=%PATH%;E:\flutter\bin

REM Clean previous builds
echo Cleaning previous builds...
if exist "build\web" rmdir /s /q "build\web"

REM Build web app
echo Building web app...
flutter build web --release

REM Check if build was successful
if exist "build\web\index.html" (
    echo.
    echo ✅ Build successful! Web files created in build\web\
    echo.
    echo Ready to deploy!
) else (
    echo.
    echo ❌ Build failed. Please check the errors above.
)

pause
