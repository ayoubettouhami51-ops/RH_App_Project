import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'employee_model.dart';

class HRProcessor {
  static const Set<String> presenceCodes = {"MIS", "FC", "RPJ", "VS"};
  static const Set<String> exclusionCodes = {"RM", "RC", "PEAS", "CA", "CA-1", "CP"};

  final Map<String, List<DateTime>> weeks = {
    "S01": [DateTime(2026, 3, 30), DateTime(2026, 4, 5)],
    "S02": [DateTime(2026, 4, 6), DateTime(2026, 4, 12)],
    "S03": [DateTime(2026, 4, 13), DateTime(2026, 4, 19)],
    "S04": [DateTime(2026, 4, 20), DateTime(2026, 4, 26)],
    "S05": [DateTime(2026, 4, 27), DateTime(2026, 5, 3)],
  };

  Future<List<Employee>> processPdf(String filePath) async {
    List<Employee> employees = [];
    final File file = File(filePath);
    final List<int> bytes = await file.readAsBytes();
    
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);

    for (int i = 0; i < document.pages.count; i++) {
      final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
      
      final RegExp nameRegExp = RegExp(r"-\s*([^|]+?)\s+Matricule:\s*(\d+)");
      final Match? nameMatch = nameRegExp.firstMatch(pageText);
      
      if (nameMatch == null) continue;
      
      String name = nameMatch.group(1)!.trim();
      String matricule = nameMatch.group(2)!.trim();
      
      Map<DateTime, int> attendance = {};
      Map<String, double> hours = {"V04": 0, "V05": 0, "V06": 0, "V07": 0};

      final List<String> lines = pageText.split('\n');
      
      for (final String line in lines) {
        final RegExp dateRegExp = RegExp(r"^(LUN|MAR|MER|JEU|VEN|SAM|DIM)\s+(\d{2}/\d{2}/\d{4})");
        final Match? dateMatch = dateRegExp.firstMatch(line);
        
        if (dateMatch != null) {
          final String dateStr = dateMatch.group(2)!;
          final DateTime currentDate = DateFormat("dd/MM/yyyy").parse(dateStr);
          final String restOfLine = line.substring(dateMatch.end).trim();
          
          int isPresent = 0;
          if (presenceCodes.any((code) => restOfLine.contains(code))) {
            isPresent = 1;
          } else if (exclusionCodes.any((code) => restOfLine.contains(code))) {
            isPresent = 0;
          } else if (RegExp(r"\d{1,2}:\d{2}").allMatches(restOfLine).length >= 2) {
            isPresent = 1;
          }
          
          attendance[currentDate] = isPresent;
          
          // استخراج الساعات
          final RegExp hoursRegExp = RegExp(r"(\d+:\d+|\d+\.\d+|\d+)");
          final List<String> matches = hoursRegExp.allMatches(restOfLine).map((m) => m.group(0)!).toList();
          
          if (matches.length >= 4) {
            hours["V04"] = _parseHours(matches[matches.length - 4]);
            hours["V05"] = _parseHours(matches[matches.length - 3]);
            hours["V06"] = _parseHours(matches[matches.length - 2]);
            hours["V07"] = _parseHours(matches[matches.length - 1]);
          }
        }
      }

      Map<String, int> weekCounts = {};
      weeks.forEach((week, range) {
        weekCounts[week] = _sumPeriod(attendance, range[0], range[1]);
      });

      int pp = weekCounts.values.reduce((a, b) => a + b);
      int pf = _sumPeriod(attendance, DateTime(2026, 4, 1), DateTime(2026, 4, 30));

      employees.add(Employee(
        matricule: matricule,
        name: name,
        weekData: weekCounts,
        pp: pp,
        pf: pf,
        hours: hours,
        totalSupp: hours["V05"]! + hours["V06"]! + hours["V07"]!,
        remarque: attendance.isEmpty ? "Données illisibles" : "",
      ));
    }

    document.dispose();
    employees.sort((a, b) => b.totalSupp.compareTo(a.totalSupp));
    return employees;
  }

  double _parseHours(String val) {
    if (val.contains(':')) {
      final parts = val.split(':');
      return double.parse(parts[0]) + (double.parse(parts[1]) / 60.0);
    }
    return double.tryParse(val) ?? 0.0;
  }

  int _sumPeriod(Map<DateTime, int> attendance, DateTime start, DateTime end) {
    int sum = 0;
    attendance.forEach((date, value) {
      if (date.isAfter(start.subtract(const Duration(days: 1))) && 
          date.isBefore(end.add(const Duration(days: 1)))) {
        sum += value;
      }
    });
    return sum;
  }
}
