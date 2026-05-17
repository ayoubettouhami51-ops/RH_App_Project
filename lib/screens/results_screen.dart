import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../models/employee_model.dart';
import '../models/processing_mode.dart';
import '../theme.dart';

class ResultsScreen extends StatefulWidget {
  final List<Employee> employees;
  final String outputPath;
  final ProcessingMode mode;

  const ResultsScreen({super.key, required this.employees, required this.outputPath, required this.mode});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _tab = "table";
  bool _exported = false;

  void _openExcel() {
    OpenFile.open(widget.outputPath);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_exported) setState(() => _exported = false);
              else Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: OcpTheme.cardDecoration(),
              child: const Text("‹ Retour", style: TextStyle(color: OcpTheme.text, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const Text("Résultats", style: TextStyle(color: OcpTheme.text, fontSize: 16, fontWeight: FontWeight.w800)),
          if (!_exported)
            GestureDetector(
              onTap: () => setState(() => _exported = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: OcpTheme.accent, borderRadius: BorderRadius.circular(12)),
                child: const Text("Exporter", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            )
          else
            const SizedBox(width: 70),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_exported) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("✅", style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 24),
                        const Text("Exporté avec succès !", style: TextStyle(color: OcpTheme.accentGreen, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        const Text("Rapport_Pointage.xlsx", style: TextStyle(color: OcpTheme.textMuted, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(widget.outputPath, textAlign: TextAlign.center, style: const TextStyle(color: OcpTheme.textMuted, fontSize: 11)),
                        
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(color: OcpTheme.accentDim, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x4400D4FF))),
                          child: Text("${widget.employees.length} collaborateurs • Calculs appliqués", style: const TextStyle(color: OcpTheme.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        
                        const SizedBox(height: 50),
                        GestureDetector(
                          onTap: _openExcel,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: OcpTheme.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: OcpTheme.border),
                            ),
                            child: const Text("Ouvrir le fichier Excel", textAlign: TextAlign.center, style: TextStyle(color: OcpTheme.text, fontSize: 15, fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: OcpTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Color(0x4D00D4FF), blurRadius: 20, offset: Offset(0, 4))],
                            ),
                            child: const Text("Retour à l'accueil", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    double totalPP = widget.employees.fold(0, (sum, emp) => sum + emp.perfPP);
    String avgPP = widget.employees.isNotEmpty ? (totalPP / widget.employees.length).toStringAsFixed(1) : "0.0";

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            
            // KPI summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _KPICard(value: "${widget.employees.length}", label: "Collaborateurs", color: OcpTheme.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _KPICard(value: avgPP, label: "PP Moyen", color: OcpTheme.accentGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _KPICard(value: "0", label: "Alertes", color: OcpTheme.accentOrange)),
                ],
              ),
            ),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = "table"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tab == "table" ? OcpTheme.accent : OcpTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _tab == "table" ? OcpTheme.accent : OcpTheme.border),
                        ),
                        child: Text("Tableau", textAlign: TextAlign.center, style: TextStyle(color: _tab == "table" ? Colors.black : OcpTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = "chart"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tab == "chart" ? OcpTheme.accent : OcpTheme.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _tab == "chart" ? OcpTheme.accent : OcpTheme.border),
                        ),
                        child: Text("Graphique", textAlign: TextAlign.center, style: TextStyle(color: _tab == "chart" ? Colors.black : OcpTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _tab == "table" ? _buildTable() : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: const BoxDecoration(
            color: OcpTheme.accentDim,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(bottom: BorderSide(color: Color(0x4400D4FF))),
          ),
          child: Row(
            children: [
              const Expanded(flex: 3, child: Text("Nom & Prénom", style: TextStyle(color: OcpTheme.accent, fontSize: 10, fontWeight: FontWeight.w800))),
              const Expanded(flex: 2, child: Text("Matricule", style: TextStyle(color: OcpTheme.accent, fontSize: 10, fontWeight: FontWeight.w800))),
              ...["S01", "S02", "S03", "S04", "S05", "PP", "PF."].map((h) => Expanded(
                flex: 1,
                child: Text(h, textAlign: TextAlign.center, style: const TextStyle(color: OcpTheme.accent, fontSize: 10, fontWeight: FontWeight.w800)),
              )),
            ],
          ),
        ),
        ...widget.employees.asMap().entries.map((e) {
          int i = e.key;
          Employee emp = e.value;
          List<int> s = [
            emp.perfWeeks["S01"] ?? 0,
            emp.perfWeeks["S02"] ?? 0,
            emp.perfWeeks["S03"] ?? 0,
            emp.perfWeeks["S04"] ?? 0,
            emp.perfWeeks["S05"] ?? 0,
          ];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: i % 2 == 0 ? OcpTheme.card : OcpTheme.surface,
              border: Border(
                left: const BorderSide(color: OcpTheme.border),
                right: const BorderSide(color: OcpTheme.border),
                bottom: i == widget.employees.length - 1 ? const BorderSide(color: OcpTheme.border) : BorderSide.none,
              ),
              borderRadius: i == widget.employees.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(14)) : BorderRadius.zero,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(emp.name.split(" ").take(2).join(" "), style: const TextStyle(color: OcpTheme.text, fontSize: 11, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  flex: 2,
                  child: Text(emp.matricule, style: const TextStyle(color: OcpTheme.textMuted, fontSize: 10)),
                ),
                ...s.map((v) => Expanded(
                  flex: 1,
                  child: Text("$v", textAlign: TextAlign.center, style: TextStyle(
                    color: v >= 4 ? OcpTheme.accentGreen : v >= 3 ? OcpTheme.accentOrange : OcpTheme.accentRed,
                    fontSize: 12, fontWeight: FontWeight.w800,
                  )),
                )),
                Expanded(
                  flex: 1,
                  child: Text("${emp.perfPP}", textAlign: TextAlign.center, style: const TextStyle(color: OcpTheme.accent, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                Expanded(
                  flex: 1,
                  child: Text("${emp.perfPF}", textAlign: TextAlign.center, style: const TextStyle(color: OcpTheme.accent, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildChart() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: widget.employees.length,
      itemBuilder: (context, i) {
        Employee emp = widget.employees[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emp.name.split(" ").take(2).join(" "), style: const TextStyle(color: OcpTheme.text, fontSize: 12, fontWeight: FontWeight.w700)),
                  Text("PP: ${emp.perfPP}", style: const TextStyle(color: OcpTheme.accent, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10, width: double.infinity,
                decoration: BoxDecoration(color: OcpTheme.card, borderRadius: BorderRadius.circular(5)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: emp.perfPP / 25, // Assuming 25 is max roughly
                  child: Container(decoration: BoxDecoration(gradient: OcpTheme.primaryGradient, borderRadius: BorderRadius.circular(5))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KPICard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _KPICard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: OcpTheme.cardDecoration(),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: OcpTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
