[app]

# Application
# Buildozer utilise ce fichier pour créer le package Android.
title = RH Pro Report
package.name = rhproreport
package.domain = org.ocp
version = 1.1.0

# Sources
source.dir = .
source.include_exts = py,png,jpg,jpeg,kv,atlas,json,txt,md
source.exclude_dirs = tests,.git,__pycache__,.pytest_cache

# Python / Kivy
requirements = python3==3.11.5,hostpython3==3.11.5,kivy==2.3.0,kivymd==1.2.0,pdfplumber,pdfminer.six,openpyxl,Pillow,plyer,pyjnius

# UI
orientation = portrait
fullscreen = 0

# Assets
# Décommentez si vous ajoutez vos propres icônes.
# icon.filename = %(source.dir)s/icon.png
# presplash.filename = %(source.dir)s/presplash.png

# Android
android.api = 33
android.minapi = 23
android.ndk = 25b
android.ndk_api = 23
android.archs = arm64-v8a, armeabi-v7a
android.accept_sdk_license = True
android.allow_backup = True

# Permissions : nécessaires pour choisir/lire un PDF et écrire les rapports.
# Sur Android récent, le sélecteur peut renvoyer une URI content:// traitée par main.py.
android.permissions = android.permission.READ_EXTERNAL_STORAGE,android.permission.WRITE_EXTERNAL_STORAGE,android.permission.MANAGE_EXTERNAL_STORAGE

# Artifacts
android.release_artifact = aab
android.debug_artifact = apk

[buildozer]
log_level = 2
warn_on_root = 1
