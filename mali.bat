@echo off
REM Master Mali command script
REM Usage: mali.bat [flutter|firebase|build|deploy|run] [args]

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

if "%1"=="flutter" (
    echo Running Flutter command...
    shift
    %FLUTTER_PATH% %1 %2 %3 %4 %5 %6 %7 %8 %9
) else if "%1"=="firebase" (
    echo Running Firebase command...
    shift
    firebase %1 %2 %3 %4 %5 %6 %7 %8 %9
) else if "%1"=="build" (
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
) else (
    echo Mali Command Center
    echo.
    echo Usage: mali.bat [command]
    echo.
    echo Commands:
    echo   flutter [args]  - Run Flutter commands
    echo   firebase [args] - Run Firebase commands
    echo   build          - Build the Mali app
    echo   deploy         - Deploy to Firebase
    echo   run            - Run the app in Chrome
    echo   setup          - Clean and get dependencies
    echo.
    echo Examples:
    echo   mali.bat flutter --version
    echo   mali.bat firebase deploy --only hosting
    echo   mali.bat build
    echo   mali.bat deploy
)

echo.
echo ✅ Command executed from: %MALI_WORKSPACE%
