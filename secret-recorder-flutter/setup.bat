@echo off
echo ========================================
echo   Secret Recorder Flutter
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter not found!
    echo Please install Flutter from: https://docs.flutter.dev/get-started/install
    echo.
    pause
    exit /b 1
)

echo.
echo Getting dependencies...
flutter pub get

echo.
echo ========================================
echo   Build Commands:
echo ========================================
echo.
echo   Run on device:     flutter run
echo   Build APK:         flutter build apk --release
echo   Build App Bundle:  flutter build appbundle --release
echo.
echo   APK Location: build\app\outputs\flutter-apk\app-release.apk
echo.

pause
