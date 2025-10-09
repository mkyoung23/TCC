@echo off
echo ========================================
echo TIME CAPSULE CAMERA - Firebase Setup
echo ========================================
echo.
echo This will get your Firebase token for CodeMagic
echo.
echo Step 1: Installing Firebase CLI...
npm install -g firebase-tools
echo.
echo Step 2: Getting your token...
echo.
echo IMPORTANT: A browser will open. Log in with:
echo Email: M.K.Young240@gmail.com
echo.
pause
firebase login:ci
echo.
echo ========================================
echo COPY THE TOKEN ABOVE!
echo.
echo Now go to CodeMagic and add it:
echo 1. Go to: https://codemagic.io/apps
echo 2. Click TCC project
echo 3. Click Environment variables
echo 4. Add new variable:
echo    Name: FIREBASE_TOKEN
echo    Value: [paste token here]
echo    Check "Secure" box
echo ========================================
pause