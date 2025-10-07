@echo off
echo Setting up Mali workspace...
echo.

REM Set workspace path
set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

echo ✅ Workspace set to: %MALI_WORKSPACE%
echo ✅ Flutter path: %FLUTTER_PATH%
echo.

REM Test Flutter
echo Testing Flutter...
%FLUTTER_PATH% --version

echo.
echo ✅ Workspace setup complete!
echo 🚀 All commands will now run from: %MALI_WORKSPACE%
echo.
pause
