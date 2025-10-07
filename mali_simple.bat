@echo off
REM Simple Mali command script
REM Usage: mali_simple.bat [command]

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

if "%1"=="build" (
    echo Building Mali app...
    %FLUTTER_PATH% clean
    %FLUTTER_PATH% pub get
    %FLUTTER_PATH% build web --release
    robocopy build\web public /E /MIR
    echo ✅ Build complete!
) else if "%1"=="deploy" (
    echo Deploying Mali app...
    firebase deploy --only hosting
    echo ✅ Deployment complete!
) else if "%1"=="run" (
    echo Running Mali app...
    %FLUTTER_PATH% run -d chrome
) else if "%1"=="setup" (
    echo Setting up Mali workspace...
    %FLUTTER_PATH% clean
    %FLUTTER_PATH% pub get
    echo ✅ Setup complete!
) else if "%1"=="build-deploy" (
    echo Building and deploying Mali app...
    %FLUTTER_PATH% clean
    %FLUTTER_PATH% pub get
    %FLUTTER_PATH% build web --release
    robocopy build\web public /E /MIR
    firebase deploy --only hosting
    echo ✅ Build and deployment complete!
) else (
    echo Mali Command Center
    echo.
    echo Usage: mali_simple.bat [command]
    echo.
    echo Commands:
    echo   build        - Build the Mali app
    echo   deploy       - Deploy to Firebase
    echo   run          - Run the app in Chrome
    echo   setup        - Clean and get dependencies
    echo   build-deploy - Build and deploy in one command
    echo.
    echo Examples:
    echo   mali_simple.bat build
    echo   mali_simple.bat deploy
    echo   mali_simple.bat build-deploy
)

echo.
echo ✅ Command executed from: %MALI_WORKSPACE%
