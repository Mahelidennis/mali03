@echo off
setlocal

REM --- Configuration ---
set MALI_WORKSPACE=C:\Users\user\AndroidStudioProjects\mali03
set FLUTTER_PATH=C:\Users\user\flutter\bin\flutter.bat

echo ========================================
echo 🧪 Testing Groq API Connection
echo ========================================

REM --- Navigate to workspace ---
echo.
echo ➡️ Navigating to workspace: %MALI_WORKSPACE%
cd /d %MALI_WORKSPACE%
if %errorlevel% neq 0 (
    echo ❌ ERROR: Failed to navigate to workspace. Exiting.
    exit /b %errorlevel%
)
echo ✅ Navigated to workspace: %CD%

REM --- Create temporary test file ---
echo.
echo 📝 Creating temporary test main file...

(
echo import 'package:flutter/material.dart';
echo import 'package:firebase_core/firebase_core.dart';
echo import 'firebase_options.dart';
echo import 'test_groq_connection.dart';
echo.
echo Future^<void^> main^(^) async {
echo   WidgetsFlutterBinding.ensureInitialized^(^);
echo   
echo   // Initialize Firebase with error handling
echo   try {
echo     await Firebase.initializeApp^(options: DefaultFirebaseOptions.currentPlatform^);
echo     print^('Firebase initialized successfully'^);
echo   } catch ^(e^) {
echo     print^('Firebase initialization failed: $e'^);
echo   }
echo   
echo   runApp^(const MaterialApp^(home: TestGroqConnection^(^)^)^);
echo }
) > lib\main_test_groq.dart

echo ✅ Test file created

REM --- Run Flutter app with test main file ---
echo.
echo 🧪 Running Groq Connection Test...
echo.
echo This will:
echo 1. Test if Groq API key is configured
echo 2. Test connection to Groq API
echo 3. Test actual chat functionality
echo.
echo The app will open in Chrome for testing.
echo.

%FLUTTER_PATH% run -d chrome -t lib/main_test_groq.dart
if %errorlevel% neq 0 (
    echo ❌ ERROR: Flutter run failed. Check your Flutter setup and project.
    exit /b %errorlevel%
)

echo.
echo ========================================
echo ✅ Groq Test Initiated
echo ========================================
echo Please check the Chrome browser for the test result.

endlocal
exit /b 0

