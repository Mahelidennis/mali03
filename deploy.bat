@echo off
REM Simple deploy command that runs deploy_and_backup.bat
REM Usage: deploy

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

REM Check if deploy_and_backup.bat exists
if not exist "deploy_and_backup.bat" (
    echo ❌ ERROR: deploy_and_backup.bat not found in %MALI_WORKSPACE%
    echo Please make sure you are in the correct Mali project directory.
    pause
    exit /b 1
)

REM Run the deploy and backup script
echo 🚀 Running Mali app deployment...
call deploy_and_backup.bat
