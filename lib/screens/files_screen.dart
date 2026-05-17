import 'package:flutter/material.dart';
import '../theme.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 80, color: OcpTheme.accent),
            const SizedBox(height: 20),
            const Text("Rapports", style: TextStyle(color: OcpTheme.text, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Les rapports générés se trouvent dans\nvotre dossier Téléchargements.", textAlign: TextAlign.center, style: TextStyle(color: OcpTheme.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
