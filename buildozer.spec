[app]

# Application
# Buildozer utilise ce fichier pour créer le package Android.
title = RH OCP
package.name = rhocp
package.domain = com.mycompany
version = 2.1.0

# Sources
source.dir = .
source.include_exts = py,png,jpg,jpeg,kv,atlas,json,txt,md
source.exclude_dirs = tests,.git,__pycache__,.pytest_cache,.github

# Python / Kivy
# Note : cryptography retiré (problèmes de compilation native sur Android).
# et_xmlfile ajouté (dépendance obligatoire d'openpyxl).
# chardet/charset-normalizer ajoutés (dépendances de pdfminer.six).
requirements = python3,kivy==2.3.0,kivymd==1.2.0,pdfplumber,pdfminer.six,openpyxl,et_xmlfile,Pillow,plyer,chardet,charset-normalizer

# UI
orientation = portrait
fullscreen = 0

# Assets
icon.filename = %(source.dir)s/icon.png
presplash.filename = %(source.dir)s/presplash.png

# Android
android.api = 33
android.minapi = 23
android.ndk = 25.1.8937393
android.ndk_api = 23
android.archs = arm64-v8a
android.accept_sdk_license = True
android.allow_backup = True

# Permissions : nécessaires pour choisir/lire un PDF et écrire les rapports.
# Sur Android récent, le sélecteur peut renvoyer une URI content:// traitée par main.py.
android.permissions = android.permission.READ_EXTERNAL_STORAGE,android.permission.WRITE_EXTERNAL_STORAGE,android.permission.MANAGE_EXTERNAL_STORAGE

# Artifacts
android.debug_artifact = apk

[buildozer]
log_level = 2
warn_on_root = 1
