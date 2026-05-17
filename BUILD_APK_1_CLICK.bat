@echo off
color 0B
echo ===================================================================
echo               OCP RH App - Compilation Automatique de l'APK
echo ===================================================================
echo.

cd /d "%~dp0"

echo [1/4] Nettoyage complet du cache de construction...
call flutter clean
echo.

echo [2/4] Installation des packages et dependances...
call flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo [3/4] Generation de l'icone et de l'ecran de demarrage...
call dart run flutter_launcher_icons 2>nul
call dart run flutter_native_splash:create 2>nul

echo.
echo [4/4] Construction du fichier APK (Cela peut prendre 3 a 7 minutes)...
call flutter build apk --release
if %errorlevel% neq 0 goto :error

echo.
echo ===================================================================
echo   SUCCES TOTAL ! Votre application APK est prete a etre installee !
echo ===================================================================
echo.
echo Ouverture automatique du dossier contenant votre APK...
explorer "build\app\outputs\flutter-apk"
pause
exit

:error
color 0C
echo.
echo ===================================================================
echo   ERREUR: La compilation a echoue. Veuillez verifier les messages.
echo ===================================================================
pause
exit
