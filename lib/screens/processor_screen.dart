import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme.dart';
import '../models/employee_model.dart';
import '../models/processing_mode.dart';
import '../services/hr_processor.dart';
import '../excel_generator.dart';
import 'results_screen.dart';

class ProcessorScreen extends StatefulWidget {
  final ProcessingMode mode;
  const ProcessorScreen({super.key, required this.mode});

  @override
  State<ProcessorScreen> createState() => _ProcessorScreenState();
}

class _ProcessorScreenState extends State<ProcessorScreen> {
  String _step = "import"; // import, config, processing
  String? _filePath;
  String _fileName = "";
  
  // Processing state
  double _progress = 0.0;
  List<String> _logs = [];
  
  final HRProcessor _processor = HRProcessor();
  final ExcelGenerator _generator = ExcelGenerator();

  late Map<String, List<DateTime>> _weeks;

  @override
  void initState() {
    super.initState();
    // Default to a 5-week period starting March 31, 2026
    _generateWeeks(DateTime(2026, 3, 30), DateTime(2026, 5, 3));
  }

  void _generateWeeks(DateTime start, DateTime end) {
    setState(() {
      _weeks = {};
      // Align start to the Monday of its week
      DateTime currentStart = DateTime(start.year, start.month, start.day);
      int daysToSubtract = currentStart.weekday - 1;
      currentStart = currentStart.subtract(Duration(days: daysToSubtract));
      
      for (int i = 1; i <= 5; i++) {
        DateTime currentEnd = currentStart.add(const Duration(days: 6));
        _weeks["S0${i}"] = [currentStart, currentEnd];
        currentStart = currentStart.add(const Duration(days: 7));
      }
    });
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _weeks["S01"]![0], end: _weeks["S05"]![1]),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: OcpTheme.accent,
              onPrimary: Colors.black,
              surface: OcpTheme.surface,
              onSurface: OcpTheme.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _generateWeeks(picked.start, picked.end);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
        _fileName = result.files.single.name;
        _step = "config";
      });
    }
  }

  void _addLog(String log) {
    setState(() => _logs.add(log));
  }

  Future<void> _process() async {
    if (_filePath == null) return;
    
    setState(() { _step = "processing"; _progress = 0.1; _logs = []; });
    _addLog("📄 Lecture du fichier source: $_fileName...");
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      _addLog("🔍 Extraction et scan des données de pointage...");
      setState(() => _progress = 0.3);
      await Future.delayed(const Duration(milliseconds: 500));
      
      _addLog("🧮 Application des algorithmes métiers...");
      setState(() => _progress = 0.5);
      
      final List<Employee> employees = await _processor.processPdf(_filePath!, _weeks, widget.mode);
      _addLog("👥 ${employees.length} collaborateurs identifiés et calculés !");
      
      setState(() => _progress = 0.7);
      _addLog("📊 Génération du rapport Excel professionnel...");
      
      DateTime start = _weeks["S01"]![0];
      DateTime end = _weeks["S05"]![1];
      String periodStr = "${start.day.toString().padLeft(2,'0')}/${start.month.toString().padLeft(2,'0')} au ${end.day.toString().padLeft(2,'0')}/${end.month.toString().padLeft(2,'0')}/${end.year}";
      
      final String outputPath = await _generator.generateReports(employees, widget.mode, periodStr);
      
      setState(() => _progress = 1.0);
      _addLog("✅ Opération terminée avec succès !");
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => ResultsScreen(employees: employees, outputPath: outputPath, mode: widget.mode)
        ));
      }
    } catch (e) {
      _addLog("❌ ERREUR CRITIQUE: $e");
    }
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_step == "config") setState(() => _step = "import");
              else Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: OcpTheme.cardDecoration(),
              child: const Text("‹ Retour", style: TextStyle(color: OcpTheme.text, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          Text(title, style: const TextStyle(color: OcpTheme.text, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 70), // Balance the row
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_step == "import") ...[
              _buildTopBar("Importer un fichier"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sélectionnez le fichier PDF natif généré par le système pour en extraire les pointages.", style: TextStyle(color: OcpTheme.textMuted, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 30),
                    
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: OcpTheme.cardDecoration(),
                        child: Row(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(color: const Color(0x18FF4560), borderRadius: BorderRadius.circular(14)),
                              child: const Center(child: Text("📄", style: TextStyle(fontSize: 26))),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Fichier PDF", style: TextStyle(color: OcpTheme.text, fontSize: 15, fontWeight: FontWeight.w800)),
                                  SizedBox(height: 2),
                                  Text("État Mensuel du Personnel", style: TextStyle(color: OcpTheme.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: OcpTheme.textMuted),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          border: Border.all(color: OcpTheme.border, style: BorderStyle.solid, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          children: [
                            Text("☁️", style: TextStyle(fontSize: 36)),
                            SizedBox(height: 12),
                            Text("Glisser-déposer ou appuyez ici", style: TextStyle(color: OcpTheme.textMuted, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_step == "config") ...[
              _buildTopBar("Configuration"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DÉCOUPAGE HEBDOMADAIRE ET PÉRIODE", style: TextStyle(color: OcpTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      
                      GestureDetector(
                        onTap: _pickDateRange,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: OcpTheme.accentDim,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: OcpTheme.accent),
                          ),
                          child: Row(
                            children: [
                              const Text("📅", style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Modifier la période de calcul", style: TextStyle(color: OcpTheme.accent, fontSize: 13, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text("Du ${_weeks["S01"]![0].day.toString().padLeft(2,'0')}/${_weeks["S01"]![0].month.toString().padLeft(2,'0')} au ${_weeks["S05"]![1].day.toString().padLeft(2,'0')}/${_weeks["S05"]![1].month.toString().padLeft(2,'0')}/${_weeks["S05"]![1].year}", style: const TextStyle(color: OcpTheme.text, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit, color: OcpTheme.accent, size: 20),
                            ],
                          ),
                        ),
                      ),
                      
                      ..._weeks.entries.map((e) => GestureDetector(
                        onTap: () async {
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: DateTimeRange(start: e.value[0], end: e.value[1]),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: OcpTheme.accent,
                                    onPrimary: Colors.black,
                                    surface: OcpTheme.surface,
                                    onSurface: OcpTheme.text,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _weeks[e.key] = [picked.start, picked.end];
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: OcpTheme.cardDecoration(),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(color: OcpTheme.accentDim, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x4400D4FF))),
                                child: Center(child: Text(e.key, style: const TextStyle(color: OcpTheme.accent, fontSize: 12, fontWeight: FontWeight.w800))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Semaine ${e.key.replaceAll('S0', '')}", style: TextStyle(color: OcpTheme.text, fontSize: 13, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text("${e.value[0].day.toString().padLeft(2,'0')}/${e.value[0].month.toString().padLeft(2,'0')} → ${e.value[1].day.toString().padLeft(2,'0')}/${e.value[1].month.toString().padLeft(2,'0')}", style: const TextStyle(color: OcpTheme.textMuted, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit, color: OcpTheme.accent, size: 20),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _process,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: OcpTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [BoxShadow(color: Color(0x4D00D4FF), blurRadius: 20, offset: Offset(0, 4))],
                          ),
                          child: const Text("🚀 Lancer l'analyse", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ] else if (_step == "processing") ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("⚙️", style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 20),
                        const Text("Analyse en cours", style: TextStyle(color: OcpTheme.text, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text("Traitement des données de pointage...", style: TextStyle(color: OcpTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 40),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Progression", style: TextStyle(color: OcpTheme.textMuted, fontSize: 12)),
                            Text("${(_progress * 100).toInt()}%", style: const TextStyle(color: OcpTheme.accent, fontSize: 12, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 8, width: double.infinity,
                          decoration: BoxDecoration(color: OcpTheme.card, borderRadius: BorderRadius.circular(4)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress,
                            child: Container(decoration: BoxDecoration(gradient: OcpTheme.primaryGradient, borderRadius: BorderRadius.circular(4))),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity, height: 280,
                          padding: const EdgeInsets.all(16),
                          decoration: OcpTheme.cardDecoration(),
                          child: ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(_logs[i], style: TextStyle(
                                  color: i == _logs.length - 1 ? OcpTheme.accent : OcpTheme.textMuted,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                )),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
