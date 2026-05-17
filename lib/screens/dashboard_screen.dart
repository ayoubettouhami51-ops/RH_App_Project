import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/processing_mode.dart';
import 'processor_screen.dart';
import 'files_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DashboardHome(),
    FilesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: OcpTheme.surface,
          border: Border(top: BorderSide(color: OcpTheme.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Rapports'),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bonjour 👋", style: TextStyle(color: OcpTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text("PointageXpert", style: TextStyle(color: OcpTheme.text, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  const Text("Analytics RH Professionnel", style: TextStyle(color: OcpTheme.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Stats Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0x1800D4FF), Color(0x187B61FF)]),
                border: Border.all(color: const Color(0x3300D4FF)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("DERNIÈRE ANALYSE", style: TextStyle(color: OcpTheme.accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(value: "100%", label: "Précision"),
                      _StatItem(value: "5", label: "Semaines (PP)"),
                      _StatItem(value: "Auto", label: "V04-V07"),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("MODULES D'ANALYSE", style: TextStyle(color: OcpTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: "⭐",
                          title: "Performance",
                          subtitle: "Calcul PP & PF",
                          color: OcpTheme.accent,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProcessorScreen(mode: ProcessingMode.performance))),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ActionCard(
                          icon: "⏳",
                          title: "Heures Supp",
                          subtitle: "Extraction V04-V07",
                          color: OcpTheme.accentGreen,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProcessorScreen(mode: ProcessingMode.overtime))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: "🚗",
                    title: "Prime Automobile",
                    subtitle: "Validation stricte (Mois d'Avril)",
                    color: OcpTheme.accentPurple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProcessorScreen(mode: ProcessingMode.automobile))),
                  ),
                ],
              ),
            ),

            // Features
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("FONCTIONNALITÉS INTELLIGENTES", style: TextStyle(color: OcpTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  _FeatureRow(icon: "🔍", title: "Extraction Intelligente", desc: "Analyse avancée des PDFs scannés et natifs", color: OcpTheme.accent),
                  _FeatureRow(icon: "✅", title: "Validation Métier", desc: "Exclusion auto: CA, CP, MIS, FC, RM, RC...", color: OcpTheme.accentGreen),
                  _FeatureRow(icon: "📊", title: "Rapports Professionnels", desc: "Génération Excel formatée et prête à l'envoi", color: OcpTheme.accentPurple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: OcpTheme.text, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: OcpTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OcpTheme.card,
          border: Border.all(color: OcpTheme.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: OcpTheme.text, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: OcpTheme.textMuted, fontSize: 11)),
            const SizedBox(height: 12),
            Container(width: 30, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  final Color color;

  const _FeatureRow({required this.icon, required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OcpTheme.card,
        border: Border.all(color: OcpTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: OcpTheme.text, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: OcpTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
