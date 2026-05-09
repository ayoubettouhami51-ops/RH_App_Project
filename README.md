# RH Pro Report — Version finale renforcée

Application KivyMD pour convertir un PDF RH en deux rapports Excel :

1. **Prime de Performance**
2. **Heures Supplémentaires**

La version incluse ici a été durcie pour un usage plus fiable : validations, journal d'erreurs, interface plus propre, meilleure gestion Android/PC et test moteur sans interface.

---

## Contenu du projet

```text
RH_App_Project/
├── main.py              # App KivyMD + moteur PDF/Excel renforcé
├── smoke_test.py        # Test rapide sans interface Kivy
├── requirements.txt     # Dépendances pour lancer sur PC
├── buildozer.spec       # Configuration Android
├── run_desktop.sh       # Lancement PC/Linux
├── build_apk.sh         # Build APK debug
├── ocp_logo.png         # Logo utilisé dans l'app et Excel
└── README.md
```

---

## Améliorations incluses

- Interface plus propre sous forme de cartes : en-tête, périodes, PDF, statut.
- Moteur `DataEngine` testable même sans Kivy installé.
- Validation stricte des dates S01 → S05.
- Détection plus tolérante du début des 31 colonnes journalières.
- Gestion des semaines qui chevauchent deux mois : seul le mois du rapport est compté.
- Lecture améliorée des heures : `10,5`, `10:30`, `10h30`.
- Déduplication des lignes extraites deux fois par pdfplumber.
- Journal `errors_log.txt` dans le dossier de sortie si certaines lignes sont ignorées.
- Chemin de sortie robuste : `Downloads/RH_Reports` quand possible, sinon dossier app/utilisateur.
- Gestion Android `content://` ajoutée pour les fichiers sélectionnés par certains gestionnaires Android.
- Excel amélioré : filtres, gel des en-têtes, lignes alternées, alertes heures sup.

---

## Lancer sur PC

```bash
cd RH_App_Project
python -m pip install -r requirements.txt
python main.py
```

Sur un environnement sans Kivy/KivyMD, l'interface ne se lance pas, mais le moteur reste testable :

```bash
python smoke_test.py
```

Le test génère deux fichiers Excel factices et vérifie qu'ils s'ouvrent correctement.

---

## Générer APK Android

Environnement conseillé : Ubuntu/WSL2 + Python 3.11 + JDK 17.

```bash
cd RH_App_Project
python -m pip install --upgrade pip setuptools wheel cython buildozer
buildozer -v android debug
```

Ou :

```bash
./build_apk.sh
```

APK généré :

```text
bin/*.apk
```

---

## Utilisation de l'application

1. Entrez les périodes S01 à S05 au format `AAAA-MM-JJ`.
2. Sélectionnez le PDF RH.
3. Appuyez sur **Générer les 2 fichiers Excel**.
4. Les fichiers seront enregistrés dans `RH_Reports`.

S01 est obligatoire. S02 → S05 peuvent rester vides si le mois n'en a pas besoin.

---

## Codes reconnus

| Type | Codes / formats | Comptage |
|---|---|---|
| Absence/repos | RM, RC, PEAS, CA, RHJ, IRR, JF, ABS, MAL | 0 |
| Présence | MIS, RPJ, FC, RP, P, PR, TR, AP | 1 |
| Horaire | 08:00, 8h00, 7,5 | 1 si > 0 |

---

## Limite connue

Le moteur fonctionne au mieux avec les PDF texte/tableaux. Si le PDF est une image scannée, il faudra d'abord le convertir avec OCR avant traitement.
