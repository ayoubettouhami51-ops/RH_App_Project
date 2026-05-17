import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/employee_model.dart';
import 'models/processing_mode.dart';

class ExcelGenerator {
  Future<String> generateReports(List<Employee> employees, ProcessingMode mode, String period) async {
    final Excel excel = Excel.createExcel();
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }
    
    final CellStyle headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#0B3D5C'), // Dark Blue OCP
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    
    final CellStyle dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final CellStyle nameStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    // --- Path 1: Prime de Performance ---
    if (mode == ProcessingMode.performance) {
      final Sheet sheetPerf = excel['Prime de Performance'];
      final List<String> headersPerf = [
        "Matricule", "Code", "Nom / Prénom", "Type de poste", "Rapidité", 
        "Qualité", "Initiative", "S01", "S02", "S03", "S04", "S05", 
        "Nbre des jrs P.P", "Nbre des jrs P.F", "Note H"
      ];
      for (int col = 0; col < headersPerf.length; col++) {
        final cell = sheetPerf.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headersPerf[col]);
        cell.cellStyle = headerStyle;
      }
      for (int i = 0; i < employees.length; i++) {
        final emp = employees[i];
        final List<dynamic> rowData = [
          emp.matricule, "", emp.name, "", "", "", "", 
          emp.perfWeeks["S01"] ?? 0,
          emp.perfWeeks["S02"] ?? 0,
          emp.perfWeeks["S03"] ?? 0,
          emp.perfWeeks["S04"] ?? 0,
          emp.perfWeeks["S05"] ?? 0,
          emp.perfPP,
          emp.perfPF,
          emp.remarque
        ];
        for (int col = 0; col < rowData.length; col++) {
          final cell = sheetPerf.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
          _setCellValue(cell, rowData[col], col == 2 ? nameStyle : dataStyle);
        }
      }
    }
    
    // --- Path 2: Heures Supplémentaires ---
    if (mode == ProcessingMode.overtime) {
      final Sheet sheetHours = excel['Heures Supplémentaires'];
      final List<String> headersHours = [
        "Matricule", "Nom de l'Agent", "Période", "V04 (H. Normales)", 
        "V05 (H. Supp 25%)", "V06 (H. Supp 50%)", "V07 (H. Supp 100%)", 
        "Total Heures Supplémentaires (V05+V06+V07)", "Remarque"
      ];
      for (int col = 0; col < headersHours.length; col++) {
        final cell = sheetHours.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headersHours[col]);
        cell.cellStyle = headerStyle;
      }
      
      List<Employee> sortedBySupp = List.from(employees);
      sortedBySupp.sort((a, b) => b.totalSupp.compareTo(a.totalSupp));
      
      for (int i = 0; i < sortedBySupp.length; i++) {
        final emp = sortedBySupp[i];
        final List<dynamic> rowData = [
          emp.matricule,
          emp.name,
          period,
          emp.hours["V04"] ?? 0.0,
          emp.hours["V05"] ?? 0.0,
          emp.hours["V06"] ?? 0.0,
          emp.hours["V07"] ?? 0.0,
          emp.totalSupp,
          emp.remarque,
        ];
        for (int col = 0; col < rowData.length; col++) {
          final cell = sheetHours.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
          _setCellValue(cell, rowData[col], col == 1 ? nameStyle : dataStyle);
          if (col == 7) { 
            cell.cellStyle = CellStyle(
              backgroundColorHex: ExcelColor.fromHexString('#FFFDE7'),
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center,
            );
          }
        }
      }
    }
    
    // --- Path 3: Prime Automobile ---
    if (mode == ProcessingMode.automobile) {
      final Sheet sheetAuto = excel['Prime Automobile'];
      final List<String> headersAuto = [
        "Nom & Prénom", "Matricule", "S01", "S02", "S03", "S04", "S05", "PP"
      ];
      for (int col = 0; col < headersAuto.length; col++) {
        final cell = sheetAuto.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.value = TextCellValue(headersAuto[col]);
        cell.cellStyle = headerStyle;
      }
      
      for (int i = 0; i < employees.length; i++) {
        final emp = employees[i];
        final List<dynamic> rowData = [
          emp.name,
          emp.matricule,
          emp.autoWeeks["S01"] ?? 0,
          emp.autoWeeks["S02"] ?? 0,
          emp.autoWeeks["S03"] ?? 0,
          emp.autoWeeks["S04"] ?? 0,
          emp.autoWeeks["S05"] ?? 0,
          emp.autoPP,
        ];
        for (int col = 0; col < rowData.length; col++) {
          final cell = sheetAuto.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
          _setCellValue(cell, rowData[col], col == 0 ? nameStyle : dataStyle);
        }
      }
    }
    
    Directory? outputDir;
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) await Permission.storage.request();
      var manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) await Permission.manageExternalStorage.request();
      
      outputDir = Directory('/storage/emulated/0/Download');
      if (!await outputDir.exists()) {
        outputDir = await getExternalStorageDirectory();
      }
    } else {
      outputDir = await getDownloadsDirectory();
    }
    
    final String outputPath = '${outputDir!.path}/Rapport_RH_OCP_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    
    final List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      final File file = File(outputPath);
      await file.writeAsBytes(fileBytes);
    }
    
    return outputPath;
  }
  
  void _setCellValue(Data cell, dynamic val, CellStyle style) {
    if (val is int) {
      cell.value = IntCellValue(val);
    } else if (val is double) {
      cell.value = DoubleCellValue(val);
    } else {
      cell.value = TextCellValue(val.toString());
    }
    cell.cellStyle = style;
  }
}
