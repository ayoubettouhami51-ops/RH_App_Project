#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════╗
║  RH Pro Report — Build APK via Google Colab                  ║
║                                                              ║
║  INSTRUCTIONS :                                              ║
║  1. Ouvrir Google Colab : https://colab.research.google.com  ║
║  2. Nouveau notebook (Python 3)                              ║
║  3. Copier-coller les cellules ci-dessous dans Colab         ║
║  4. Exécuter chaque cellule dans l'ordre                     ║
║  5. L'APK sera téléchargé automatiquement à la fin           ║
╚══════════════════════════════════════════════════════════════╝

--- CELLULE 1 : Upload du projet ---
Coller dans une cellule Colab :

```python
# ── Cellule 1 : Uploader le projet ──
import os
from google.colab import files

# Créer le dossier projet
os.makedirs('/content/RH_App_Project', exist_ok=True)
os.chdir('/content/RH_App_Project')

# Uploader tous les fichiers du projet
print("📁 Sélectionnez TOUS les fichiers du projet :")
print("   - main.py")
print("   - buildozer.spec")
print("   - ocp_logo.png")
print("   - requirements.txt")
print()
uploaded = files.upload()
print(f"\\n✅ {len(uploaded)} fichiers uploadés avec succès !")
for name in uploaded:
    print(f"   📄 {name}")
```

--- CELLULE 2 : Installer les dépendances ---

```python
# ── Cellule 2 : Installer les outils de build ──
%%time
!sudo apt-get update -qq
!sudo apt-get install -y -qq \
    build-essential git ffmpeg \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    libportmidi-dev libswscale-dev libavformat-dev libavcodec-dev \
    zlib1g-dev libgstreamer1.0-dev gstreamer1.0-plugins-base \
    libffi-dev libssl-dev autoconf automake libtool pkg-config \
    cmake unzip openjdk-17-jdk > /dev/null 2>&1

!pip install --upgrade pip setuptools wheel cython==3.0.10 buildozer > /dev/null 2>&1

print("\\n✅ Tous les outils de build sont installés !")
print("   - Buildozer :", end=" ")
!buildozer version
```

--- CELLULE 3 : Builder l'APK ---

```python
# ── Cellule 3 : Construire l'APK ──
%%time
import os
os.chdir('/content/RH_App_Project')

print("🔨 Construction de l'APK en cours...")
print("⏳ Première exécution : ~15-25 minutes (téléchargement Android SDK/NDK)")
print("   Exécutions suivantes : ~5-10 minutes")
print("=" * 60)

!yes | buildozer -v android debug 2>&1 | tail -100

print("\\n" + "=" * 60)
# Vérifier si l'APK a été créé
import glob
apks = glob.glob('/content/RH_App_Project/bin/*.apk')
if apks:
    print(f"\\n✅ APK créé avec succès !")
    for apk in apks:
        size_mb = os.path.getsize(apk) / (1024 * 1024)
        print(f"   📦 {os.path.basename(apk)} ({size_mb:.1f} MB)")
else:
    print("\\n❌ Erreur : APK non trouvé. Consultez les logs ci-dessus.")
```

--- CELLULE 4 : Télécharger l'APK ---

```python
# ── Cellule 4 : Télécharger l'APK ──
import glob, os
from google.colab import files

apks = glob.glob('/content/RH_App_Project/bin/*.apk')
if apks:
    for apk in apks:
        print(f"📥 Téléchargement de {os.path.basename(apk)}...")
        files.download(apk)
    print("\\n✅ APK téléchargé ! Transférez-le sur votre téléphone Android pour l'installer.")
    print("\\n💡 Astuce : Activez 'Sources inconnues' dans les paramètres Android")
    print("   Paramètres → Sécurité → Sources inconnues → Activer")
else:
    print("❌ Aucun APK trouvé. Relancez la Cellule 3.")
```
"""

if __name__ == "__main__":
    print(__doc__)
