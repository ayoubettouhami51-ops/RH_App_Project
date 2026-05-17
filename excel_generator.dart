import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/employee_model.dart';

class ExcelGenerator {
  Future<String> generateReports(List<Employee> employees) async {
    final Excel excel = Excel.createExcel();
    
    // --- 1. التقرير الأول: منحة الأداء (Prime de Performance) ---
    final Sheet sheetPerf = excel['Prime de Performance'];
    excel.delete('Sheet1'); // حذف الصفحة الافتراضية
    
    // الأنماط (Styles)
    final CellStyle headerStyle = CellStyle(
      bold: true,
      fontColorHex: 'FFFFFF',
      backgroundColorHex: '0B3D5C', // أزرق داكن (نمط OCP)
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
    
    // إضافة العناوين
    final List<String> headersPerf = ["Matricule", "Nom & Prénom", "S01", "S02", "S03", "S04", "S05", "PP", "PF", "Remarque"];
    for (int col = 0; col < headersPerf.length; col++) {
      final cell = sheetPerf.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = headersPerf[col];
      cell.cellStyle = headerStyle;
    }
    
    // إضافة البيانات
    for (int i = 0; i < employees.length; i++) {
      final emp = employees[i];
      final List<dynamic> rowData = [
        emp.matricule,
        emp.name,
        emp.weekData["S01"] ?? 0,
        emp.weekData["S02"] ?? 0,
        emp.weekData["S03"] ?? 0,
        emp.weekData["S04"] ?? 0,
        emp.weekData["S05"] ?? 0,
        emp.pp,
        emp.pf,
        emp.remarque,
      ];
      
      for (int col = 0; col < rowData.length; col++) {
        final cell = sheetPerf.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
        cell.value = rowData[col];
        cell.cellStyle = (col == 1) ? nameStyle : dataStyle;
      }
    }
    
    // --- 2. التقرير الثاني: الساعات الإضافية (Heures Supplémentaires) ---
    final Sheet sheetHours = excel['Heures Supplémentaires'];
    
    final List<String> headersHours = ["Matricule", "Nom et prénom de l'Agent", "V04", "V05", "V06", "V07", "Total Heures Supplémentaires", "Remarque"];
    for (int col = 0; col < headersHours.length; col++) {
      final cell = sheetHours.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = headersHours[col];
      cell.cellStyle = headerStyle;
    }
    
    // إضافة البيانات (مرتبة مسبقاً في الـ Processor)
    for (int i = 0; i < employees.length; i++) {
      final emp = employees[i];
      final List<dynamic> rowData = [
        emp.matricule,
        emp.name,
        emp.hours["V04"] ?? 0.0,
        emp.hours["V05"] ?? 0.0,
        emp.hours["V06"] ?? 0.0,
        emp.hours["V07"] ?? 0.0,
        emp.totalSupp,
        emp.remarque,
      ];
      
      for (int col = 0; col < rowData.length; col++) {
        final cell = sheetHours.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i + 1));
        cell.value = rowData[col];
        cell.cellStyle = (col == 1) ? nameStyle : dataStyle;
        
        // تمييز الساعات الإجمالية بلون ذهبي خفيف
        if (col == 6) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: 'FFFDE7',
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
          );
        }
      }
    }
    
    // حفظ الملف في مجلد التنزيلات (Downloads)
    Directory? outputDir;
    if (Platform.isAndroid) {
      outputDir = Directory('/storage/emulated/0/Download');
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
}
