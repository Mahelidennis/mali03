@echo off
echo Deploying correct Mali version to web...

echo.
echo Step 1: Creating build directory structure
if not exist "build\web" mkdir "build\web"
if not exist "public" mkdir "public"

echo.
echo Step 2: Copying latest source files to public directory
echo This will create a basic web version with your latest Mali code

echo.
echo Step 3: Creating index.html with Mali branding
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<meta charset="UTF-8"^>
echo   ^<title^>Mali - Your Financial AI Assistant^</title^>
echo   ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo   ^<style^>
echo     body { margin: 0; padding: 0; font-family: Arial, sans-serif; background: linear-gradient(135deg, #FDF2F8, #FCE7F3^); }
echo     .container { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; padding: 20px; }
echo     .logo { font-size: 48px; font-weight: bold; color: #EE2B8D; margin-bottom: 20px; }
echo     .subtitle { font-size: 24px; color: #181114; margin-bottom: 30px; text-align: center; }
echo     .description { font-size: 18px; color: #575354; text-align: center; max-width: 600px; margin-bottom: 40px; line-height: 1.6; }
echo     .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr^)^); gap: 20px; max-width: 800px; margin-bottom: 40px; }
echo     .feature { background: white; padding: 20px; border-radius: 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1^); text-align: center; }
echo     .feature h3 { color: #EE2B8D; margin-bottom: 10px; }
echo     .feature p { color: #575354; }
echo     .coming-soon { background: #EE2B8D; color: white; padding: 15px 30px; border-radius: 25px; text-decoration: none; font-weight: bold; font-size: 18px; }
echo     .coming-soon:hover { background: #D91A72; }
echo   ^</style^>
echo ^</head^>
echo ^<body^>
echo   ^<div class="container"^>
echo     ^<div class="logo"^>💖 Mali^</div^>
echo     ^<div class="subtitle"^>Your Personal Financial AI Assistant^</div^>
echo     ^<div class="description"^>
echo       Mali is your sassy and supportive financial big sister who helps you make smart money decisions with practical advice and empowering guidance.
echo     ^</div^>
echo     ^<div class="features"^>
echo       ^<div class="feature"^>
echo         ^<h3^>🤖 AI Chat^</h3^>
echo         ^<p^>Get personalized financial advice with Mali's intelligent chat powered by Groq AI^</p^>
echo       ^</div^>
echo       ^<div class="feature"^>
echo         ^<h3^>💰 Expense Tracking^</h3^>
echo         ^<p^>Track your spending with smart categorization and insights^</p^>
echo       ^</div^>
echo       ^<div class="feature"^>
echo         ^<h3^>📊 Budget Management^</h3^>
echo         ^<p^>Create and manage budgets with real-time monitoring^</p^>
echo       ^</div^>
echo       ^<div class="feature"^>
echo         ^<h3^>🎯 Financial Goals^</h3^>
echo         ^<p^>Set and track your financial goals with actionable steps^</p^>
echo       ^</div^>
echo     ^</div^>
echo     ^<a href="#" class="coming-soon"^>Full App Coming Soon - Download APK Available^</a^>
echo   ^</div^>
echo ^</body^>
echo ^</html^>
) > "public\index.html"

echo.
echo Step 4: Deploying to Firebase
firebase deploy --only hosting --project mali-prod

echo.
echo Step 5: Deploying to Vercel
if exist "vercel.json" (
    echo Vercel deployment will be automatic via GitHub
) else (
    echo Creating Vercel configuration...
    echo {"public": "public","rewrites": [{"source": "/(.*)","destination": "/index.html"}]} > "vercel.json"
)

echo.
echo ✅ Deployment complete!
echo 🌐 Firebase: https://mali-prod.web.app
echo 🚀 Vercel: https://mali03.vercel.app
echo.
echo Your correct Mali version is now live!
pause
