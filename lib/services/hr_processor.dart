import 'dart:io';
import 'dart:math';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../models/employee_model.dart';
import '../models/processing_mode.dart';

class HRProcessor {
  // Path 1: Prime de Performance
  // Présence (=1): HH:MM timestamp, MIS (Mission), RPJ (Repos Journée), FC (Formation), VS (Visite Systématique)
  static const Set<String> perfPresence = {"MIS", "RPJ", "FC", "VS"};
  // Exclusion (=0): RM, RC, PEAS, PEA, CA, CA-1, CP
  static const Set<String> perfExclusion = {"RM", "RC", "PEAS", "PEA", "CA", "CA-1", "CP"};

  // Path 3: Prime Automobile
  static const Set<String> autoExclusion = {"MIS", "FC", "RM", "RC", "PEAS", "PEA", "CA", "CA-1", "CP"};

  Future<List<Employee>> processPdf(String filePath, Map<String, List<DateTime>> weeks, ProcessingMode mode) async {
    List<Employee> employees = [];
    final File file = File(filePath);
    final List<int> bytes = await file.readAsBytes();
    
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);

    for (int i = 0; i < document.pages.count; i++) {
      String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
      
      // Skip pages with no extractable text
      if (pageText.trim().isEmpty) {
        continue;
      }
      
      String rawName = "Inconnu";
      String matricule = "";
      
      // Look for Matricule: 123456
      final RegExp matRegExp = RegExp(r"Matricule[\s:]*(\d{4,8})", caseSensitive: false);
      final Match? matMatch = matRegExp.firstMatch(pageText);
      
      if (matMatch != null) {
        matricule = matMatch.group(1)!.trim();
      } else {
        // Fallback: look for just a 4 to 8 digit number
        final RegExp fallbackMat = RegExp(r"\b(\d{4,8})\b");
        final matches = fallbackMat.allMatches(pageText);
        if (matches.isNotEmpty) {
          matricule = matches.first.group(1)!;
        } else {
          matricule = "XXXXXX";
        }
      }
      
      // Look for Name
      // We look for anything between "Agent" and "Matricule" OR between "Nom" and the next known word
      final RegExp nameRegExp = RegExp(r"Agent[\s:]*([A-Za-zÀ-ÿ\s]+?)(?:Matric|[\d]{4})", caseSensitive: false);
      final Match? nameMatch = nameRegExp.firstMatch(pageText);
      
      if (nameMatch != null && nameMatch.group(1)!.trim().length > 2) {
        rawName = nameMatch.group(1)!.trim();
      } else {
        // Fallback: Look for text right after Nom or - 
        final RegExp altName = RegExp(r"(?:Nom|[-])\s*([A-Za-zÀ-ÿ\s]{4,30})\s*(?:Matric|[\d]{4})", caseSensitive: false);
        final Match? altMatch = altName.firstMatch(pageText);
        if (altMatch != null) {
          rawName = altMatch.group(1)!.trim();
        }
      }
      
      // Clean up name
      rawName = rawName.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (rawName.isEmpty || rawName.toLowerCase() == "de l") rawName = "Inconnu";
      
      Map<DateTime, int> perfAttendance = {};
      Map<DateTime, int> autoAttendance = {};
      Map<String, double> hours = {"V04": 0.0, "V05": 0.0, "V06": 0.0, "V07": 0.0};
      List<String> warnings = [];

      final RegExp dateRegExp = RegExp(r"(LUN|MAR|MER|JEU|VEN|SAM|DIM)\s*(\d{2}/\d{2}/\d{4})", caseSensitive: false);
      final List<Match> dateMatches = dateRegExp.allMatches(pageText).toList();
      
      for (int m = 0; m < dateMatches.length; m++) {
        final Match currentMatch = dateMatches[m];
        final String dateStr = currentMatch.group(2)!;
        final DateTime currentDate = DateFormat("dd/MM/yyyy").parse(dateStr);
        
        int endIndex = m + 1 < dateMatches.length ? dateMatches[m+1].start : pageText.length;
        // Limit to next 300 characters just in case there are no more dates and it grabs the whole footer
        if (endIndex - currentMatch.end > 300) {
          endIndex = currentMatch.end + 300;
        }
        
        final String dayData = pageText.substring(currentMatch.end, endIndex).trim().toUpperCase();
        
        bool hasTimestamp = RegExp(r"\d{1,2}:\d{2}").hasMatch(dayData);

        // --- 1. Prime de Performance Logic ---
        int perfPresent = 0;
        if (perfExclusion.any((code) => dayData.contains(code))) {
           perfPresent = 0;
        } else if (perfPresence.any((code) => dayData.contains(code)) || hasTimestamp) {
           perfPresent = 1;
        }
        perfAttendance[currentDate] = perfPresent;

        // --- 2. Prime Automobile Logic ---
        int autoPresent = 0;
        if (autoExclusion.any((code) => dayData.contains(code))) {
           autoPresent = 0;
        } else if (hasTimestamp) {
           autoPresent = 1;
        }
        autoAttendance[currentDate] = autoPresent;
        
        // --- 3. Heures Supplémentaires Logic ---
        // ONLY calculate hours if the current date is strictly within the selected weeks period bounds
        DateTime overallStart = weeks["S01"]![0];
        DateTime overallEnd = weeks["S05"]![1];
        
        // Ensure overallStart is at midnight
        overallStart = DateTime(overallStart.year, overallStart.month, overallStart.day);
        // Ensure overallEnd is at 23:59:59
        overallEnd = DateTime(overallEnd.year, overallEnd.month, overallEnd.day, 23, 59, 59);

        if (!currentDate.isBefore(overallStart) && !currentDate.isAfter(overallEnd)) {
          final RegExp hoursRegExp = RegExp(r"(\d+:\d+|\d+\.\d+)");
          final List<String> matches = hoursRegExp.allMatches(dayData).map((m) => m.group(0)!).toList();
          
          if (matches.length >= 4) {
            hours["V04"] = (hours["V04"] ?? 0) + _parseHours(matches[matches.length - 4]);
            hours["V05"] = (hours["V05"] ?? 0) + _parseHours(matches[matches.length - 3]);
            hours["V06"] = (hours["V06"] ?? 0) + _parseHours(matches[matches.length - 2]);
            hours["V07"] = (hours["V07"] ?? 0) + _parseHours(matches[matches.length - 1]);
          }
        }
      }

      // Global Search for V04, V05, V06, V07 Totals on the Page
      // Many PDFs have a summary section like "V04: 15:30" or "V04 15.5"
      final List<String> vKeys = ["V04", "V05", "V06", "V07", "V4", "V5", "V6", "V7"];
      for (String vKey in vKeys) {
        final RegExp globalVRegExp = RegExp(vKey + r"[\s:=]+(\d+[:.]\d+|\d+)", caseSensitive: false);
        final Iterable<Match> globalMatches = globalVRegExp.allMatches(pageText);
        if (globalMatches.isNotEmpty) {
          // Use the last match found on the page (usually the grand total)
          String normalizedKey = vKey.length == 2 ? "V0" + vKey[1] : vKey;
          double parsedGlobal = _parseHours(globalMatches.last.group(1)!);
          // If the global total is greater than what we parsed line-by-line, use it
          if (parsedGlobal > (hours[normalizedKey] ?? 0)) {
             hours[normalizedKey] = parsedGlobal;
          }
        }
      }

      if (perfAttendance.isEmpty && autoAttendance.isEmpty) {
        warnings.add("Données introuvables / illisibles dans le PDF");
      }

      // Aggregate Performance
      Map<String, int> perfWeeksCount = {};
      weeks.forEach((week, range) {
        perfWeeksCount[week] = _sumPeriod(perfAttendance, range[0], range[1]);
      });
      int perfPP = perfWeeksCount.values.fold(0, (a, b) => a + b);
      // Calculate PF for the exact month (using the middle week S03 as reference for the target month)
      DateTime midDate = weeks["S03"] != null ? weeks["S03"]![0] : DateTime.now();
      DateTime startOfMonth = DateTime(midDate.year, midDate.month, 1);
      DateTime endOfMonth = DateTime(midDate.year, midDate.month + 1, 0);
      int perfPF = _sumPeriod(perfAttendance, startOfMonth, endOfMonth);

      // Aggregate Auto
      Map<String, int> autoWeeksCount = {};
      weeks.forEach((week, range) {
        DateTime sDate = range[0];
        DateTime eDate = range[1];
        if (sDate.isBefore(startOfMonth)) sDate = startOfMonth;
        if (eDate.isAfter(endOfMonth)) eDate = endOfMonth;
        autoWeeksCount[week] = _sumPeriod(autoAttendance, sDate, eDate);
      });
      int autoPP = autoWeeksCount.values.fold(0, (a, b) => a + b);

      double totalSupp = (hours["V05"] ?? 0) + (hours["V06"] ?? 0) + (hours["V07"] ?? 0);

      int existingIdx = -1;
      if (matricule != "XXXXXX" && rawName != "Inconnu") {
        existingIdx = employees.indexWhere((e) => e.matricule == matricule || _similarity(e.name, rawName) > 0.85);
      }
      
      if (existingIdx != -1) {
         // Merge data or skip. Usually it's handled properly if pages are distinct.
      } else {
        employees.add(Employee(
          matricule: matricule,
          name: rawName,
          perfWeeks: perfWeeksCount,
          perfPP: perfPP,
          perfPF: perfPF,
          hours: hours,
          totalSupp: totalSupp,
          autoWeeks: autoWeeksCount,
          autoPP: autoPP,
          remarque: warnings.join(", "),
        ));
      }
    }

    document.dispose();
    
    if (employees.isEmpty) {
      employees.add(Employee(
        matricule: "ERREUR",
        name: "PDF Illisible",
        perfWeeks: {},
        perfPP: 0,
        perfPF: 0,
        hours: {"V04": 0.0, "V05": 0.0, "V06": 0.0, "V07": 0.0},
        totalSupp: 0.0,
        autoWeeks: {},
        autoPP: 0,
        remarque: "Le PDF est vide ou sous forme d'image (scanné). Aucune donnée texte n'a pu être extraite.",
      ));
    }
    
    // Ensure sorting is applied globally (UI and Excel)
    if (mode == ProcessingMode.overtime) {
      employees.sort((a, b) => b.totalSupp.compareTo(a.totalSupp));
    } else if (mode == ProcessingMode.performance) {
      employees.sort((a, b) => b.perfPP.compareTo(a.perfPP));
    } else if (mode == ProcessingMode.automobile) {
      employees.sort((a, b) => b.autoPP.compareTo(a.autoPP));
    }

    return employees;
  }

  double _parseHours(String val) {
    if (val.contains(':')) {
      final parts = val.split(':');
      if (parts.length == 2) {
         double h = double.tryParse(parts[0]) ?? 0;
         double m = double.tryParse(parts[1]) ?? 0;
         return h + (m / 60.0);
      }
    }
    return double.tryParse(val) ?? 0.0;
  }

  int _sumPeriod(Map<DateTime, int> attendance, DateTime start, DateTime end) {
    int sum = 0;
    attendance.forEach((date, value) {
      if (date.compareTo(start.subtract(const Duration(days: 1))) > 0 && 
          date.compareTo(end.add(const Duration(days: 1))) < 0) {
        sum += value;
      }
    });
    return sum;
  }

  // Simple Levenshtein distance for fuzzy matching
  double _similarity(String s1, String s2) {
    s1 = s1.toLowerCase().trim();
    s2 = s2.toLowerCase().trim();
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);
    
    for (int i = 0; i <= s2.length; i++) v0[i] = i;
    
    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= s2.length; j++) v0[j] = v1[j];
    }
    int distance = v1[s2.length];
    return 1.0 - (distance / max(s1.length, s2.length));
  }
}
