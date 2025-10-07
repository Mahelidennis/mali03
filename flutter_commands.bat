@echo off
REM Flutter command aliases for Mali project
REM Usage: flutter_commands.bat [command] [args]

set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

REM Navigate to workspace
cd /d %MALI_WORKSPACE%

REM Execute Flutter command with all arguments
%FLUTTER_PATH% %*

echo.
echo ✅ Command executed from: %MALI_WORKSPACE%
