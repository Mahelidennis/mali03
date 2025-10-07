@echo off
REM Deploy and Backup Script for Mali App
REM Automatically backs up to Git, builds, and deploys to Firebase

setlocal enabledelayedexpansion

REM Set paths
set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

echo ========================================
echo 🚀 Mali App Deploy and Backup Script
echo ========================================
echo.

REM Navigate to workspace
cd /d %MALI_WORKSPACE%
echo ✅ Navigated to workspace: %MALI_WORKSPACE%
echo.

REM Step 1: Git Add All Changes
echo 📝 Step 1: Adding all changes to Git...
git add .
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to add files to Git
    echo Please check your Git configuration and try again.
    pause
    exit /b 1
)
echo ✅ All files added to Git successfully
echo.

REM Step 2: Create Commit
echo 💾 Step 2: Creating commit...
git commit -m "Auto backup before deploy"
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to create commit
    echo This might be because there are no changes to commit.
    echo Please check git status and try again.
    pause
    exit /b 1
)
echo ✅ Commit created successfully
echo.

REM Step 3: Push to GitHub
echo 🔄 Step 3: Pushing changes to GitHub...
git push origin main
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to push to GitHub
    echo Please check your GitHub credentials and repository access.
    echo Make sure you have set up the remote repository correctly.
    pause
    exit /b 1
)
echo ✅ Changes pushed to GitHub successfully
echo.

REM Step 4: Build Web Version
echo 🔨 Step 4: Building web version...
echo Cleaning previous builds...
%FLUTTER_PATH% clean
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to clean Flutter project
    echo Please check your Flutter installation and try again.
    pause
    exit /b 1
)

echo Getting dependencies...
%FLUTTER_PATH% pub get
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to get Flutter dependencies
    echo Please check your pubspec.yaml and internet connection.
    pause
    exit /b 1
)

echo Building for web...
%FLUTTER_PATH% build web --release
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to build Flutter web app
    echo Please check your Flutter installation and project configuration.
    pause
    exit /b 1
)
echo ✅ Web build completed successfully
echo.

REM Step 5: Copy to Public Directory
echo 📁 Step 5: Copying build to public directory...
robocopy build\web public /E /MIR
if %errorlevel% gtr 1 (
    echo ❌ ERROR: Failed to copy build files to public directory
    echo Please check file permissions and try again.
    pause
    exit /b 1
)
echo ✅ Build files copied to public directory
echo.

REM Step 6: Deploy to Firebase
echo 🌐 Step 6: Deploying to Firebase...
firebase deploy --only hosting
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to deploy to Firebase
    echo Please check your Firebase configuration and authentication.
    echo Make sure you are logged in to Firebase CLI.
    pause
    exit /b 1
)
echo ✅ Deployment to Firebase completed successfully
echo.

REM Success Message
echo ========================================
echo 🎉 SUCCESS! Mali App Deployed Successfully
echo ========================================
echo.
echo ✅ All steps completed:
echo   1. Git backup created and pushed to GitHub
echo   2. Web version built successfully
echo   3. Deployed to Firebase hosting
echo.
echo 🌐 Your app is now live at: https://mali-prod.web.app
echo 📊 Check the deployment status in Firebase Console
echo.
echo Press any key to exit...
pause >nul
exit /b 0
