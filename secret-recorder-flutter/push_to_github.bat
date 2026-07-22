@echo off
echo ========================================
echo   Secret Recorder - GitHub Push Helper
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git not found!
    echo Please install Git from: https://git-scm.com
    pause
    exit /b 1
)

echo Step 1: Initialize Git repository...
cd /d "%~dp0"
git init

echo.
echo Step 2: Add all files...
git add .

echo.
echo Step 3: Create first commit...
git commit -m "Initial commit: Secret Recorder Flutter"

echo.
echo ========================================
echo   Next Steps:
echo ========================================
echo.
echo   1. Create a new repository on GitHub
echo      https://github.com/new
echo.
echo   2. Copy the repository URL
echo.
echo   3. Run these commands:
echo      git remote add origin YOUR_REPO_URL
echo      git push -u origin main
echo.
echo   4. The APK will be built automatically!
echo      Check: Actions tab in your repository
echo.
echo   5. Download APK from:
echo      Releases tab in your repository
echo.

pause
