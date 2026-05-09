# -*- coding: utf-8 -*-
"""Test rapide du moteur Excel sans lancer l'interface Kivy."""

from datetime import date
from pathlib import Path

import openpyxl

from main import DataEngine


def main() -> None:
    engine = DataEngine()
    periods = {
        "s01_start": date(2026, 1, 1), "s01_end": date(2026, 1, 7),
        "s02_start": date(2026, 1, 8), "s02_end": date(2026, 1, 14),
        "s03_start": date(2026, 1, 15), "s03_end": date(2026, 1, 21),
        "s04_start": date(2026, 1, 22), "s04_end": date(2026, 1, 28),
        "s05_start": date(2026, 1, 29), "s05_end": date(2026, 1, 31),
    }
    engine.validate_periods(periods)
    engine.report_month = engine.infer_report_month(periods)

    employees = []
    # Ligne simulée : matricule, code, nom, poste, 31 jours, V04,V05,V06,V07
    base_days = ["08:00"] * 26 + ["RM", "RC", "08:00", "08:00", "08:00"]
    for idx, total in enumerate([12.5, 66.0, 105.0], start=1):
        row = [f"100{idx}", f"C{idx}", f"Agent Test {idx}", "AP1" if idx == 1 else "OP"]
        row += base_days
        row += ["160", total / 3, total / 3, total / 3]
        parsed = engine.parse_row(row, periods)
        assert parsed is not None
        employees.append(parsed.as_dict())

    f1 = engine.generate_excel_performance(employees, periods)
    f2 = engine.generate_excel_heures_supp(employees)

    for file_path in [f1, f2]:
        path = Path(file_path)
        assert path.exists(), file_path
        wb = openpyxl.load_workbook(path, data_only=False)
        assert wb.sheetnames, file_path
        print(f"OK: {path}")


if __name__ == "__main__":
    main()
