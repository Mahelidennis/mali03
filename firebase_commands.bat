@echo off
REM Firebase command aliases for Mali project
REM Usage: firebase_commands.bat [command] [args]

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

REM Execute Firebase command with all arguments
firebase %*

echo.
echo ✅ Firebase command executed from: %MALI_WORKSPACE%
