@echo off
echo Deploying Mali web app...
echo.

REM Deploy to Firebase
echo Deploying to Firebase...
firebase deploy --only hosting --project mali-prod

echo.
echo ✅ Deployment complete!
echo.
echo Your updated Mali app should now be live at:
echo https://mali-prod.web.app
echo.

pause
