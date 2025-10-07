@echo off
REM Setup Global Deploy Command for Mali App
REM This adds the Mali project to PATH so you can run 'deploy' from anywhere

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03

echo ========================================
echo 🌐 Setting up Global Deploy Command
echo ========================================
echo.

echo 📁 Mali workspace: %MALI_WORKSPACE%
echo.

REM Check if deploy.bat exists
if not exist "%MALI_WORKSPACE%\deploy.bat" (
    echo ❌ ERROR: deploy.bat not found in Mali workspace
    echo Please make sure the Mali project is set up correctly.
    pause
    exit /b 1
)

echo ✅ deploy.bat found in Mali workspace
echo.

REM Add to PATH for current session
echo 🔧 Adding Mali workspace to PATH for current session...
set PATH=%PATH%;%MALI_WORKSPACE%

echo ✅ PATH updated for current session
echo.

echo ========================================
echo 🎉 Global Deploy Command Setup Complete!
echo ========================================
echo.
echo You can now run 'deploy' from anywhere in your terminal!
echo.
echo To make this permanent, you need to add this to your system PATH:
echo   %MALI_WORKSPACE%
echo.
echo Instructions for permanent setup:
echo 1. Open System Properties → Advanced → Environment Variables
echo 2. Edit the "Path" variable in System Variables
echo 3. Add: %MALI_WORKSPACE%
echo 4. Click OK and restart your terminal
echo.
echo Test the command now:
echo   deploy
echo.
pause
