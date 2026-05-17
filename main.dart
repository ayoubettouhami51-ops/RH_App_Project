import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'services/hr_processor.dart';
import 'excel_generator.dart';
import 'models/employee_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RH OCP - Custom',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filePath = "Aucun fichier sélectionné";
  bool _isLoading = false;
  final HRProcessor _processor = HRProcessor();
  final ExcelGenerator _generator = ExcelGenerator();

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  Future<void> _runProcess() async {
    if (_filePath == "Aucun fichier sélectionné") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez d'abord sélectionner un fichier PDF.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Employee> employees = await _processor.processPdf(_filePath);
      final String outputPath = await _generator.generateReports(employees);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Succès ! Rapports générés dans : $outputPath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du traitement : $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RH OCP - Custom"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              _filePath,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text("Sélectionner le PDF"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runProcess,
              icon: const Icon(Icons.analytics),
              label: const Text("Générer les Rapports Excel"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
